@tool
extends Control

@onready var dialogueDataScreen = $DialogueCreatorMainWindow/DialogueData
@onready var dialogueBitList = $DialogueCreatorMainWindow/DialogueData/DialogueBits/BitScroll/BitList

const OUTPUT_PATH = "res://addons/output/";
const TEXT_BIT_ARCH = preload("res://addons/src/scenes/DialogueTextEntry.tscn");

# Called when the node enters the scene tree for the first time.
func _ready():
	dialogueDataScreen.visible = false;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func OnNewDialogue():
	print("New dialogue resource created");
	dialogueDataScreen.visible = true;
	pass;

func OnDialogueImport():
	print("Importing dialogue file")
	pass;
	
func OnDialogueSave():
	print("Saving dialogue file")
	pass;

func AddTextBit():
	print("New text bit created");
	var newTextBit = TEXT_BIT_ARCH.instantiate();
	dialogueBitList.add_child(newTextBit);
	pass;
	
func AddTransitionBit():
	print("New transition bit added");
	pass;
