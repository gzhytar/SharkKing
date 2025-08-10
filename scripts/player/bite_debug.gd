extends Node2D

@export var target_shape_path: NodePath = NodePath("../BiteShape")
@export var enabled: bool = false
@export var fill_color: Color = Color(1, 0, 0, 0.2)
@export var outline_color: Color = Color(1, 0, 0, 0.8)
@export var outline_width: float = 2.0
@export var arc_points: int = 48

func _process(_delta: float) -> void:
	visible = enabled
	_sync_to_shape()
	queue_redraw()

func _sync_to_shape() -> void:
	var shape_node := get_node_or_null(target_shape_path) as CollisionShape2D
	if shape_node == null:
		return
	position = shape_node.position

func _draw() -> void:
	if not enabled:
		return
	var shape_node := get_node_or_null(target_shape_path) as CollisionShape2D
	if shape_node == null or shape_node.shape == null:
		return
	if shape_node.shape is CircleShape2D:
		var r := (shape_node.shape as CircleShape2D).radius
		if r <= 0.0:
			return
		draw_circle(Vector2.ZERO, r, fill_color)
		draw_arc(Vector2.ZERO, r, 0.0, TAU, arc_points, outline_color, outline_width, false)
	elif shape_node.shape is RectangleShape2D:
		var s := (shape_node.shape as RectangleShape2D).size
		var rect := Rect2(Vector2(-s.x * 0.5, -s.y * 0.5), s)
		draw_rect(rect, fill_color, true)
		draw_rect(rect, outline_color, false, outline_width)
