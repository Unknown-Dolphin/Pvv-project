extends Node2D

@onready var pausetile = $pausetile
@onready var darkscreen = $darkscreen

func _ready():
	pausetile.modulate -= Color(0.5, 0.5, 0.5, 0)

func _input(event):
	if global.you_lost:
		return
	if event is InputEventKey and event.keycode == 4194305 and !event.pressed and get_tree().paused:
		get_parent().get_node("pausetext").visible = false
		get_tree().paused = false
		darkscreen.visible = false
		pausetile.modulate -= Color(0.5, 0.5, 0.5, 0)
	elif event is InputEventKey and event.keycode == 4194305 and !event.pressed and !get_tree().paused:
		get_parent().get_node("pausetext").visible = true
		get_tree().paused = true
		darkscreen.visible = true
		pausetile.modulate += Color(0.5, 0.5, 0.5, 0)

func _on_button_pause_button_up():
	if global.you_lost:
		return
	if get_tree().paused:
		get_parent().get_node("pausetext").visible = false
		get_tree().paused = false
		darkscreen.visible = false
		pausetile.modulate -= Color(0.5, 0.5, 0.5, 0)
	else:
		get_parent().get_node("pausetext").visible = true
		get_tree().paused = true
		darkscreen.visible = true
		pausetile.modulate += Color(0.5, 0.5, 0.5, 0)
