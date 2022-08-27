extends VBoxContainer

signal task_resolved()
signal task_cancelled()

var task_owner_id
var task_id

@onready var TaskName = find_child('TaskName')
@onready var TaskDescription = find_child('TaskDescription')
@onready var Contributors = find_child('Contributors')
@onready var ContributorsContainer = find_child('ContributorsContainer')
@onready var WorkNeededContainer = find_child('WorkNeededContainer')
@onready var WorkCompleteSection = find_child('WorkCompleteSection')

func _ready():
	find_child('CompleteButton').pressed.connect(resolve_task)
	find_child('CancelTaskButton').pressed.connect(cancel_task)

func set_task(task_owner_id, task_id):
	if task_owner_id != self.task_owner_id or task_id != self.task_id:
		var cur_task = get_task_item()
		if cur_task:
			cur_task.contributors_updated.disconnect(contributors_updated)
			cur_task.work_complete.disconnect(work_task_complete)
			cur_task.work_resolved.disconnect(work_task_resolved)
		self.task_owner_id = task_owner_id
		self.task_id = task_id
		cur_task = get_task_item()
		if cur_task:
			if !cur_task or !is_instance_valid(cur_task) or cur_task.is_work_resolved():
				cur_task = null
				self.task_owner_id = null
				self.task_id = null
			else:
				cur_task.contributors_updated.connect(contributors_updated)
				cur_task.work_complete.connect(work_task_complete)
				cur_task.work_resolved.connect(work_task_resolved)
	refresh()

func work_task_resolved(work_task):
	if task_id == work_task.get_id():
		set_task(null, null)
	task_resolved.emit()

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
	if task_item.is_work_complete():
		WorkNeededContainer.visible = false
		WorkCompleteSection.visible = true
		Contributors.visible = false
	else:
		WorkNeededContainer.visible = true
		WorkCompleteSection.visible = false
		Contributors.visible = true
		WorkNeededContainer.refresh(task_item)
		ContributorsContainer.refresh(task_item)

func contributors_updated(task_item):
	ContributorsContainer.refresh(task_item)
	WorkNeededContainer.refresh(task_item)

func work_task_complete(task_item):
	refresh()

func resolve_task():
	var cur_task = get_task_item()
	if cur_task == null:
		push_error('Tried to resolve nonexistent task - the button should not have been visible!') 
		return
	if !cur_task.is_work_complete():
		push_error('Tried to resolve an incomplete task - the button should not have been visible!')
		return
	cur_task.resolve_completion_effects()

func cancel_task():
	task_cancelled.emit()
	
