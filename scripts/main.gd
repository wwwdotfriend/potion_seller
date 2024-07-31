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
@onready var potion_sprite = $CustomerBox/PotionSprite
@onready var recipe_menu = $RecipeMenu

var cauldron_ingredients = {}

var customer_orders = []
var current_order_index = 0

var current_potion_in_area := ""

@onready var order_label: Label = $CustomerBox/OrderLabel
@onready var sell_label: Label = $CustomerBox/SellConfirmation/SellLabel
@onready var sell_confirmation: Control = $CustomerBox/SellConfirmation
@onready var gold_label: Label = $GoldPieces/GoldLabel

var wrong_order = false

var player_gold = 0

var current_day := 1
var customers_per_day := 0
var customers_served := 0

var customer_scene_paths = []
var current_customers = []
var customer_order_position = Vector2(-175, 25)  # Main position under the box
var customer_spacing = Vector2(400, 0)  # 32px spacing between customers
var customer_offscreen_right = Vector2(300, 25)  # Position off-screen to the right

##### POTION RECIPES START #####
var potion_recipes := {
	"Potion of Health": {
		"name": "Potion of Health",
		"recipe": {"bloodroot": 2},
		"description": "Boosts physical health and energy.",
		"base_value": 10,
		"scene_path": "res://scenes/potions/potion_of_health.tscn",
		"sprite_path": "res://assets/art/potions/Potion_of_Healing.png",
		"phrases": [
			"I need a potion to heal my broken arm!",
			"My tummy hurts, please help!",
			"I've got a nasty cut, got anything for that?",
			"I'm feeling a bit under the weather, what can you give me?"
		]
	},
	"Potion of Mana": {
		"name": "Potion of Mana",
		"recipe": {"bloodroot": 1, "moonberry": 1},
		"description": "",
		"base_value": 15,
		"scene_path": "res://scenes/potions/potion_of_mana.tscn",
		"sprite_path": "res://assets/art/potions/PotionofMana.png",
		"phrases": [
			"My magic is depleted, I need a recharge!",
			"Got anything to boost my spells?",
			"I'm all outta juice, help!"
		]
	},
	"Potion of Strength": {
		"name": "Potion of Strength",
		"recipe": {"bloodroot": 2, "suns_grace": 1},
		"description": "",
		"base_value": 20,
		"scene_path": "res://scenes/potions/potion_of_strength.tscn",
		"sprite_path": "res://assets/art/potions/PotionofStrength.png",
		"phrases": [
			"Nasty cave-in up the path, could use some extra help...",
			"I'm feeling weak, can you help me bulk up?",
			"I've got a pit fight coming up, what've you got?"
		]
	},
	"Potion of Night Vision": {
		"name": "Potion of Night Vision",
		"recipe": {"shadowcap": 1, "moonberry": 1},
		"description": "Allows the drinker to see in the dark.",
		"base_value": 25,
		"scene_path": "res://scenes/potions/potion_of_nightvision.tscn",
		"sprite_path": "res://assets/art/potions/PotionofNightVision.png",
		"phrases": [
			"I'm going spelunking, need something to see in the dark.",
			"I'm afraid of the dark.",
			"I'm on watch tonight, what can you give me?",
			"Got anything to help me navigate at night?"
		]
	},
	"Potion of Stealth": {
		"name": "Potion of Stealth",
		"recipe": {"shadowcap": 1, "emerald_algae": 1},
		"description": "Makes the drinker harder to detect.",
		"base_value": 30,
		"scene_path": "res://scenes/potions/potion_of_stealth.tscn",
		"sprite_path": "res://assets/art/potions/PotionofStealth.png",
		"phrases": [
			"I need to sneak past some critters, got anything for that?",
			"The hide-and-seek championships are coming up, what can help me win?"
		]
	},
	"Potion of Poison": {
		"name": "Potion of Poison",
		"recipe": {"shadowcap": 2, "emerald_algae": 1},
		"description": "A toxic brew that causes damage over time.",
		"base_value": 40,
		"scene_path": "res://scenes/potions/potion_of_poison.tscn",
		"sprite_path": "res://assets/art/potions/PotionofPoison.png",
		"phrases": [
			"I need something to... uh... get rid of pests. Yeah, pests.",
			"Got anything that could make someone... sick?",
			"I'm studying toxic substances, what's your strongest brew?"
		]
	},
	"Potion of Shadows": {
		"name": "Potion of Shadows",
		"recipe": {"shadowcap": 3},
		"description": "Grants the ability to blend into shadows, becoming nearly invisible.",
		"base_value": 50,
		"scene_path": "res://scenes/potions/potion_of_shadows.tscn",
		"sprite_path": "res://assets/art/potions/PotionofShadows.png",
		"phrases": [
			"I need to... disappear for a while. Got anything for that?",
			"I need something a bit stronger than a normal invisibility potion...",
			"I've got a job tonight. Need something to blend in, if you catch my drift."
		]
	}
}
##### POTION RECIPES END #####

func _ready() -> void:
	for node in get_tree().get_nodes_in_group("pickable"):
		node.clicked.connect(_on_pickable_clicked)
	for node in get_tree().get_nodes_in_group("inv_slot"):
		node.slot_clicked.connect(slot_clicked)
		
	start_new_day()
	sell_confirmation.hide()
	recipe_menu.hide()
	update_gold_display()
	load_customer_scenes()

func _process(delta: float) -> void:
	grind_time()
	cauldron_time()
	check_for_scripted_events()

func slot_clicked(item: IngredientItem) -> void:
	if item.quantity > 0:
		var scene = load(item.raw_scene_path)
		var scene_instance = scene.instantiate()
		scene_instance.set_ingredient_item(item)
		item.state = IngredientItem.State.RAW
		scene_instance.global_position = get_global_mouse_position()
		add_child(scene_instance)
		scene_instance.clicked.connect(_on_pickable_clicked)
		_on_pickable_clicked(scene_instance)
		call_deferred("_check_for_drop")

		item.quantity -= 1
		$hud.update_slots()
	else:
		print("cannot spawn")
	
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

##### MORTAR #####
func mortar_clicked(item: IngredientItem) -> void:
	var scene = load(item.crushed_scene_path)
	var scene_instance = scene.instantiate()
	scene_instance.set_ingredient_item(item)
	scene_instance.global_position = get_global_mouse_position()
	add_child(scene_instance)
	scene_instance.clicked.connect(_on_pickable_clicked)
	_on_pickable_clicked(scene_instance)
	call_deferred("_check_for_drop")

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


##### CAULDRON #####
func add_to_cauldron(ingredient_name: String) -> void:
	if ingredient_name in cauldron_ingredients:
		cauldron_ingredients[current_ingredient.name] += 1
	else:
		cauldron_ingredients[current_ingredient.name] = 1
	print("Added to cauldron:", current_ingredient.name)
	print("Current cauldron contents:", cauldron_ingredients)

func cauldron_clicked() -> void:
	if current_potion != "":
		var potion_data = potion_recipes[current_potion]
		var potion_scene = load(potion_data["scene_path"])
		if potion_scene:
			var scene_instance = potion_scene.instantiate()
			scene_instance.global_position = get_global_mouse_position()
			
			var new_potion = Potion.new()
			new_potion.name = current_potion
			scene_instance.set_potion(new_potion)
			
			add_child(scene_instance)
			scene_instance.clicked.connect(_on_pickable_clicked)
			_on_pickable_clicked(scene_instance)
			
			current_potion = ""
			cauldron_ingredients.clear()
			can_brew = false
			$Cauldron/IngredientCauldronSprite.texture = null

func _on_cauldron_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if !can_brew and current_potion != "" and !held_object:
			print("cauldron clicked")
			cauldron_clicked()
			$Mortar/IngredientMortarSprite.texture = null

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

##### CUSTOMER #####
func _on_customer_potion_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("potion") and current_order_index < customer_orders.size():
		var potion = body.get_potion()
		if potion:
			current_potion_in_area = potion.name
			var sprite_path = potion_recipes[current_potion_in_area]["sprite_path"]
			potion_sprite.texture = load(sprite_path) if sprite_path else null
			body.queue_free()
			order_label.hide()
			sell_confirmation.show()
			sell_label.text = "Sell this potion?"
		else:
			print("potion object is null")

func generate_customer_orders(num_orders: int) -> void:
	customer_orders.clear()
	current_order_index = 0
	var available_potions = potion_recipes.keys()

	for customer in current_customers:
		customer.queue_free()
	current_customers.clear()
	
	if not customer_scene_paths.is_empty() and not available_potions.is_empty():
		for i in range(num_orders):
			var random_potion = available_potions[randi() % available_potions.size()]
			customer_orders.append(random_potion)

			var random_customer_scene = load(customer_scene_paths[randi() % customer_scene_paths.size()])
			var customer_instance = random_customer_scene.instantiate()
			add_child(customer_instance)

			customer_instance.position = customer_offscreen_right + customer_spacing * i
			current_customers.append(customer_instance)

	animate_customer_queue()
	display_current_order()

func animate_customer_queue() -> void:
	var tween = create_tween()
	for i in range(current_customers.size()):
		var customer = current_customers[i]
		var target_position = customer_order_position + customer_spacing * i
		tween.parallel().tween_property(customer, "position", target_position, 0.5)

func load_customer_scenes() -> void:
	var dir = DirAccess.open("res://scenes/customers/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tscn"):
				customer_scene_paths.append("res://scenes/customers/" + file_name)
			file_name = dir.get_next()
	else:
		print("error trying to access customers")

func display_current_order() -> void:
	if current_order_index < customer_orders.size():
		var current_order = customer_orders[current_order_index]
		var phrases = potion_recipes[current_order]["phrases"]
		var random_phrase = phrases[randi() % phrases.size()]
		order_label.text = random_phrase
	else:
		order_label.text = "All orders complete for today!"
	potion_sprite.texture = load("res://assets/art/potions/EmptyBottle.png")
	
func next_order() -> void:
	current_order_index += 1
	customers_served += 1

	# Move customers
	if not current_customers.is_empty():
		var tween = create_tween()

		# Move the first customer off-screen
		var first_customer = current_customers[0]
		tween.tween_property(first_customer, "position", customer_offscreen_right, 0.5)
		tween.tween_callback(first_customer.queue_free)

		# Move the remaining customers
		for i in range(1, current_customers.size()):
			var customer = current_customers[i]
			var target_position = customer_order_position + customer_spacing * (i - 1)
			tween.parallel().tween_property(customer, "position", target_position, 0.5)

		# Remove the first customer from the array
		current_customers.pop_front()

	if customers_served >= customers_per_day:
		end_day()
	else:    
		display_current_order()
	wrong_order = false

func start_new_day() -> void:
	customers_per_day = randi_range(3, 6)
	customers_served = 0
	if customer_scene_paths.is_empty():
		load_customer_scenes()
	generate_customer_orders(customers_per_day)
	update_day_display()

func end_day() -> void:
	current_day += 1
	print("Day ", current_day - 1, " completed!")
	start_new_day()

func update_day_display() -> void:
	$DayLabel.text = "Day " + str(current_day)
	
func update_gold_display():
	gold_label.text = str(player_gold)

func _on_sell_yes_pressed() -> void:
	var current_order = customer_orders[current_order_index]
	if current_potion_in_area == current_order:
		var potion_value = potion_recipes[current_order]["base_value"]
		player_gold += potion_value
		update_gold_display()
		next_order()
		sell_confirmation.hide()
		order_label.show()
		wrong_order = false
	else:
		sell_confirmation.hide()
		order_label.show()
		order_label.text = "This isn't what I wanted... (click to continue)"
		wrong_order = true

	potion_sprite.texture = load("res://assets/art/potions/EmptyBottle.png")
	current_potion_in_area = ""

func _on_sell_no_pressed() -> void:
	sell_confirmation.hide()
	order_label.show()
	potion_sprite.texture = load("res://assets/art/potions/EmptyBottle.png")
	if current_potion_in_area in potion_recipes:
		var potion_scene = load(potion_recipes[current_potion_in_area]["scene_path"])
		if potion_scene:
			var new_potion = potion_scene.instantiate()
			new_potion.position = Vector2(-100, 0)
			var potion_data = Potion.new()
			potion_data.name = current_potion_in_area
			new_potion.set_potion(potion_data)
			add_child(new_potion)
			new_potion.clicked.connect(_on_pickable_clicked)
	current_potion_in_area = ""

func _on_customer_box_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if wrong_order:
			next_order()
			wrong_order = false

func _on_recipe_menu_button_pressed() -> void:
	recipe_menu.visible = !recipe_menu.visible

func check_for_scripted_events() -> void:
	pass
	#match current_day:
		#3:
			#trigger_day_three_event()
