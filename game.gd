extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	Dialogic.signal_event.connect(DialogicSignal)
	Dialogic.start("ellastart")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func DialogicSignal(argument: String):
	if argument == "its a signal":
		print("A signal was fired by Dialogic!")
