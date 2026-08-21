@tool
extends Node
class_name RubiconVocalController

@export var target_vocal: AudioStreamPlayer
@export var note_controllers: Array[RubiconLevelNoteController]

@export_group('Random Pitch Range', 'pitch_range_')
@export var pitch_range_min: float = 1.0
@export var pitch_range_max: float = 1.0

var _misses: Array[AudioStreamPlayer]

func _ready() -> void:
	for child in get_children():
		if child is AudioStreamPlayer: _misses.append(child)

	for controller in note_controllers:
		controller.note_changed.connect(_on_note_changed)

func _on_note_changed(result: RubiconLevelNoteHitResult, _has_ending_row: bool) -> void:
	if !is_instance_valid(target_vocal): return

	if result.scoring_rating == RubiconLevelNoteHitResult.Judgment.JUDGMENT_MISS:
		target_vocal.volume_linear = 0.0
		_play_miss()
	else:
		target_vocal.volume_linear = 1.0

func _play_miss() -> void:
	if _misses.is_empty(): return

	var miss := _misses[randi_range(0, maxi(_misses.size() - 1, 0))]
	miss.pitch_scale = randf_range(pitch_range_min, pitch_range_max)
	miss.play()
