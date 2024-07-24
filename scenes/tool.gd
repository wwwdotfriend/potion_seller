extends CharacterBody2D

var held = false
const GRAVITY = 900

var grab_offset = Vector2.ZERO

signal clicked

func _physics_process(delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	if held:
		global_transform.origin = get_global_mouse_position() + grab_offset
	else:
		velocity.y += GRAVITY * delta
		move_and_slide()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			print("clicked")
			clicked.emit(self)

func pickup():
	if held:
		return
	held = true
	grab_offset = global_position - get_global_mouse_position()

func drop():
	held = false
