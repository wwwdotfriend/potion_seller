extends Panel

signal slot_clicked

@onready var item_visual: Sprite2D = $item_display

func update(item: IngredientItem):
	if !item:
		item_visual.visible = false
	else:
		item_visual.visible = true
		item_visual.texture = item.texture


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("M1"):
		slot_clicked.emit()
	
