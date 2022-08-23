extends HBoxContainer

func setup(contributor:GameItem):
	if contributor == null or !is_instance_valid(contributor):
		push_error('Tried to create ContributorsEntry from a null or deleted contributor')
		return
	label_updated(contributor.get_label())
	contributor.label_updated.connect(label_updated)
	work_task_pause_updated(contributor.active_work_task_paused)
	contributor.active_work_task_paused_updated.connect(work_task_pause_updated)
	$ResumeButton.connect('pressed', set_paused.bind(contributor, false))
	$PauseButton.connect('pressed', set_paused.bind(contributor, true))

func label_updated(new_label):
	$Label.text = new_label

func work_task_pause_updated(paused):
	$ResumeButton.visible = paused
	$PauseButton.visible = !paused

func set_paused(contributor, paused):
	contributor.active_work_task_paused = paused
