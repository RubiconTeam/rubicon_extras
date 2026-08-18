@tool
extends AnimatedSprite2D

@export var health_bar: RubiconHealthBar:
	set(value):
		if value != health_bar and health_bar != null and health_bar.value_changed.is_connected(health_changed):
			health_bar.value_changed.disconnect(health_changed)
		
		health_bar = value
		update_configuration_warnings()
		
		if health_bar != null:
			health_bar.value_changed.connect(health_changed)

var neutral_animation_name: StringName = &"neutral"

var lose_enabled: bool = true
var lose_animation_name: StringName = &"lose"
var lose_trigger_percentage: float

var win_enabled: bool = false
var win_animation_name: StringName = &"win"
var win_trigger_percentage: float

func health_changed(_value: float) -> void:
	var health_module: RubiconHealthModule = health_bar.health_module
	var normalized_health: float = (health_module.health - health_module.min_health) / (health_module.max_health - health_module.min_health)
	
	if win_trigger_percentage > lose_trigger_percentage:
		if normalized_health > win_trigger_percentage:
			if win_enabled and win_animation_name != null:
				play(win_animation_name)
				return
		elif normalized_health < lose_trigger_percentage:
			if lose_enabled and lose_animation_name != null:
				play(lose_animation_name)
				return
	else:
		if normalized_health < win_trigger_percentage:
			if win_enabled and win_animation_name != null:
				play(win_animation_name)
				return
		elif normalized_health > lose_trigger_percentage:
			if lose_enabled and lose_animation_name != null:
				play(lose_animation_name)
				return
	
	if neutral_animation_name != null:
		play(neutral_animation_name)

func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	
	properties.append({
			name = &"Neutral",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_GROUP,
			hint_string = "neutral_"
		})
	
	properties.append({
		name = &"neutral_animation_name",
		hint = PROPERTY_HINT_ENUM,
		type = TYPE_STRING_NAME,
		usage = PROPERTY_USAGE_DEFAULT,
		hint_string = ",".join(sprite_frames.get_animation_names())
	})
	
	properties.append({
			name = &"Lose",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_GROUP,
			hint_string = "lose_"
		})
	
	properties.append({
			name = &"lose_enabled",
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT,
			hint = PROPERTY_HINT_GROUP_ENABLE
		})
	
	properties.append({
		name = &"lose_animation_name",
		hint = PROPERTY_HINT_ENUM,
		type = TYPE_STRING_NAME,
		usage = PROPERTY_USAGE_DEFAULT,
		hint_string = ",".join(sprite_frames.get_animation_names())
	})
	
	properties.append({
			name = &"lose_trigger_percentage",
			type = TYPE_FLOAT,
			usage = PROPERTY_USAGE_DEFAULT,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0,1"
		})
	
	properties.append({
			name = &"Win",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_GROUP,
			hint_string = "win_"
		})
	
	properties.append({
			name = &"win_enabled",
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT,
			hint = PROPERTY_HINT_GROUP_ENABLE
		})
	
	properties.append({
		name = &"win_animation_name",
		hint = PROPERTY_HINT_ENUM,
		type = TYPE_STRING_NAME,
		usage = PROPERTY_USAGE_DEFAULT,
		hint_string = ",".join(sprite_frames.get_animation_names())
	})
	
	properties.append({
			name = &"win_trigger_percentage",
			type = TYPE_FLOAT,
			usage = PROPERTY_USAGE_DEFAULT,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0,1"
		})
	
	return properties
