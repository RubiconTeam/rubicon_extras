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
		

@export var icon_group_first: Node2D
@export var icon_group_second: Node2D
#@export var icons_to_bump: Array[Node2D]:
	#set(value):
		#if value == icons_to_bump or value == null:
			#return
		#
		#icons_to_bump = value
		#for i: int in icons_to_bump.size():
			#var icon: Node2D = icons_to_bump[i]
			#if icon == null:
				#_icons_base_scale[i] = Vector2.ZERO
				#continue
				#
			#_icons_base_scale[i] = icon.scale
		#notify_property_list_changed()
		#
		#var icon_amount: int = icons_to_bump.size()
		#for i: int in _icons_base_scale.size():
			#if i < icon_amount:
				#continue
			#else:
				#_icons_base_scale.remove_at(i)

@export var bump_every: BumpTime = BumpTime.MEASURE:
	set(value):
		bump_every = value
		set_bump_time(value)

@export_range(1, 128) var bump_interval: int = 1

#@export_custom(PROPERTY_HINT_LINK, "") var bump_amount: Vector2 = Vector2(0.05, 0.05)
@export_custom(PROPERTY_HINT_LINK, "") var bump_amount_first: Vector2 = Vector2(0.05, 0.05)
@export_custom(PROPERTY_HINT_LINK, "") var bump_amount_second: Vector2 = Vector2(-0.05, 0.05)
@export var bump_interpolate_speed: float = 3.125

@export_storage var _icons_base_scale: Array[Vector2]

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
	
	var cur_time: int = floorf(get_cur_time_value())
	if cur_time % bump_interval != 0:
		return
	
	#for icon in icons_to_bump:
		#icon.scale += bump_amount
	if icon_group_first != null:
		icon_group_first.scale += bump_amount_first
	if icon_group_second != null:
		icon_group_second.scale += bump_amount_second

var placeholder_icon_base_scale_first: Vector2 = Vector2.ONE
var placeholder_icon_base_scale_second: Vector2 = Vector2(-1, 1)
func _process(delta: float) -> void:
	if !enabled or rubicon_level == null:
		return
	
	#for icon in icon_groups_to_bump:
		#icon.scale = icon.scale.lerp(placeholder_icon_base_scale, bump_interpolate_speed * delta)
	# this approach is extremely limited, i'll be adding a proper way of doing this,
	# i just want to finish this atm
	if icon_group_first != null:
		icon_group_first.scale = icon_group_first.scale.lerp(placeholder_icon_base_scale_first, bump_interpolate_speed * delta)
	if icon_group_second != null:
		icon_group_second.scale = icon_group_second.scale.lerp(placeholder_icon_base_scale_second, bump_interpolate_speed * delta)

func get_cur_time_value() -> float:
	match bump_every:
		BumpTime.BEAT:
			return rubicon_level.clock.time_beat
		BumpTime.STEP:
			return rubicon_level.clock.time_step
	return rubicon_level.clock.time_measure

#func _get_property_list() -> Array[Dictionary]:
	#var properties: Array[Dictionary] = []
	#
	#if !icons_to_bump.is_empty():
		#properties.append({
			#name = &"Icon Base Scale",
			#type = TYPE_NIL,
			#usage = PROPERTY_USAGE_GROUP,
			#hint_string = "scale_",
		#})
		#
		#for icon: AnimatedSprite2D in icons_to_bump:
			#if icon == null:
				#continue
			#var icon_property_name: StringName = &"scale_%s_base_scale" % [icon.name]
			#properties.append({
				#name = icon_property_name,
				#type = TYPE_VECTOR2,
				#usage = PROPERTY_USAGE_DEFAULT,
				#hint = PROPERTY_HINT_LINK
			#})
		#
		#
	#
	#return properties
