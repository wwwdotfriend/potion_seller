extends Sprite2D

@onready var hover_overlay = $ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hover_overlay.color = Color(1, 1, 1, 0.5)
	hover_overlay.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_hover_mouse_entered() -> void:
	print("entered")
	hover_overlay.show()

func _on_hover_mouse_exited() -> void:
	print("exit")
	hover_overlay.hide()
