extends Control

@onready var inv: Inv = preload("res://resources/inventory.tres")
@onready var slots: Array = $Inventory.get_children()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_slots()

func update_slots():
	for i in range(min(inv.items.size(), slots.size())):
		slots[i].update(inv.items[i])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_plus_bloodroot_pressed() -> void:
	var found = false
	for item in inv.items:
		if item.name == "bloodroot":
			item.quantity += 1
			found = true
			break
	if not found:
		var new_item = IngredientItem.new()
		new_item.name = "bloodroot"
		new_item.quantity = 1
		inv.items.append(new_item)
	update_slots()
