@tool
class_name TextEntryObj
extends TextureRect

@onready var speaker = $Data/VBoxContainer/SpeakerInput/TextInput
@onready var rightSideToggle = $Data/VBoxContainer/SpeakerInput/SpeakerRightToggle as CheckButton
@onready var textSquare = $Data/VBoxContainer/TextInput/TextInput;

@onready var texFiles = $Data/Textures/HBoxContainer/TexEntry
@onready var visibleBools = $Data/Textures/HBoxContainer/Visible
@onready var flippedBools = $Data/Textures/HBoxContainer/Flipped
@onready var highlightBools = $Data/Textures/HBoxContainer/Highlighted

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

func Save(data := {}) -> int:
	data["id"] = "TEXT";
	data["speakerName"] = {};
	data["speakerName"] = speaker.text;
	data["rightSide"] = rightSideToggle.is_pressed();
	data["text"] = {};
	
	data["text"]["en_US"] = textSquare.text;
	
	
	var texData = {};
	
	var size = texFiles.get_child_count();
	for i in size:
		if texFiles.get_child(i).text == "KEEP":
			continue;
			
		texData[i] = {};
		texData[i]["file"] = texFiles.get_child(i).text;
		
		texData[i]["visible"] = visibleBools.get_child(i).is_pressed();
		texData[i]["flipped"] = flippedBools.get_child(i).is_pressed();
		texData[i]["highlighted"] = highlightBools.get_child(i).is_pressed();
		
	if texData == {}:
		return 1;
		
	data["textures"] = texData;
	return 1;

	
func Load(data := {}):
	#speaker.text = data["speakerName"]["en_US"];
	rightSideToggle.button_pressed = data["rightSide"];
	
	var textData = data["text"];	
	# No translation?
	if textData is String:	
		textSquare.text = data["text"];		
	# Translated name:
	elif textData is Dictionary:		
		# English by default
		if textData.has("en_US"):
			textSquare.text = textData["en_US"];
		# Otherwise, use first found locale
		else:
			textSquare.text = textData[textData.keys()[0]]
			
	speaker.text = data["speakerName"];
	
	if data.has("textures") == false:
		return;
	
	var size = data["textures"].size()
	for i in size:
		if data["textures"].has(i) == false:
			continue;
		texFiles.get_child(i).text = data["textures"][i]["file"];
		flippedBools.get_child(i).button_pressed = data["textures"][i]["flipped"];
		visibleBools.get_child(i).button_pressed = data["textures"][i]["visible"];
		highlightBools.get_child(i).button_pressed = data["textures"][i]["highlight"];
