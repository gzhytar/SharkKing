extends CharacterBody2D

const Loot = preload("res://scripts/core/loot.gd")

enum State { PATROL, OBSERVE, FLEE }

@export var patrol_speed: float = 160.0
@export var observe_speed: float = 180.0
@export var detection_radius: float = 600.0
@export var preferred_distance: float = 260.0
@export var max_hp: int = 4
@export var flee_hp_threshold: float = 0.4
@export var loot_min: int = 1
@export var loot_max: int = 3

var _state: State = State.PATROL
var _hp: int
var _patrol_dir: Vector2 = Vector2.RIGHT

func _ready() -> void:
    add_to_group("predator")
    _hp = max_hp
    randomize()
    _patrol_dir = Vector2(randf() * 2.0 - 1.0, randf() * 2.0 - 1.0).normalized()

func _physics_process(_delta: float) -> void:
    var player := _find_player()
    _update_state(player)
    _apply_state_logic(player)
    move_and_slide()

func _update_state(player: Node2D) -> void:
    var low_hp := float(_hp) / float(max_hp) <= flee_hp_threshold
    if low_hp:
        _state = State.FLEE
        return
    if player == null:
        _state = State.PATROL
        return
    var dist := (player.global_position - global_position).length()
    if dist <= detection_radius:
        _state = State.OBSERVE
    else:
        _state = State.PATROL

func _apply_state_logic(player: Node2D) -> void:
    match _state:
        State.PATROL:
            velocity = _patrol_dir * patrol_speed
            _patrol_dir = (_patrol_dir + Vector2(randf() - 0.5, randf() - 0.5) * 0.15).normalized()
        State.OBSERVE:
            if player:
                var to_player := player.global_position - global_position
                var dir := to_player.normalized()
                var dist := to_player.length()
                # Maintain preferred distance: move closer if too far, back off if too close
                if dist > preferred_distance * 1.15:
                    velocity = dir * observe_speed
                elif dist < preferred_distance * 0.85:
                    velocity = -dir * observe_speed
                else:
                    velocity = Vector2.ZERO
        State.FLEE:
            if player:
                var dir := (global_position - player.global_position).normalized()
                velocity = dir * (observe_speed + 40.0)
        _:
            velocity = Vector2.ZERO

func take_damage(amount: int) -> void:
    _hp = max(0, _hp - amount)
    if _hp <= 0:
        _die()

func _die() -> void:
    var parent := get_parent()
    if parent:
        var amount := randi_range(loot_min, loot_max)
        Loot.spawn_pickup(amount, global_position, parent)
    queue_free()

func _find_player() -> Node2D:
    var root := get_tree().current_scene
    if root == null:
        return null
    return root.find_child("Player", true, false) as Node2D
