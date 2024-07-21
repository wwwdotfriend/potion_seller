extends Control

@export var inv: Inv

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for node in get_tree().get_nodes_in_group("inv_slot"):
		node.clicked.connect(slot_clicked)
		
func slot_clicked():
	print("slot clicked")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
