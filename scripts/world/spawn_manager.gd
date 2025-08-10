extends Node

@export var prey_scene: PackedScene
@export var max_prey_count: int = 24
@export var spawn_interval_seconds: float = 1.0
@export var min_spawn_distance: float = 800.0
@export var max_spawn_distance: float = 1400.0

var _time_since_last_spawn: float = 0.0

func _process(delta: float) -> void:
    _time_since_last_spawn += delta
    if _time_since_last_spawn < spawn_interval_seconds:
        return
    _time_since_last_spawn = 0.0
    _try_spawn_prey()

func _try_spawn_prey() -> void:
    if prey_scene == null:
        return
    if _current_prey_count() >= max_prey_count:
        return
    var player: Node2D = _find_player()
    if player == null:
        return
    var parent_2d: Node2D = get_parent() as Node2D
    if parent_2d == null:
        return
    var pos: Vector2 = _random_point_in_ring(player.global_position, min_spawn_distance, max_spawn_distance)
    var prey: Node2D = prey_scene.instantiate() as Node2D
    parent_2d.add_child(prey)
    prey.global_position = pos

func _current_prey_count() -> int:
    var count := 0
    for child in get_parent().get_children():
        if child is CharacterBody2D and child.name.begins_with("PreyFish"):
            count += 1
    return count

func _random_point_in_ring(center: Vector2, min_r: float, max_r: float) -> Vector2:
    var angle: float = randf() * TAU
    var r: float = lerp(min_r, max_r, randf())
    return center + Vector2(cos(angle), sin(angle)) * r

func _find_player() -> Node2D:
    var root := get_tree().current_scene
    if root == null:
        return null
    return root.find_child("Player", true, false) as Node2D
