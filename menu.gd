extends Control

func _on_play_pressed():
	$PlayAudio.play()

func _on_options_pressed():
	get_tree().change_scene_to_file("res://scripts/options_menu.tscn")


func _on_quit_pressed():
	get_tree().quit()


func _on_play_audio_finished() -> void:
	$MenuAudio.stop()
	get_tree().change_scene_to_file("res://scenes/main.tscn")
