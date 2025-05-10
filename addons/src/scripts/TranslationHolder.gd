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
	# Check for possible duplicate insertions
	for n in nameList.get_children():
		if n.text == data:
			return;	
	
	var nameEntry = LineEdit.new();
	nameList.add_child(nameEntry)
	nameEntry.custom_minimum_size = Vector2(250, 50)
	
	if localeInput.text == "en_US":
		nameEntry.editable = false;
		
	if data:
		nameEntry.text = data;
	
func AddTextEntry(data : String):
	var textEntry = TextEdit.new();
	textList.add_child(textEntry);
	textEntry.custom_minimum_size = Vector2(250, 200)
	textEntry.autowrap_mode = 2;
	textEntry.wrap_mode = 1;
	
	if localeInput.text == "en_US":
		textEntry.editable = false;
	
	if data:
		textEntry.text = data;
	
