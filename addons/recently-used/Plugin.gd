tool
extends EditorPlugin

var _dock


func _enter_tree():
    _dock = preload("Dock.tscn").instance()
    add_control_to_dock(DOCK_SLOT_LEFT_BR, _dock)


func _exit_tree():
    remove_control_from_docks(_dock)
    _dock.queue_free()
