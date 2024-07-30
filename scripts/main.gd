extends Node2D

var held_object = null
var current_ingredient: IngredientItem = null
var potion: Potion = null

var pestle_in_mortar = true
var spoon_in_cauldron = true

var last_pestle_position: Vector2
var last_spoon_position: Vector2

var mortar_full = false
var cauldron_full = false

var can_brew = false

var current_potion = ""

@onready var sprite = $Mortar/IngredientMortarSprite
@onready var mortar_timer = $MortarTimer
@onready var pestle = $pestle
@onready var spoon = $spoon
@onready var cauldron_timer = $CauldronTimer

var cauldron_ingredients = {}

##### POTION RECIPES START #####
var potion_recipes := {
	"Potion of Healing": {
		"name": "Potion of Healing",
		"recipe": {"bloodroot": 2},
		"base_value": 10,
		"scene_path": "res://scenes/potions/potion_of_health.tscn"
	},
	"Potion of Mana": {
		"name": "Potion of Mana",
		"recipe": {"bloodroot": 1, "moonberry": 1},
		"base_value": 15,
		"scene_path": ""
	}
}
##### POTION RECIPES END #####

func _ready() -> void:
	for node in get_tree().get_nodes_in_group("pickable"):
		node.clicked.connect(_on_pickable_clicked)
	for node in get_tree().get_nodes_in_group("inv_slot"):
		node.slot_clicked.connect(slot_clicked)

func _process(delta: float) -> void:
	grind_time()
	cauldron_time()

func grind_time():
	if current_ingredient and current_ingredient.state == IngredientItem.State.RAW and pestle_in_mortar and held_object and mortar_full:
		if held_object.global_position != last_pestle_position:
			if mortar_timer.is_stopped():
				mortar_timer.start()
				print("timer started")
		last_pestle_position = pestle.global_position
	elif not mortar_timer.is_stopped():
		mortar_timer.stop
		
func cauldron_time():
	if can_brew and spoon_in_cauldron and held_object and held_object.is_in_group("spoon"):
		if held_object.global_position != last_spoon_position:
			if cauldron_timer.is_stopped():
				cauldron_timer.start()
				print("cauldron timer started")
		last_spoon_position = held_object.global_position
	elif not cauldron_timer.is_stopped():
		cauldron_timer.stop
		print("cauldron timer stopped")

func add_to_cauldron(ingredient_name: String) -> void:
	if ingredient_name in cauldron_ingredients:
		cauldron_ingredients[current_ingredient.name] += 1
	else:
		cauldron_ingredients[current_ingredient.name] = 1
	print("Added to cauldron:", current_ingredient.name)
	print("Current cauldron contents:", cauldron_ingredients)

func check_potion_recipe() -> void:
	can_brew = false
	current_potion = ""
	for potion_name in potion_recipes:
		var recipe = potion_recipes[potion_name]["recipe"]
		var recipe_match = true
		for ingredient in recipe:
			if cauldron_ingredients.get(ingredient, 0) != recipe[ingredient]:
				recipe_match = false
				break
		if recipe_match:
			for ingredient in cauldron_ingredients:
				if ingredient not in recipe:
					recipe_match = false
					break
		if recipe_match:
			can_brew = true
			current_potion = potion_name
			print("can brew: ", potion_name)
			return

func slot_clicked(item: IngredientItem) -> void:
	var scene = load(item.raw_scene_path)
	var scene_instance = scene.instantiate()
	scene_instance.set_ingredient_item(item)
	item.state = IngredientItem.State.RAW
	scene_instance.global_position = get_global_mouse_position()
	add_child(scene_instance)
	scene_instance.clicked.connect(_on_pickable_clicked)
	_on_pickable_clicked(scene_instance)
	call_deferred("_check_for_drop")
	
func mortar_clicked(item: IngredientItem) -> void:
	var scene = load(item.crushed_scene_path)
	var scene_instance = scene.instantiate()
	scene_instance.set_ingredient_item(item)
	scene_instance.global_position = get_global_mouse_position()
	add_child(scene_instance)
	scene_instance.clicked.connect(_on_pickable_clicked)
	_on_pickable_clicked(scene_instance)
	call_deferred("_check_for_drop")
	
func cauldron_clicked() -> void:
	if current_potion != "":
		var potion_data = potion_recipes[current_potion]
		var potion_scene = load(potion_data["scene_path"])
		if potion_scene:
			var scene_instance = potion_scene.instantiate()
			scene_instance.global_position = get_global_mouse_position()
			add_child(scene_instance)
			scene_instance.clicked.connect(_on_pickable_clicked)
			_on_pickable_clicked(scene_instance)
			
			current_potion = ""
			cauldron_ingredients.clear()
			can_brew = false
			$Cauldron/IngredientCauldronSprite.texture = null

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
		if current_ingredient:
			if current_ingredient.state == IngredientItem.State.RAW:
				$Mortar/IngredientMortarSprite.texture = current_ingredient.mortar_sprite
			elif current_ingredient.state == IngredientItem.State.CRUSHED:
				$Mortar/IngredientMortarSprite.texture = current_ingredient.crushed_sprite
		body.queue_free()
		mortar_full = true
		
func _on_ing_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if current_ingredient and !held_object:
			if current_ingredient.state == IngredientItem.State.RAW:
				slot_clicked(current_ingredient)
				current_ingredient = null
				$Mortar/IngredientMortarSprite.texture = null
			elif current_ingredient.state == IngredientItem.State.CRUSHED:
				mortar_clicked(current_ingredient)
				current_ingredient = null
				$Mortar/IngredientMortarSprite.texture = null
		mortar_full = false

func _on_cauldron_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if !can_brew and current_potion != "" and !held_object:
			print("cauldron clicked")
			cauldron_clicked()
			$Mortar/IngredientMortarSprite.texture = null

func _on_mortar_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("pestle"):
		pestle_in_mortar = true
		print("pestle in mortar")

func _on_mortar_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("pestle"):
		pestle_in_mortar = false
		print("pestle out mortar")

func _on_mortar_timer_timeout() -> void:
	if current_ingredient:
		current_ingredient.state = IngredientItem.State.CRUSHED
		sprite.texture = current_ingredient.crushed_sprite

func _on_cauldron_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("spoon"):
		spoon_in_cauldron = true
		print("spoon in cauldron")

func _on_cauldron_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("spoon"):
		spoon_in_cauldron = false
		print("spoon out cauldron")

func _on_cauldron_inside_body_entered(body: Node2D) -> void:
	if body.is_in_group("ingredient"):
		current_ingredient = body.get_ingredient_item()
		if current_ingredient:
			if current_ingredient.state == IngredientItem.State.RAW:
				print("its raw")
			elif current_ingredient.state == IngredientItem.State.CRUSHED:
				$Cauldron/IngredientCauldronSprite.texture = current_ingredient.crushed_sprite
				current_ingredient.state = IngredientItem.State.CAULDRON
				add_to_cauldron(current_ingredient.name)
				body.queue_free()
				check_potion_recipe()

func _on_cauldron_timer_timeout() -> void:
	if can_brew and current_potion != "":
		print("Brewed: ", current_potion)
		can_brew = false
