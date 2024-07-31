extends CharacterBody2D

signal clicked

var held = false
const GRAVITY = 900
const FOLLOW_SPEED = 80.0  # Adjust this value to change how quickly it follows the cursor

var grab_offset = Vector2.ZERO
@onready var hit_sound = $HitSounds
var sound_played = false

func _physics_process(delta: float) -> void:
	if held:
		var target_position = get_global_mouse_position() + grab_offset
		var direction = (target_position - global_position).normalized()
		var distance = global_position.distance_to(target_position)
		
		velocity = direction * min(FOLLOW_SPEED * distance, FOLLOW_SPEED * 50)
		
		var collision = move_and_collide(velocity * delta)
		if collision:
			if not sound_played:
				$HitSounds.play()
				sound_played = true
			var slide_vector = collision.get_remainder().slide(collision.get_normal())
			move_and_collide(slide_vector)
		else:
			sound_played = false
	else:
		velocity.y += GRAVITY * delta
		move_and_slide()
		sound_played = false

func pickup():
	if held:
		return
	held = true
	grab_offset = global_position - get_global_mouse_position()

func drop():
	held = false
	velocity = Vector2.ZERO

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			clicked.emit(self)
