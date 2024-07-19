extends Sprite2D



var amt: float = 0.0
var n: float = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	n += delta
	amt *= decay
	
	if Input.is_action_just_pressed("M1"):
		amt = 1.0
		
