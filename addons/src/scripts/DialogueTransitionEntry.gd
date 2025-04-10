@tool
class_name TransitionEntryObj
extends TextureRect

@onready var backTex = $GeneralData/Background/TextInput
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
	data["type"] = "TRANS";
	data["background"] = backTex.text;
	data["bgVisible"] = bgVisible.is_pressed();
	data["transition"] = transitionDropDown.get_item_text(transitionDropDown.selected);
	data["duration"] = float(transDuration.text);
	return;
