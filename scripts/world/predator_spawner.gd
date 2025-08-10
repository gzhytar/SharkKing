extends Node

@export var predator_scene: PackedScene
@export var predator_scenes: Array[PackedScene]
@export var max_predator_count: int = 6
@export var spawn_interval_seconds: float = 2.5
@export var min_spawn_distance: float = 900.0
@export var max_spawn_distance: float = 1600.0

var _time_since_last_spawn: float = 0.0

func _process(delta: float) -> void:
    _time_since_last_spawn += delta
    if _time_since_last_spawn < spawn_interval_seconds:
        return
    _time_since_last_spawn = 0.0
    _try_spawn_predator()

func _try_spawn_predator() -> void:
    var scene := _pick_scene()
    if scene == null:
        return
    if _current_predator_count() >= max_predator_count:
        return
    var player: Node2D = _find_player()
    if player == null:
        return
    var parent_2d: Node2D = get_parent() as Node2D
    if parent_2d == null:
        return
    var pos: Vector2 = _random_point_in_ring(player.global_position, min_spawn_distance, max_spawn_distance)
    var predator: Node2D = scene.instantiate() as Node2D
    parent_2d.add_child(predator)
    predator.global_position = pos

func _pick_scene() -> PackedScene:
    if predator_scenes != null and predator_scenes.size() > 0:
        var idx := randi() % predator_scenes.size()
        return predator_scenes[idx]
    return predator_scene

func _current_predator_count() -> int:
    var count := 0
    for child in get_parent().get_children():
        if child is CharacterBody2D and child.is_in_group("predator"):
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
