extends Control

@onready var credits: Panel = get_node("Credits")

func _ready():
	pass

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://game.tscn")

func _on_credits_button_pressed():
	credits.visible = true

func _on_exit_button_pressed():
	get_tree().quit()

func _on_hide_credits_button_pressed():
	credits.visible = false
