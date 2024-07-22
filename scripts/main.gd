extends Node2D

var held_object = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for node in get_tree().get_nodes_in_group("pickable"):
		node.clicked.connect(_on_pickable_clicked)
	for node in get_tree().get_nodes_in_group("inv_slot"):
		node.slot_clicked.connect(slot_clicked)

func slot_clicked(item: IngredientItem) -> void:
	print(item.name + " | " + item.scene_path)
	var scene = load(item.scene_path)
	var scene_instance = scene.instantiate()
	scene_instance.add_to_group("pickable")
	scene_instance.set_process_input(true)
	scene_instance.set_process_unhandled_input(true)
	add_child(scene_instance)
	scene_instance.clicked.connect(_on_pickable_clicked)

func _on_pickable_clicked(object):
	if !held_object:
		object.pickup()
		held_object = object
		
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if held_object and !event.pressed:
			held_object.drop(Input.get_last_mouse_velocity())
			held_object = null
