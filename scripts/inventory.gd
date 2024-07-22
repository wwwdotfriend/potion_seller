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
