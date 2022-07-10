extends GameItemAware

signal rename_item(old_name, new_name)
signal new_folder(folder_name)
signal delete_item(keep_children)

const CMD_RENAME = 1
const CMD_NEW = 2
const CMD_DELETE = 3
