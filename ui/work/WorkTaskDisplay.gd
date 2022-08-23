extends VBoxContainer

var task_owner_id
var task_id

@onready var TaskName = find_child('TaskName')
@onready var TaskDescription = find_child('TaskDescription')
@onready var ContributorsContainer = find_child('ContributorsContainer')
@onready var WorkNeededContainer = find_child('WorkNeededContainer')

func set_task(task_owner_id, task_id):
	if task_owner_id != self.task_owner_id or task_id != self.task_id:
		var cur_task = get_task_item()
		if cur_task:
			cur_task.disconnect('contributors_updated', contributors_updated)
		self.task_owner_id = task_owner_id
		self.task_id = task_id
		cur_task = get_task_item()
		if cur_task:
			cur_task.connect('contributors_updated', contributors_updated)
	refresh()

func get_task_owner()->WorkProvidingItem:
	if task_owner_id == null:
		return null
	var task_owner:WorkProvidingItem = IdManager.get_item_by_id(task_owner_id)
	return task_owner

func get_task_item()->WorkTask:
	var task_owner:WorkProvidingItem = get_task_owner()
	if task_owner == null:
		return null
	var task:WorkTask = task_owner.get_work_task(task_id)
	return task

func refresh():
	var task_item:WorkTask = get_task_item()
	if task_item == null:
		visible = false
		return
	visible = true
	TaskName.text = task_item.get_label()
	TaskDescription.text = task_item.get_description()
	ContributorsContainer.refresh(task_item)
	WorkNeededContainer.refresh(task_item)
	
func contributors_updated(task_item):
	ContributorsContainer.refresh(task_item)
	WorkNeededContainer.refresh(task_item)
