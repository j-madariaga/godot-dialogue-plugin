@tool
class_name TransitionEntryObj
extends TextureRect

@onready var backTex = $GeneralData/Background/BGInput
@onready var bgVisible = $GeneralData/Background/BGVisibleToggle;
@onready var transitionDropDown = $GeneralData/TransitionSection/TransitionDropdown
@onready var transDuration = $GeneralData/DurationSection/DurationInput

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
	pass;

func OnDelete():
	queue_free();
	return;


func Save(data := {}):
	data["id"] = "TRANS";
	data["background"] = backTex.text;
	data["bgVisible"] = bgVisible.is_pressed();
	data["transition"] = transitionDropDown.get_item_text(transitionDropDown.selected);
	data["duration"] = float(transDuration.text);
	return;

func Load(data := {}):
	backTex.text = data["background"];
	bgVisible.button_pressed = bool(data["bgVisible"]); 
	
	for i in transitionDropDown.item_count:
		if transitionDropDown.get_item_text(i) == data["transition"]:
			transitionDropDown.selected = i;
	
	transDuration.text = str(data["duration"]);
