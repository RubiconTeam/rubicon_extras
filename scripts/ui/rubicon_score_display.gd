@tool
extends Label
class_name RubiconScoreDisplay

@export var level_note_controller:RubiconLevelNoteController:
	set(value):
		if value != level_note_controller and level_note_controller != null and level_note_controller.performance_updated.is_connected(reformat_values):
			level_note_controller.performance_updated.disconnect(reformat_values)
		
		level_note_controller = value
		
		_controller_property_list.clear()
		for property: Dictionary in level_note_controller.get_script().get_script_property_list():
			_controller_property_list.append(property["name"])
		
		update_configuration_warnings()
		reformat_values()
		
		if level_note_controller != null:
			level_note_controller.performance_updated.connect(reformat_values)

@export_multiline var unformatted_text: String:
	set(value):
		if value == unformatted_text:
			return
		
		unformatted_text = value
		
		reformat_values()

@export var float_decimal_digits: int = 2:
	set(value):
		if value == float_decimal_digits:
			return
		
		float_decimal_digits = value
		reformat_values()

var _controller_property_list: PackedStringArray

var _last_formatted_text: String:
	set(value):
		_last_formatted_text = value
		text = value

func reformat_values() -> void:
	_last_formatted_text = unformatted_text.format(get_values())

func get_values() -> Dictionary[StringName, Variant]:
	if _controller_property_list.is_empty():
		return {}
	
	var new_dict: Dictionary[StringName, Variant] = {}
		
	for value_idx: int in _controller_property_list.size():
		var property_name: StringName = _controller_property_list[value_idx]
		if level_note_controller != null:
			var value: Variant = level_note_controller.get(property_name)
			var value_string: String = str(value)
			
			if value is float:
				value_string = value_string.pad_decimals(float_decimal_digits)
			
			new_dict.set(property_name, value_string)
	
	return new_dict

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if level_note_controller == null:
		warnings.append(tr("This node requires a note controller to display score. Make sure to assign one on the inspector"))
	
	return warnings

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_EDITOR_PRE_SAVE:
			if unformatted_text == null:
				return
			
			text = unformatted_text
		
		NOTIFICATION_EDITOR_POST_SAVE:
			if _last_formatted_text == null:
				return
			
			text = _last_formatted_text
