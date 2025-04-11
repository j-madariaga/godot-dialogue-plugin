extends HBoxContainer

@onready var nameLabel = $FileName
var internalFileName : String;
var dialogueCr : DialogueCreator;

func Init(fn : String):
	internalFileName = fn;
	nameLabel.text = fn.trim_suffix(".dialogue");
	return;
	
func OnImportPress():
	dialogueCr.onFileImport.emit(internalFileName);
