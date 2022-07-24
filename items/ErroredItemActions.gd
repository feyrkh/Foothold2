extends GameItemActions

func init_error(path):
	$ErrorMsg.text = "Invalid action panel path: %s" % [path]
