extends Node2D

@export var play_area: Rect2 = Rect2(Vector2(-960, -540), Vector2(1920, 1080))
@export var show_bounds_in_editor: bool = true

func get_play_area() -> Rect2:
    return play_area

func _draw() -> void:
    if Engine.is_editor_hint() and show_bounds_in_editor:
        draw_rect(play_area, Color(0.2, 0.7, 1.0, 0.15), false, 2.0)
