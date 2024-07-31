extends Panel

signal slot_clicked(item: IngredientItem)

@onready var item_visual: Sprite2D = $item_display
@onready var quantity_label: Label = $IngredientAmount
var current_item: IngredientItem = null

func update(item: IngredientItem) -> void:
	current_item = item
	if !item:
		item_visual.visible = false
		# quantity_label.visible = false
	else:
		item_visual.visible = true
		item_visual.texture = item.texture
		# quantity_label.visible = true
		# quantity_label.text = str(item.quantity)

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("M1"):
		slot_clicked.emit(current_item)
