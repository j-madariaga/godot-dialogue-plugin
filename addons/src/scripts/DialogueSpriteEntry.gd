@tool
class_name DialogueSpriteEntry
extends TextureRect


func OnMoveUp():
	var childIdx = get_index();
	print("Child idx = ", childIdx);
	if childIdx == 0:
		print("Could not move!")
		return;
	
	get_parent().move_child(self, childIdx - 1);
	pass;


func OnMoveDown():
	var childIdx = get_index();
	print("Child idx = ", childIdx);
	print("Child count = ", get_parent().get_child_count())
	if childIdx == get_parent().get_child_count() - 1:
		print("Could not move!")
		return;
	
	get_parent().move_child(self, childIdx + 1);
	pass;

func OnDelete():
	queue_free();
	pass;
