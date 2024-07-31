extends Control

@export var inv: Inv

func add_item(item: IngredientItem) -> void:
	var found = false
	for inv_item in inv.items:
		if inv_item.name == item.name:
			inv_item.quantity += item.quantity
			found = true
			break
	if not found:
		inv.items.append(item)
	$Inventory.update_slots()
