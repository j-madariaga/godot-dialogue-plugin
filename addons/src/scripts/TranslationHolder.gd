class_name TranslationHolder
extends VBoxContainer

@onready var localeInput = $LocaleKey/KeyEdit

@onready var nameList = $TransTypes/Scroll/NameKeys
@onready var textList = $TransTypes/Scroll2/TextKeys

func Save() -> Dictionary:
	return {};
	
func Load(data := {}, locale : String = "en_US"):
	return

func AddNameEntry(data : String):
	var nameEntry = LineEdit.new();
	nameList.add_child(nameEntry)
	
	if data:
		nameEntry.text = data;
	
func AddTextEntry(data : String):
	var textEntry = TextEdit.new();
	textList.add_child(textEntry);
	
	if data:
		textEntry.text = data;
