extends CharacterBody2D

var held = false

signal clicked

func _physics_process(delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			print("clicked")
			clicked.emit(self)
