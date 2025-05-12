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
@onready var tabs = $Organizer/TabBar

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
	tabs.current_tab = tabIdx;
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
		ch.free();
		
func ClearTranslationList():
	for ch in translationList.get_children():
		ch.free();


func OnNewDialogue():
	dialogueDataScreen.visible = true;
	pass;


func OnDialogueImport(fileName : String):

	# Avoid reloading loaded file
	fileNameInput.text = fileName.trim_suffix(".dialogue");
	if fileName == fileNameInput.text:
		return;
	
	if IsDialogueListEmpty() == false:
		ClearDialogueList();
		
	while IsTranslationListEmpty() == false:
		ClearTranslationList();
	
	var fullPath = OUTPUT_PATH + fileName;
	var file = FileAccess.open(fullPath, FileAccess.READ);
	
	var parsedData = JSON.parse_string(file.get_as_text());
	file.close()

	var locales = ["en_US"];
	if parsedData.has("locales"):
		locales = parsedData["locales"];
		print("Locales in file: ", locales.size())
		for l in locales:
			AddTranslationHolder(l)

	print("Translations: ", translationList.get_child_count())
	
	var bits = parsedData["dialogueBits"]
	for b in bits:
		
		match b["id"]:
			"TEXT":
				AddTextBit(b);
						
				if b["text"] is Dictionary:
					for l in locales:
						AddTextToLocale(b["text"][l], l)
			"SPRITE":
				AddSpriteBit(b);
			"AUDIO":
				AddAudioBit(b);
			"TRANS":
				AddTransitionBit(b);
				
	if parsedData.has("nameKeys"):
		for n in parsedData["nameKeys"]:
			for l in locales:
				if parsedData["nameKeys"][n].has(l) == false:
					AddNameToLocale("", l)
				else:
					AddNameToLocale(parsedData["nameKeys"][n][l], l)	
					
	for l : TranslationHolder in translationList.get_children():
		print(l.nameList.get_child_count())
	
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
			"speakerName" : ""
		}
		
		var isText = bit.Save(data);
		if isText:			
			for l : TranslationHolder in translationList.get_children():
				var localeKey = l.localeInput.text;
				data["text"][localeKey] = l.textList.get_child(textBitsCount).text;
				
				if data["speakerName"] != "":				
					dialogueData["nameKeys"][data["speakerName"]] = {}
					dialogueData["nameKeys"][data["speakerName"]]["en_US"] = data["speakerName"]
				
			textBitsCount += 1;
	
		
		dialogueData["dialogueBits"].append(data);
	
	for key in dialogueData["nameKeys"]:
		var firstTrans = translationList.get_child(0)
		var searchID = firstTrans.GetChildIDByName(key)
		
		for l : TranslationHolder in translationList.get_children():
			var locale = l.localeInput.text

			var translatedName = l.GetNameByChildID(searchID);
			
			if translatedName != "":
				dialogueData["nameKeys"][key][locale] = translatedName;
		
		
	#for l : TranslationHolder in translationList.get_children():
		#if l.localeInput.text == "en_US":
			#continue;
		#
		#var localeKey = l.localeInput.text;
		#for n in l.nameList.get_children():
			#if n.placeholder_text == "KEEP_NAME" and n.text == "":
				#continue;
			


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
	SwitchTab(0)
	

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


func OnNewTranslation():
	if translationList.get_child_count() == 0:
		AddTranslationHolder();
	
	var firstHolder : TranslationHolder = translationList.get_child(0);
	CloneEmptyTranslationHolder(firstHolder.nameList.get_child_count(), firstHolder.textList.get_child_count())
	
	return;

func AddTranslationHolder(localeKey : String = "") -> TranslationHolder:
	var holder : TranslationHolder = TRANSLATION_HOLDER_ARCH.instantiate();
	translationList.add_child(holder)
	holder.localeInput.text = localeKey;
	return holder;
	
func CloneEmptyTranslationHolder(nameCount : int, textCount : int):
	var holder = AddTranslationHolder();
	
	for n in nameCount:
		holder.AddNameEntry("");
		
	for t in textCount:
		holder.AddTextEntry("");

func RefreshFromCreationTab():
	
	var firstTransTab : TranslationHolder = translationList.get_child(0);
	for text in firstTransTab.textList.get_children():
		text.queue_free()
	
	for entry in dialogueBitList.get_children():
		if entry is TextEntryObj:
			firstTransTab.AddTextEntry(entry.textSquare.text)
			firstTransTab.AddNameEntry(entry.speaker.text)
		else:
			continue;
	return;
