@tool
class_name DialogueSpriteEntry
extends TextureRect

@onready var textures = $SpriteInput/TextureSection/HBoxContainer
@onready var flipBools = $SpriteInput/FlippedToggles/HBoxContainer
@onready var visibleBools = $SpriteInput/VisibleToggles/HBoxContainer
@onready var highlightToggles = $SpriteInput/HighlightToggles/HBoxContainer


func OnMoveUp():
	var childIdx = get_index();
	if childIdx == 0:
		return;
	
	get_parent().move_child(self, childIdx - 1);



func OnMoveDown():
	var childIdx = get_index();
	if childIdx == get_parent().get_child_count() - 1:
		return;
	
	get_parent().move_child(self, childIdx + 1);


func OnDelete():
	queue_free();

	
func Save(data := {}):
	data["id"] = "SPRITE";
	var texData = [];
	var flipData = [];
	var visData = [];
	var highData = []; 
	
	var size = textures.get_child_count();
	for i in size:
		if textures.get_child(i).text == "":
			continue;
		
		texData.append(textures.get_child(i).text);
		flipData.append(flipBools.get_child(i).is_pressed());
		visData.append(visibleBools.get_child(i).is_pressed());
		highData.append(highlightToggles.get_child(i).is_pressed());
	
	data["textures"] = texData;
	data["flipped"] = flipData;
	data["visible"] = visData;
	data["highlighted"] = highData;	
	return;
	
func Load(data := {}):
	if data.has("textures") == false:
		return;
	
	var size = data["textures"].size();
	for i in size:
		textures.get_child(i).text = data["textures"][i];
		flipBools.get_child(i).button_pressed = data["flipped"][i];
		visibleBools.get_child(i).button_pressed = data["visible"][i];
		highlightToggles.get_child(i).button_pressed = data["highlighted"][i];
