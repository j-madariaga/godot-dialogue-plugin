@tool
extends EditorPlugin

var panel;

func _enter_tree():
	# Initialization of the plugin goes here.
	# Instantiate the plugin on the top toolbar of the editor
	panel = preload("res://addons/src/scenes/DialogueCreator_MainWindow.tscn").instantiate();
	EditorInterface.get_editor_main_screen().add_child(panel)
	_make_visible(true);
	pass


func _exit_tree():
	# Clean-up of the plugin goes here.
	# Remove plugin from the toolbar
	panel.queue_free();
	pass


func _has_main_screen():
	return true


func _make_visible(visible):
	if panel:
		panel.visible = visible;
	pass


func _get_plugin_name():
	return "Dialogue Creator"


func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
