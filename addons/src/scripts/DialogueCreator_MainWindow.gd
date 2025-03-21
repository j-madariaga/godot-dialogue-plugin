@tool
extends Control

@onready var dialogueDataScreen = $DialogueCreatorMainWindow/DialogueData
@onready var dialogueBitList = $DialogueCreatorMainWindow/DialogueData/DialogueBits/BitScroll/BitList

@onready var titleInput = $DialogueCreatorMainWindow/DialogueData/TitleContainer/TitleEditText
@onready var fileNameInput = $DialogueCreatorMainWindow/DialogueData/FilenameContainer/FileNameTextEdit
@onready var triggerChanceInput = $DialogueCreatorMainWindow/DialogueData/TitleContainer/TriggerChanceInput

const OUTPUT_PATH = "res://addons/output/";
const TEXT_BIT_ARCH = preload("res://addons/src/scenes/DialogueTextEntry.tscn");
const SPRITE_BIT_ARCH = preload("res://addons/src/scenes/DialogueSpriteEntry.tscn");
const TRANS_BIT_ARCH = preload("res://addons/src/scenes/DialogueTransitionEntry.tscn");
# Called when the node enters the scene tree for the first time.
func _ready():
	VerifySaveDir();
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


func VerifySaveDir():
	DirAccess.make_dir_absolute(OUTPUT_PATH);
	pass;

func OnDialogueSave():
	print("Saving dialogue file")
	
	if fileNameInput.text == "":
		printerr("ERROR: A FILENAME MUST BE GIVEN!")
		return;
	
	
	var newDialogue = DialogueFile.new();
	newDialogue.dialogueTitle = titleInput.text
	newDialogue.dialogueFileName = fileNameInput.text;
	newDialogue.triggerChance = int(triggerChanceInput.text);
	
	for bit in dialogueBitList.get_children():
		bit.Save(newDialogue.dialogueBits);
	
	newDialogue.DebugPrint();
	var jsonData = JSON.stringify(newDialogue, "\t");
	
	var fullPath = OUTPUT_PATH + fileNameInput.text + ".dialogue";
	print(fullPath);
	var file = FileAccess.open(fullPath, FileAccess.WRITE);
	file.store_string(jsonData);
	file.close();
	
	pass;

func AddTextBit():
	print("New text bit created");
	var newTextBit = TEXT_BIT_ARCH.instantiate();
	dialogueBitList.add_child(newTextBit);
	pass;
	
func AddSpriteBit():
	print("New sprite bit created");
	var newSpriteBit = SPRITE_BIT_ARCH.instantiate();
	dialogueBitList.add_child(newSpriteBit);
	
func AddTransitionBit():
	print("New transition bit added");
	var newTransBit = TRANS_BIT_ARCH.instantiate();
	dialogueBitList.add_child(newTransBit);
	pass;

