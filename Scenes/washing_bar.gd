extends Control
class_name WashingBar

@onready var texture_progress_bar: TextureProgressBar = %TextureProgressBar

func washingBarProgress(time: float) -> void:
	var tween := create_tween()
	tween.tween_property(texture_progress_bar, "value", 1.0, time)
	
func reset_bar() -> void:
	texture_progress_bar.value = 0
