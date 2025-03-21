@tool
class_name TextEntryObj
extends TextureRect

@onready var speaker = $VBoxContainer/SpeakerInput/TextInput
@onready var rightSideToggle = $VBoxContainer/SpeakerInput/SpeakerRightToggle
@onready var textSquare = $VBoxContainer/TextInput/TextInput;

func OnMoveUp():
	var childIdx = get_index();
	if childIdx == 0:
		return;
	
	get_parent().move_child(self, childIdx - 1);
	pass;


func OnMoveDown():
	var childIdx = get_index();
	if childIdx == get_parent().get_child_count() - 1:
		return;
	
	get_parent().move_child(self, childIdx + 1);
	pass;

func OnDelete():
	queue_free();
	pass;

func Save(_data):
	var textBit = DialogueTextBit.new();
	textBit.speakerName = speaker.text;
	textBit.speakerRightSide = rightSideToggle.button_pressed;
	textBit.dialogueText = textSquare.text;
	_data.append(textBit);
	pass;
