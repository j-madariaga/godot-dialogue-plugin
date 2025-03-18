extends TextureRect


func OnMoveUp():
	#var childIdx = get_index();
	#print("Child idx = ", childIdx);
	#if childIdx == 1:
		#return;
	#
	#move_child(self, childIdx - 1);
	pass;


func OnMoveDown():
	#var childIdx = get_index();
	#print("Child idx = ", childIdx);
	#if childIdx == get_parent().get_child_count():
		#return;
	#
	#move_child(self, childIdx + 1);
	pass;

func OnDelete():
	queue_free();
	pass;
