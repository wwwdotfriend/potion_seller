extends RigidBody2D

signal clicked

var held = false

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			clicked.emit(self)
			rotation_degrees = 0
			
func _physics_process(delta):
	if held:
		global_transform.origin = get_global_mouse_position()

func pickup():
	if held:
		return
	freeze = false
	held =  true

func drop(impulse=Vector2.ZERO):
	if held:
		freeze = false
		apply_central_impulse(impulse)
		held = false 
