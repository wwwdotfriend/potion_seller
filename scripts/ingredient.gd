extends Node2D

@onready var sprite = $Sprite2D

signal mouse_released
signal picked_up_changed(picked)

var picked_up: bool = false :
	set(b):
		if not b:
			position = Vector2.ZERO
		picked_up = b
		picked_up_changed.emit()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if picked_up:
		global_position = get_global_mouse_position()
	
	if Input.is_action_just_released("M1"):
		mouse_released.emit()

func _on_mouse_region_pressed() -> void:
	picked_up = true
	await mouse_released
	picked_up = false
