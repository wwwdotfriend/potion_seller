extends Node2D

var held_object = null

func _ready() -> void:
	for node in get_tree().get_nodes_in_group("pickable"):
		node.clicked.connect(_on_pickable_clicked)
	for node in get_tree().get_nodes_in_group("inv_slot"):
		node.slot_clicked.connect(slot_clicked)

func slot_clicked(item: IngredientItem) -> void:
	var scene = load(item.scene_path)
	var scene_instance = scene.instantiate()
	scene_instance.add_to_group("pickable")
	scene_instance.global_position = get_global_mouse_position()
	add_child(scene_instance)
	scene_instance.clicked.connect(_on_pickable_clicked)
	_on_pickable_clicked(scene_instance)
	call_deferred("_check_for_drop")
	
func _on_pickable_clicked(object):
	if !held_object:
		object.pickup()
		held_object = object
		
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if held_object and !event.pressed:
			held_object.drop(Input.get_last_mouse_velocity())
			held_object = null
	elif !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and held_object:
		held_object.drop(Input.get_last_mouse_velocity())
		held_object = null
			
func _check_for_drop():
	if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_unhandled_input(InputEventMouseButton.new())
