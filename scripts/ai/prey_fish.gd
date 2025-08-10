extends CharacterBody2D

@export var swim_speed: float = 240.0
@export var turn_speed: float = 8.0
@export var avoid_radius: float = 160.0
@export var wander_jitter: float = 0.8

var _desired_direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
    randomize()
    _desired_direction = Vector2(randf() * 2.0 - 1.0, randf() * 2.0 - 1.0).normalized()

func _physics_process(delta: float) -> void:
    var avoid := _compute_avoidance()
    var target := (_desired_direction + avoid).normalized()
    # Smoothly steer towards target
    var current_dir := velocity.normalized() if velocity.length() > 0.01 else _desired_direction
    var new_dir := current_dir.lerp(target, clamp(turn_speed * delta, 0.0, 1.0)).normalized()
    velocity = new_dir * swim_speed
    move_and_slide()
    _maybe_change_wander(delta)

func _compute_avoidance() -> Vector2:
    var player := _find_player()
    if player == null:
        return Vector2.ZERO
    var to_player := global_position - player.global_position
    var dist := to_player.length()
    if dist <= 0.001 or dist > avoid_radius:
        return Vector2.ZERO
    var strength := 1.0 - (dist / avoid_radius)
    return to_player.normalized() * strength

func _find_player() -> Node2D:
    # Look for sibling/parent child named Player for simplicity
    var root := get_tree().current_scene
    if root == null:
        return null
    var candidate := root.find_child("Player", true, false)
    return candidate as Node2D

func _maybe_change_wander(delta: float) -> void:
    # Small random jitter to wander
    var jitter := Vector2(randf() - 0.5, randf() - 0.5) * wander_jitter * delta * 10.0
    _desired_direction = (_desired_direction + jitter).normalized()
