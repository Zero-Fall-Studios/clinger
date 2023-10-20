extends CanvasLayer

func _ready():
	hide()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		set_visible(!get_tree().paused)
		get_tree().paused = !get_tree().paused

func _on_button_pressed():
	get_tree().quit()
