@tool
extends RubiconNoteSplashDisplay
class_name RubiconRandomSplashDisplay


@export_storage var splash_animations: Dictionary[StringName, StringName]
var random_animation_count: int:
	set(value):
		if value <= 0:
			value = 1
		
		if value < random_animation_count:
			for i: int in value:
				var idx: int = i + (random_animation_count - 1)
				splash_animations.erase(&"splash_animation_%s" % [idx])
				print("removed "+str(idx))
		
		random_animation_count = value
		notify_property_list_changed()

var _prev_random_animation_count: int

func _get_splash_animation() -> StringName:
	var random_splash_idx: int = randi_range(0, random_animation_count - 1)
	return splash_animations.get(&"splash_animation_%s" % [random_splash_idx])

func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	
	_initialize_base_property = false
	if animation_player != null:
		properties.append({
			name = &"random_animation_count",
			type = TYPE_INT,
			usage = PROPERTY_USAGE_DEFAULT
		})
		
		for i: int in random_animation_count:
			var anims_array: Array[StringName] = [&""]
			anims_array.append_array(anim_player_list)
			properties.append({
				name = &"splash_animation_%s" % [i],
				hint = PROPERTY_HINT_ENUM,
				type = TYPE_STRING_NAME,
				usage = PROPERTY_USAGE_EDITOR,
				hint_string = ",".join(anims_array)
			})
	
	return properties

func _get(property: StringName) -> Variant:
	if property.begins_with("splash_animation_"):
		return splash_animations[property] if splash_animations.has(property) else null
	
	return null

func _set(property: StringName, value: Variant):
	if property.begins_with("splash_animation_"):
		splash_animations.set(property, value)
		return true
	
	return false

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if splash_animations.is_empty():
		warnings.append(tr(&"You need to set a splash animation for the note splash to be displayed. Set it in the inspector after selecting a valid AnimationPlayer."))
	
	return warnings
