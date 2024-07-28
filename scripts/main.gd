extends Node2D

var held_object = null
var current_ingredient: IngredientItem = null
var pestle_in_mortar = false
var pestle_moving = false

@onready var raw_sprite = $Mortar/IngredientMortarSprite
@onready var mortar_timer = $MortarTimer

func _ready() -> void:
	for node in get_tree().get_nodes_in_group("pickable"):
		node.clicked.connect(_on_pickable_clicked)
	for node in get_tree().get_nodes_in_group("inv_slot"):
		node.slot_clicked.connect(slot_clicked)

func slot_clicked(item: IngredientItem) -> void:
	var scene = load(item.scene_path)
	var scene_instance = scene.instantiate()
	scene_instance.set_ingredient_item(item)
	scene_instance.global_position = get_global_mouse_position()
	add_child(scene_instance)
	scene_instance.clicked.connect(_on_pickable_clicked)
	_on_pickable_clicked(scene_instance)
	call_deferred("_check_for_drop")
	
func _on_pickable_clicked(object):
	if !held_object:
		object.pickup()
		held_object = object
	if object.has_method("get_ingredient_item"):
		var ingredient = object.get_ingredient_item()
		print("holding ", ingredient.name)
	else:
		print("holding ", object.name)
		
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if held_object and !event.pressed:
			held_object.drop()
			held_object = null
	elif !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and held_object:
		held_object.drop()
		held_object = null
			
func _check_for_drop():
	if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_unhandled_input(InputEventMouseButton.new())

func _on_panel_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("ingredient"):
		body.queue_free()

func _on_mortar_inside_body_entered(body: Node2D) -> void:
	if body.is_in_group("ingredient"):
		current_ingredient = body.get_ingredient_item()
		var mortar_sprite = current_ingredient.mortar_sprite
		$Mortar/IngredientMortarSprite.texture = mortar_sprite
		if current_ingredient:
			print(current_ingredient.name)
		body.queue_free()
		
func _on_ing_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if current_ingredient and !held_object:
			slot_clicked(current_ingredient)
			current_ingredient = null
			$Mortar/IngredientMortarSprite.texture = null

func on_that_grind() -> void:
	pass # grinding logic will go here
	
func _on_mortar_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("pestle"):
		pestle_in_mortar = true
		print("pestle in mortar")

func _on_mortar_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("pestle"):
		pestle_in_mortar = false
		print("pestle out mortar")

func _on_mortar_timer_timeout() -> void:
	print("timer done")
