@tool
class_name DialogueCreator
extends HBoxContainer

@onready var dialogueDataScreen = $Organizer/DialogueCreator
@onready var dialogueTranslationScreen = $Organizer/DialogueTranslator


@onready var fileNameInput = $Organizer/DialogueCreator/DialogueDataHolder/DialogueData/FilenameContainer/FileNameTextEdit
@onready var defaultLocaleInput = $Organizer/DialogueCreator/DialogueDataHolder/DialogueData/FilenameContainer/LocaleInput
@onready var dialogueBitList = $Organizer/DialogueCreator/DialogueDataHolder/DialogueData/BitScroll/BitList
@onready var translationList = $Organizer/DialogueTranslator/Scroll/TranslationHolder

const OUTPUT_PATH = "addons/output/";

const TRANSLATION_HOLDER_ARCH = preload("res://addons/src/scenes/TranslationHolder.tscn")
const ENCRYPTED_OUTPUT_PATH = "addons/output_encrypted/";
const TEXT_BIT_ARCH = preload("res://addons/src/scenes/DialogueTextEntry.tscn");
const SPRITE_BIT_ARCH = preload("res://addons/src/scenes/DialogueSpriteEntry.tscn");
const TRANS_BIT_ARCH = preload("res://addons/src/scenes/DialogueTransitionEntry.tscn");

const FILE_INFO_ARCH = preload("res://addons/src/scenes/FileInfo.tscn");
@onready var fileInfoList = $SideMenu/SaveHolder/FileScroll/FileList

@onready var encryptToggle = $SideMenu/EncryptContainer/EncryptionToggle
@onready var encryptKey = $SideMenu/EncryptContainer/KeyEdit

signal onFileImport(String);

# Called when the node enters the scene tree for the first time.
func _ready():
	SwitchTab(0)
	
	ReadDialogues();
	
	onFileImport.connect(OnDialogueImport);
	pass # Replace with function body.

func SwitchTab(tabIdx):
	dialogueDataScreen.visible = false;
	dialogueTranslationScreen.visible = false;
	match tabIdx:
		0:
			dialogueDataScreen.visible = true;
		1:
			dialogueTranslationScreen.visible = true;
	

func ReadDialogues():
	
	for ch in fileInfoList.get_children():
		ch.queue_free();
	
	var dir = DirAccess.open(OUTPUT_PATH);

	if dir:
		dir.list_dir_begin()
		var fileName = dir.get_next()
		while fileName != "":
			if dir.current_is_dir():
				#print("Found directory: " + fileName)
				continue
				
			else:
				#print("Found file: " + fileName);
				
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

func IsDialogueListEmpty() -> bool:
	return dialogueBitList.get_child_count() == 0;

func IsTranslationListEmpty() -> bool:
	return translationList.get_child_count() == 0;

func ClearDialogueList():
	for ch in dialogueBitList.get_children():
		ch.queue_free();
		
func ClearTranslationList():
	for ch in translationList.get_children():
		ch.queue_free();


func OnNewDialogue():
	dialogueDataScreen.visible = true;
	pass;


func OnDialogueImport(fileName : String):

	dialogueDataScreen.visible = true;
	fileNameInput.text = fileName.trim_suffix(".dialogue");
	
	if IsDialogueListEmpty() == false:
		ClearDialogueList();
		
	if IsTranslationListEmpty() == false:
		ClearTranslationList();
	
	var fullPath = OUTPUT_PATH + fileName;
	var file = FileAccess.open(fullPath, FileAccess.READ);
	
	var parsedData = JSON.parse_string(file.get_as_text());
	file.close()

	var locales = ["en_US"];
	if parsedData.has("locales"):
		locales = parsedData["locales"];		
		for l in locales:
			AddTranslationHolder(l)

	
	var bits = parsedData["dialogueBits"]
	for b in bits:
		
		match b["id"]:
			"TEXT":
				AddTextBit(b);
				if b["speakerName"] is Dictionary:
					for l in locales:
						AddNameToLocale(b["speakerName"][l], l)
				if b["text"] is Dictionary:
					for l in locales:
						AddTextToLocale(b["text"][l], l)
			"SPRITE":
				AddSpriteBit(b);
			"AUDIO":
				AddAudioBit(b);
			"TRANS":
				AddTransitionBit(b);
	

	
	return;

func AddTextToLocale(text : String, locale : String):
	for trHolder : TranslationHolder in translationList.get_children():
		if trHolder.localeInput.text == locale:
			trHolder.AddTextEntry(text)
			return;
	
func AddNameToLocale(text : String, locale : String):
	for trHolder : TranslationHolder in translationList.get_children():
		if trHolder.localeInput.text == locale:
			trHolder.AddNameEntry(text)
			return;

func OnDialogueSave():
	if fileNameInput.text == "":
		printerr("ERROR: A FILENAME MUST BE GIVEN!")
		return;
	
	var dialogueData = {
		"nameKeys" : {},
		"locales" : ["en_US"],
		"dialogueBits" : []
	}
	
	for l : TranslationHolder in translationList.get_children():
		if dialogueData["locales"].has(l.localeInput.text) == false:
			dialogueData["locales"].append(l.localeInput.text)
		
	
	var textBitsCount = 0;
	for bit in dialogueBitList.get_children():
		var data = {
			"text" : {},
			"speakerName" : {}
		}
		
		var isText = bit.Save(data);
		if isText:
			for l : TranslationHolder in translationList.get_children():
				var localeKey = l.localeInput.text;
				data["text"][localeKey] = l.textList.get_child(textBitsCount).text;
		
			
		
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


func AddTranslationHolder(localeKey : String = ""):
	var holder : TranslationHolder = TRANSLATION_HOLDER_ARCH.instantiate();
	translationList.add_child(holder)
	holder.localeInput.text = localeKey;
	return
