extends Object
class_name Factory

static func place_item(item:GameItem, owner_or_id, highlight:bool=false, deferred:bool=false):
	if !(owner_or_id is TreeNode):
		owner_or_id = IdManager.get_item_by_id(owner_or_id)
	if deferred:
		Events.call_deferred('emit_signal', ['add_game_item', item, owner_or_id, highlight])
	else:
		Events.emit_signal('add_game_item', item, owner_or_id, highlight)

static func place_item_deferred(item:GameItem, owner_or_id, highlight:bool):
	return place_item(item, owner_or_id, highlight, true)

static func area(label:String, script=null) -> AreaItem:
	if script == null:
		script = "res://items/AreaItem.gd"
	var item = load(script).new()
	item.init(label)
	return item

static func folder(label:String) -> FolderItem:
	return FolderItem.new().init(label)

static func goal(script:String, label=null) -> GameItem:
	var item = load(script).new()
	if label == null:
		label = item.get_default_label()
	item.init(label)
	if item.has_method('init_goal'):
		item.init_goal()
	Events.emit_signal('add_goal', item)
	return item

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
