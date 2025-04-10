@tool
extends Control

@onready var dialogueDataScreen = $DialogueCreatorMainWindow/DialogueDataHolder/DialogueData
@onready var dialogueBitList = $DialogueCreatorMainWindow/DialogueDataHolder/DialogueData/DialogueBits/BitScroll/BitList

@onready var titleInput = $DialogueCreatorMainWindow/DialogueDataHolder/DialogueData/TitleContainer/TitleEditText
@onready var fileNameInput = $DialogueCreatorMainWindow/DialogueDataHolder/DialogueData/FilenameContainer/FileNameTextEdit
@onready var triggerChanceInput = $DialogueCreatorMainWindow/DialogueDataHolder/DialogueData/TitleContainer/TriggerChanceInput

const OUTPUT_PATH = "res://addons/output/";
const TEXT_BIT_ARCH = preload("res://addons/src/scenes/DialogueTextEntry.tscn");
const SPRITE_BIT_ARCH = preload("res://addons/src/scenes/DialogueSpriteEntry.tscn");
const TRANS_BIT_ARCH = preload("res://addons/src/scenes/DialogueTransitionEntry.tscn");

@onready var encryptToggle = $DialogueCreatorMainWindow/VBoxContainer/EncryptContainer/EncryptionToggle
@onready var encryptKey = $DialogueCreatorMainWindow/VBoxContainer/EncryptContainer/KeyEdit

# Called when the node enters the scene tree for the first time.
func _ready():
	VerifySaveDir();
	dialogueDataScreen.visible = false;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func OnNewDialogue():
	dialogueDataScreen.visible = true;
	pass;

func OnDialogueImport():
	pass;


func VerifySaveDir():
	DirAccess.make_dir_absolute(OUTPUT_PATH);
	pass;

func OnDialogueSave():
	if fileNameInput.text == "":
		printerr("ERROR: A FILENAME MUST BE GIVEN!")
		return;
	
	var dialogueData = {
		"title" : titleInput.text,
		"triggerChance" : int(triggerChanceInput.text),
		"dialogueBits" : []
	}
	
	
	for bit in dialogueBitList.get_children():
		var data ={}
		bit.Save(data);
		dialogueData["dialogueBits"].append(data);

	var jsonData = JSON.stringify(dialogueData, "\t");
	
	var fullPath = OUTPUT_PATH + fileNameInput.text + ".dialogue";

	var file;
	if encryptToggle.is_pressed():
		file = FileAccess.open_encrypted_with_pass(fullPath, FileAccess.WRITE, encryptKey.text);
	else:
		file = FileAccess.open(fullPath, FileAccess.WRITE);
		
	
	file.store_string(jsonData);
	file.close();
	

func AddTextBit():
	var newTextBit = TEXT_BIT_ARCH.instantiate();
	dialogueBitList.add_child(newTextBit);
		
func AddSpriteBit():
	var newSpriteBit = SPRITE_BIT_ARCH.instantiate();
	dialogueBitList.add_child(newSpriteBit);
	
func AddTransitionBit():
	var newTransBit = TRANS_BIT_ARCH.instantiate();
	dialogueBitList.add_child(newTransBit);
	

