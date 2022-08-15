extends Section

# Use like this:
# const ACTION_SECTIONS = ['Description', ['FlexibleButton', 
#	{'button':'My Fancy Button', 'text':'This button does stuff.', 'visible': 'visible_callback', 'click': 'click_callback'}]]
# button: text to put on the button
# text: text to put on the label beside the button
# visible: if provided, will call this function in the game_item to see if this section should be visible or not. 
#		   Checked on setup, refresh() and after clicks are resolved
# click: will call this function in the game_item when the button is clicked

var visible_callback:String
var click_callback:String

func setup_section(args):
	if !(args is Dictionary):
		push_error('Invalid args for FlexibleButtonSection, expected dict but got: ', args)
		return
	var button = find_child('Button')
	var label = find_child('Label')
	button.text = args.get('button', '(unknown button)')
	label.text = args.get('text', '')
	visible_callback = args.get('visible', null)
	click_callback = args.get('click', null)
	update_visibility()
	button.pressed.connect(on_click)

func on_click():
	if click_callback==null or !get_game_item().has_method(click_callback):
		push_error('GameItem ', get_game_item().get_label(), ' does not have flexible button click callback: ', click_callback)
	else:
		get_game_item().call(click_callback)

func refresh():
	update_visibility()

func update_visibility():
	if visible_callback != null:
		visible = get_game_item().call(visible_callback)
