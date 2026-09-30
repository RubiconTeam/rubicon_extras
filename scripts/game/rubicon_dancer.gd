@tool
extends Node
class_name RubiconDancer

enum BumpTime {
	STEP,
	BEAT,
	MEASURE,
}

@export var _level: RubiconLevel:
	set(value):
		_level = value
		set_dance_time(dance_every)

@export var animation_player: AnimationPlayer:
	set(value):
		animation_player = value
		notify_property_list_changed()
		update_configuration_warnings()

@export var enabled: bool = true

@export var dance_every: BumpTime = BumpTime.MEASURE:
	set(value):
		dance_every = value
		set_dance_time(value)

@export_range(1, 128) var dance_interval: int = 1

@export_group("Animation", "dancing_")
@export var dancing_force_dance:bool = true
@export_storage var _dancing_animations:Array[StringName] = []:
	set(value):
		if value == _dancing_animations:
			return

		_dancing_animations = value
		_dance_anim_size = _dancing_animations.size()
		_dance_anim_index = 0

@export var dancing_retain_animation_queue: bool = false

var anim_player_list:PackedStringArray:
	get():
		if animation_player != null:
			var anims:PackedStringArray = [&"None"]
			anims.append_array(animation_player.get_animation_list())
			return anims
		return [&"None"]

var _dance_measure_step: float = 0.5
var _dance_step_offset: int = 0
var _dance_step_interval: int = 8
var _last_dance_step:int

var _dance_anim_index:int
var _dance_anim_size:int

func set_dance_time(new_bump_time: BumpTime):
	if _level == null:
		return
	
	match dance_every:
		BumpTime.STEP:
			if _level.clock.beat_change.is_connected(dance):
				_level.clock.beat_change.disconnect(dance)
			
			if _level.clock.measure_change.is_connected(dance):
				_level.clock.measure_change.disconnect(dance)
			
			if !_level.clock.step_change.is_connected(dance):
				_level.clock.step_change.connect(dance)
		
		BumpTime.BEAT:
			if _level.clock.step_change.is_connected(dance):
				_level.clock.step_change.disconnect(dance)
			
			if _level.clock.measure_change.is_connected(dance):
				_level.clock.measure_change.disconnect(dance)
			
			if !_level.clock.beat_change.is_connected(dance):
				_level.clock.beat_change.connect(dance)
		
		BumpTime.MEASURE:
			if _level.clock.step_change.is_connected(dance):
				_level.clock.step_change.disconnect(dance)
			
			if _level.clock.beat_change.is_connected(dance):
				_level.clock.beat_change.disconnect(dance)
			
			if !_level.clock.measure_change.is_connected(dance):
				_level.clock.measure_change.connect(dance)

func dance() -> void:
	if not enabled or _dancing_animations.is_empty():
		return
	var cur_time: int = floorf(get_cur_time_value())
	if cur_time % dance_interval != 0:
		return

	var anim:StringName = _dancing_animations[_dance_anim_index]
	if !anim.is_empty() and anim != &"None":
		play(anim, true)

	_dance_anim_index = wrapi(_dance_anim_index + 1, 0, _dance_anim_size)

func play(anim_name:StringName, warn_missing_animation:bool = false) -> void:
	if animation_player == null:
		printerr("Animation Player is null in character " + scene_file_path.get_file())
		return

	if !animation_player.has_animation(anim_name):
		if warn_missing_animation:
			printerr('No animation "'+anim_name+'" found in character: ' + scene_file_path.get_file())
		return

	var same_animation_queue : Array[StringName]
	if dancing_retain_animation_queue and animation_player.current_animation == anim_name:
		same_animation_queue = animation_player.get_queue()
	
	animation_player.stop()
	animation_player.play(anim_name)
	animation_player.seek(0.0, true)

func get_cur_time_value() -> float:
	match dance_every:
		BumpTime.BEAT:
			return _level.clock.time_beat
		BumpTime.STEP:
			return _level.clock.time_step
	return _level.clock.time_measure

func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	
	if animation_player != null:
		properties.append({
				name = &"dancing_animations",
				type = TYPE_ARRAY,
				usage = PROPERTY_USAGE_DEFAULT,
				hint = PROPERTY_HINT_TYPE_STRING,
				hint_string = "%d/%d:%s" % [TYPE_STRING_NAME, PROPERTY_HINT_ENUM, ",".join(anim_player_list)],
			})
	
	return properties

func _get(property: StringName) -> Variant:
	if property == &"dancing_animations":
		return _dancing_animations
	return null

func _set(property: StringName, value: Variant) -> bool:
	if property == &"dancing_animations":
		_dancing_animations = value
		return true
	return false
