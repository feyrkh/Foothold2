extends Object
class_name Factory

static func place_item(item:GameItem, owner_or_id, highlight:bool=false, deferred:bool=false):
	if !(owner_or_id is TreeItem):
		owner_or_id = IdManager.get_item_by_id(owner_or_id)
	if deferred:
		Events.call_deferred('emit_signal', ['add_game_item', item, owner_or_id, highlight])
	else:
		Events.emit_signal('add_game_item', item, owner_or_id, highlight)

static func place_item_deferred(item:GameItem, owner_or_id, highlight:bool):
	return place_item(item, owner_or_id, highlight, true)

static func area(label:String, owner_or_id, script=null) -> AreaItem:
	if script == null:
		script = "res://items/AreaItem.gd"
	var item = load(script).new()
	item.init(label)
	return item

static func folder(label:String) -> FolderItem:
	return FolderItem.new().init(label)

static func item(label:String, script=null) -> GameItem:
	if script == null:
		script = "res://items/GameItem.gd"
	var item = load(script).new()
	item.init(label)
	return item

static func pc(label:String) -> PcItem:
	return PcItem.new().init(label)

static func work_party(label:String, work_party_type_tag:String, workTypes:Dictionary) -> WorkPartyItem:
	# work_party("Explore", Tags.WORK_PARTY_EXPLORE, {WorkTypes.EXPLORE: 30})
	var item = WorkPartyItem.new().init_work_party(label, work_party_type_tag, workTypes)
	return item
