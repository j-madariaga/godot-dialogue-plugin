@tool
extends Button

var mainWindow;



# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.connect(OnPluginButtonPress);
	mainWindow.ReadDialogues();
	pass # Replace with function body.


func OnPluginButtonPress():
	mainWindow.ReadDialogue();
	
	#mainWindow = preload("res://addons/src/scenes/DialogueCreator_MainWindow.tscn").instantiate();
	#EditorPlugin.add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, mainWindow);
