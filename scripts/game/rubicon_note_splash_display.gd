@tool
extends Node
class_name RubiconNoteSplashDisplay

@export var enabled: bool = true
@export var animation_player: AnimationPlayer:
	set(value):
		animation_player = value
		notify_property_list_changed()
var splash_animation: StringName

var anim_player_list:PackedStringArray:
	get():
		if animation_player != null:
			var anims:PackedStringArray = []
			anims.append_array(animation_player.get_animation_list())
			return anims
		return []

var _note_handler: RubiconLevelNoteHandler:
	set(value):
		if _note_handler == value:
			return
		
		if _note_handler != null:
			if _note_handler._controller.note_changed.is_connected(note_changed):
				_note_handler._controller.note_changed.disconnect(note_changed)
		
		_note_handler = value
		
		if _note_handler != null:
			_note_handler._controller.connect(&"note_changed", note_changed)

var _initialize_base_property: bool = true

func note_changed(result: RubiconLevelNoteHitResult, has_ending_row: bool) -> void:
	if result == null or animation_player == null:
		return
	
	if result.handler.get_unique_id() != _note_handler.get_unique_id():
		return
	
	if result.scoring_hit == result.Hit.HIT_COMPLETE and has_ending_row:
		return
	
	if result.scoring_rating == result.Judgment.JUDGMENT_PERFECT or result.scoring_rating == result.Judgment.JUDGMENT_GREAT:
		var splash_anim: StringName = _get_splash_animation()
		if splash_anim.is_empty() or splash_anim == null:
			return
		animation_player.play(splash_anim)
		animation_player.seek(0.0, true)

func _get_splash_animation() -> StringName:
	return splash_animation

func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	
	if animation_player != null and _initialize_base_property:
		properties.append({
			name = "splash_animation",
			hint = PROPERTY_HINT_ENUM,
			type = TYPE_STRING_NAME,
			usage = PROPERTY_USAGE_DEFAULT,
			hint_string = ",".join(anim_player_list)
		})
	
	return properties

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if splash_animation.is_empty():
		warnings.append(tr(&"You need to set a splash animation for the note splash to be displayed. Set it in the inspector after selecting a valid AnimationPlayer."))
	
	return warnings

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PARENTED:
			_note_handler = null
			
			var parent : Node = get_parent()
			if parent is RubiconLevelNoteHandler:
				_note_handler = parent
