extends Node2D

@export var target_path: NodePath = NodePath("..")
@export var size: Vector2 = Vector2(44, 6)
@export var offset: Vector2 = Vector2(0, -56)
@export var bg_color: Color = Color(0, 0, 0, 0.6)
@export var fg_color: Color = Color(0.9, 0.2, 0.1, 0.9)
@export var border_color: Color = Color(1, 1, 1, 0.6)
@export var show_when_full: bool = false

func _process(_delta: float) -> void:
	position = offset
	visible = _should_show()
	queue_redraw()
func _draw() -> void:
	var t := _get_target()
	if t == null:
		return
	var hp: int = _read_hp(t)
	var max_hp: int = _read_max_hp(t)
	if max_hp <= 0:
		return
	var ratio: float = clamp(float(hp) / float(max_hp), 0.0, 1.0)
	var half := size * 0.5
	var top_left := Vector2(-half.x, -half.y)
	draw_rect(Rect2(top_left, size), bg_color, true)
	var fill_w: float = size.x * ratio
	draw_rect(Rect2(top_left, Vector2(fill_w, size.y)), fg_color, true)
	draw_rect(Rect2(top_left, size), border_color, false, 1.0)

func _should_show() -> bool:
	var t := _get_target()
	if t == null:
		return false
	var hp := _read_hp(t)
	var max_hp := _read_max_hp(t)
	if max_hp <= 0:
		return false
	if show_when_full:
		return true
	return hp < max_hp

func _get_target() -> Node:
	return get_node_or_null(target_path)

func _read_hp(t: Node) -> int:
	if "hp" in t:
		return int(t.get("hp"))
	if "_hp" in t:
		return int(t.get("_hp"))
	return 0

func _read_max_hp(t: Node) -> int:
	if "max_hp" in t:
		return int(t.get("max_hp"))
	return 0
