extends Control


func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")



func _on_options_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed():
	get_tree().quit()
