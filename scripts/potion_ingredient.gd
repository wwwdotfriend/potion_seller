extends RigidBody2D

signal clicked
signal pestled

var held = false
var grab_offset = Vector2.ZERO

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			clicked.emit(self)
			
func _physics_process(delta):
	if held:
		global_transform.origin = get_global_mouse_position() + grab_offset

func pickup():
	if held:
		return
	freeze = true
	held = true
	grab_offset = global_position - get_global_mouse_position()

func drop(impulse=Vector2.ZERO):
	if held:
		freeze = false
		apply_central_impulse(impulse)
		held = false 
