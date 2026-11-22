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

@export_group("Neutral", "neutral_")
@export var neutral_animation_name: StringName = &"neutral"

@export_group("Lose", "lose_")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var lose_enabled: bool = true
@export var lose_animation_name: StringName = &"lose"
@export_range(0, 1, 0.003) var lose_trigger_percentage: float = 0.75

@export_group("Win", "win_")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var win_enabled: bool = false
@export var win_animation_name: StringName = &"win"
@export var win_trigger_percentage: float = 0.25

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

func _validate_property(property: Dictionary) -> void:
	match property.name:
		&"neutral_animation_name", &"lose_animation_name", &"win_animation_name":
			property.hint = PROPERTY_HINT_ENUM
			property.hint_string = ",".join(sprite_frames.get_animation_names())
