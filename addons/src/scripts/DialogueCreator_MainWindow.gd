@tool
class_name DialogueCreator
extends Control

@onready var dialogueDataScreen = $DialogueCreatorMainWindow/DialogueDataHolder/DialogueData
@onready var dialogueBitList = $DialogueCreatorMainWindow/DialogueDataHolder/DialogueData/DialogueBits/BitScroll/BitList

@onready var titleInput = $DialogueCreatorMainWindow/DialogueDataHolder/DialogueData/TitleContainer/TitleEditText
@onready var fileNameInput = $DialogueCreatorMainWindow/DialogueDataHolder/DialogueData/FilenameContainer/FileNameTextEdit
@onready var triggerChanceInput = $DialogueCreatorMainWindow/DialogueDataHolder/DialogueData/TitleContainer/TriggerChanceInput

const OUTPUT_PATH = "addons/output/";
const ENCRYPTED_OUTPUT_PATH = "addons/output_encrypted/";
const TEXT_BIT_ARCH = preload("res://addons/src/scenes/DialogueTextEntry.tscn");
const SPRITE_BIT_ARCH = preload("res://addons/src/scenes/DialogueSpriteEntry.tscn");
const TRANS_BIT_ARCH = preload("res://addons/src/scenes/DialogueTransitionEntry.tscn");

const FILE_INFO_ARCH = preload("res://addons/src/scenes/FileInfo.tscn");
@onready var fileInfoList = $DialogueCreatorMainWindow/VBoxContainer/SaveHolder/FileScroll/FileList

@onready var encryptToggle = $DialogueCreatorMainWindow/VBoxContainer/EncryptContainer/EncryptionToggle
@onready var encryptKey = $DialogueCreatorMainWindow/VBoxContainer/EncryptContainer/KeyEdit

signal onFileImport(String);

# Called when the node enters the scene tree for the first time.
func _ready():
	dialogueDataScreen.visible = false;
	
	ReadDialogues();
	
	onFileImport.connect(OnDialogueImport);
	pass # Replace with function body.


func ReadDialogues():
	
	for ch in fileInfoList.get_children():
		ch.queue_free();
	
	var dir = DirAccess.open(OUTPUT_PATH);

	if dir:
		dir.list_dir_begin()
		var fileName = dir.get_next()
		while fileName != "":
			if dir.current_is_dir():
				print("Found directory: " + fileName)
				
			else:
				print("Found file: " + fileName);
				
				var FileInfo = FILE_INFO_ARCH.instantiate();
				FileInfo.dialogueCr = self;
				fileInfoList.add_child(FileInfo);
				FileInfo.Init(fileName)
				
			fileName = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func IsDialogueListEmpty():
	return dialogueBitList.get_child_count() == 0;
	
func ClearDialogueList():
	for ch in dialogueBitList.get_children():
		ch.queue_free();


func OnNewDialogue():
	dialogueDataScreen.visible = true;
	pass;


func OnDialogueImport(fileName : String):

	dialogueDataScreen.visible = true;
	
	if IsDialogueListEmpty() == false:
		ClearDialogueList();		
	
	var fullPath = OUTPUT_PATH + fileName;
	var file = FileAccess.open(fullPath, FileAccess.READ);
	
	var parsedData = JSON.parse_string(file.get_as_text());
	file.close()

	#
	#titleInput.text = parsedData["title"];
	#fileNameInput.text = fileName.trim_suffix(".dialogue");
	#triggerChanceInput.text = str(parsedData["triggerChance"]);
	
	var bits = parsedData["dialogueBits"]
	for b in bits:
		
		match b["id"]:
			"TEXT":
				AddTextBit(b);
			"SPRITE":
				AddSpriteBit(b);
			"AUDIO":
				AddAudioBit(b);
			"TRANS":
				AddTransitionBit(b);
		
	return;

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
	

	var file;
	if encryptToggle.is_pressed():
		var fullPath = ENCRYPTED_OUTPUT_PATH + fileNameInput.text + ".dialogue";
		file = FileAccess.open_encrypted_with_pass(fullPath, FileAccess.WRITE, encryptKey.text);
	else:
		var fullPath = OUTPUT_PATH + fileNameInput.text + ".dialogue";
		file = FileAccess.open(fullPath, FileAccess.WRITE);
		
	
	file.store_string(jsonData);
	file.close();
	
	ReadDialogues();
	

func AddTextBit(bitData := {}):
	var newTextBit = TEXT_BIT_ARCH.instantiate();
	dialogueBitList.add_child(newTextBit);
	
	if bitData != {}:
		newTextBit.Load(bitData);
		
func AddSpriteBit(bitData := {}):
	var newSpriteBit = SPRITE_BIT_ARCH.instantiate();
	dialogueBitList.add_child(newSpriteBit);
	
	if bitData != {}:
		newSpriteBit.Load(bitData);
	
func AddTransitionBit(bitData := {}):
	var newTransBit = TRANS_BIT_ARCH.instantiate();
	dialogueBitList.add_child(newTransBit);
	
	if bitData != {}:
		newTransBit.Load(bitData);
	
func AddAudioBit(bitData := {}):
	pass;
