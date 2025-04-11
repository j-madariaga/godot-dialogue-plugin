@tool
class_name TextEntryObj
extends TextureRect

@onready var speaker = $VBoxContainer/SpeakerInput/TextInput
@onready var rightSideToggle = $VBoxContainer/SpeakerInput/SpeakerRightToggle as CheckButton
@onready var textSquare = $VBoxContainer/TextInput/TextInput;

func OnMoveUp():
	var childIdx = get_index();
	if childIdx == 0:
		return;
	
	get_parent().move_child(self, childIdx - 1);
	return;


func OnMoveDown():
	var childIdx = get_index();
	if childIdx == get_parent().get_child_count() - 1:
		return;
	
	get_parent().move_child(self, childIdx + 1);
	return;


func OnDelete():
	queue_free();
	return;

func Save(data := {}):
	data["type"] = "TEXT";
	data["speakerName"] = speaker.text;
	data["rightSide"] = rightSideToggle.is_pressed();
	data["text"] = textSquare.text;
	return;
	
func Load(data := {}):
	speaker.text = data["speakerName"];
	rightSideToggle.button_pressed = data["rightSide"];
	textSquare.text = data["text"];
