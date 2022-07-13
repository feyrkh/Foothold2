extends GameItemActions

var game_ui
var folder_item

func _init(game_ui:GameUI, folder_item:FolderItem):
	self.game_ui = game_ui
	self.folder_item = folder_item

func _ready():
	find_child('ItemManageDropdown').setup_dropdown(game_ui, folder_item)
