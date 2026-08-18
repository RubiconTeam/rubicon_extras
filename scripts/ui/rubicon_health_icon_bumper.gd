@tool
extends Node
class_name RubiconHealthIconBumper

enum BumpTime {
	STEP,
	BEAT,
	MEASURE,
}

@export var enabled: bool = true

@export var rubicon_level: RubiconLevel:
	set(value):
		rubicon_level = value
		set_bump_time(bump_every)
		
@export var icons_to_bump: Array[Node2D]

@export var bump_every: BumpTime = BumpTime.MEASURE:
	set(value):
		bump_every = value
		set_bump_time(value)

@export_range(1, 128) var bump_interval: int = 1

@export_custom(PROPERTY_HINT_LINK, "") var bump_amount: Vector2 = Vector2(0.05, 0.05)
@export var bump_interpolate_speed: float = 3.125



var _icon_property_list: PackedStringArray = []
@export_storage var _icon_property_value: Dictionary[StringName, Vector2]

func set_bump_time(new_bump_time: BumpTime):
	if rubicon_level == null:
		return
	
	match bump_every:
		BumpTime.STEP:
			if rubicon_level.clock.beat_change.is_connected(icon_bump):
				rubicon_level.clock.beat_change.disconnect(icon_bump)
			
			if rubicon_level.clock.measure_change.is_connected(icon_bump):
				rubicon_level.clock.measure_change.disconnect(icon_bump)
			
			if !rubicon_level.clock.step_change.is_connected(icon_bump):
				rubicon_level.clock.step_change.connect(icon_bump)
		
		BumpTime.BEAT:
			if rubicon_level.clock.step_change.is_connected(icon_bump):
				rubicon_level.clock.step_change.disconnect(icon_bump)
			
			if rubicon_level.clock.measure_change.is_connected(icon_bump):
				rubicon_level.clock.measure_change.disconnect(icon_bump)
			
			if !rubicon_level.clock.beat_change.is_connected(icon_bump):
				rubicon_level.clock.beat_change.connect(icon_bump)
		
		BumpTime.MEASURE:
			if rubicon_level.clock.step_change.is_connected(icon_bump):
				rubicon_level.clock.step_change.disconnect(icon_bump)
			
			if rubicon_level.clock.beat_change.is_connected(icon_bump):
				rubicon_level.clock.beat_change.disconnect(icon_bump)
			
			if !rubicon_level.clock.measure_change.is_connected(icon_bump):
				rubicon_level.clock.measure_change.connect(icon_bump)

func icon_bump() -> void:
	if !enabled:
		return
	print("uh")
	var cur_time: int = floorf(get_cur_time_value())
	if cur_time % bump_interval != 0:
		return
	
	for icon in icons_to_bump:
		icon.scale += bump_amount
		print(icon.scale)

var placeholder_icon_base_scale: Vector2 = Vector2.ONE
func _process(delta: float) -> void:
	if !enabled:
		return
	
	for icon in icons_to_bump:
		icon.scale = icon.scale.lerp(placeholder_icon_base_scale, bump_interpolate_speed * delta)

func get_cur_time_value() -> float:
	match bump_every:
		BumpTime.BEAT:
			return rubicon_level.clock.time_beat
		BumpTime.STEP:
			return rubicon_level.clock.time_step
	return rubicon_level.clock.time_measure

func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	
	if !icons_to_bump.is_empty():
		properties.append({
			name = &"Icon Base Scale",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_GROUP,
			hint_string = "scale_",
		})
		
		_icon_property_list.clear()
		for icon: AnimatedSprite2D in icons_to_bump:
			_icon_property_list.append(icon.name)
			var icon_property_name: StringName = &"scale_%s_base_scale" % [icon.name]
			properties.append({
				name = icon_property_name,
				type = TYPE_VECTOR2,
				usage = PROPERTY_USAGE_DEFAULT,
				hint = PROPERTY_HINT_LINK
			})
			_icon_property_value.set(icon_property_name, icon.scale)
			#print(get(icon_property_name))
		#print(_icon_property_list,_icon_property_value)
		
		# prevent deleted values to be saved in the scene making it infinitely bloated
		for value_key:StringName in _icon_property_value.keys():
			if !_icon_property_list.has(value_key):
				_icon_property_value.erase(value_key)
	
	return properties

func _get(property: StringName) -> Variant:
	if property.begins_with("scale_"):
		if _icon_property_list.has(property):
			print("get property "+property)
			return _icon_property_value[property]
	
	return null

func _set(property: StringName, value: Variant) -> bool:
	if property.begins_with("scale_"):
		if _icon_property_list.has(property):
			_icon_property_value.set(property, value)
			print("set property "+property)
			return true
	return false
