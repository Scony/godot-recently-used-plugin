tool
extends Control

const DATAFILE_PATH = 'user://recently-used.cfg'

onready var _item_list = find_node('ItemList')

var _plugin
var _editor_interface
var _recently_opened_scenes = []
var _scenes_open_last_check = []


func _ready():
	_item_list.clear()
	_plugin = EditorPlugin.new()
	_editor_interface = _plugin.get_editor_interface()
	_load_data_from_file()
	_check_if_new_scenes_have_been_opened()


func _exit_tree():
	_save_data_to_file()
	_plugin.queue_free()


func _input(event):
	if event is InputEventMouseButton and event.doubleclick and _item_list.is_anything_selected():
		var selection_id = _item_list.get_selected_items()[0]
		var selected_scene = _item_list.get_item_text(selection_id)
		_editor_interface.open_scene_from_path(selected_scene)
		_item_list.unselect(selection_id)


func _update_view():
	_item_list.clear()
	for scene in _recently_opened_scenes:
		_item_list.add_item(str(scene))


func _check_if_new_scenes_have_been_opened():
	var open_scenes = _editor_interface.get_open_scenes()
	var view_update_required = false
	for scene in open_scenes:
		if not scene in _scenes_open_last_check:
			_recently_opened_scenes.erase(scene)
			_recently_opened_scenes.insert(0, scene)
			_scenes_open_last_check.append(scene)
			view_update_required = true
	if view_update_required:
		_update_view()


func _load_data_from_file():
	var config = ConfigFile.new()
	var ec = config.load(DATAFILE_PATH)
	if ec == OK:
		_recently_opened_scenes = JSON.parse(config.get_value('data', 'data', '[]')).result


func _save_data_to_file():
	var config = ConfigFile.new()
	config.set_value('data', 'data', JSON.print(_recently_opened_scenes))
	config.save(DATAFILE_PATH)


func _on_timer_timeout():		# TODO: replace polling with signals if possible
	_check_if_new_scenes_have_been_opened()
