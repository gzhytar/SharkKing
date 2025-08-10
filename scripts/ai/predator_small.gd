extends CharacterBody2D

const Loot = preload("res://scripts/core/loot.gd")

enum PredatorState { IDLE, PATROL, CHASE, ATTACK, FLEE }

@export var move_speed: float = 260.0
@export var chase_speed: float = 320.0
@export var flee_speed: float = 380.0
@export var detection_radius: float = 420.0
@export var attack_range: float = 48.0
@export var attack_cooldown_seconds: float = 0.8
@export var contact_damage: int = 1
@export var max_hp: int = 5
@export var flee_hp_threshold: float = 0.2  # flee under 20%
@export var loot_min: int = 1
@export var loot_max: int = 3

var _state: PredatorState = PredatorState.IDLE
var _hp: int
var _attack_cd: float = 0.0
var _patrol_dir: Vector2 = Vector2.RIGHT

func _ready() -> void:
    add_to_group("predator")
    _hp = max_hp
    randomize()
    _patrol_dir = Vector2(randf() * 2.0 - 1.0, randf() * 2.0 - 1.0).normalized()

func _physics_process(delta: float) -> void:
    _attack_cd = max(0.0, _attack_cd - delta)
    var player := _find_player()
    _update_state(player)
    _apply_state_logic(delta, player)
    move_and_slide()

func _update_state(player: Node2D) -> void:
    var low_hp := float(_hp) / float(max_hp) <= flee_hp_threshold
    if low_hp:
        _state = PredatorState.FLEE
        return
    if player == null:
        _state = PredatorState.PATROL
        return
    var dist := (player.global_position - global_position).length()
    if dist <= attack_range and _attack_cd == 0.0:
        _state = PredatorState.ATTACK
    elif dist <= detection_radius:
        _state = PredatorState.CHASE
    else:
        _state = PredatorState.PATROL

func _apply_state_logic(_delta: float, player: Node2D) -> void:
    match _state:
        PredatorState.PATROL:
            velocity = _patrol_dir * move_speed
            _patrol_dir = (_patrol_dir + Vector2(randf() - 0.5, randf() - 0.5) * 0.2).normalized()
        PredatorState.CHASE:
            if player:
                var dir := (player.global_position - global_position).normalized()
                velocity = dir * chase_speed
        PredatorState.ATTACK:
            if player:
                var dir := (player.global_position - global_position).normalized()
                velocity = dir * chase_speed
                _deal_contact_damage(player)
                _attack_cd = attack_cooldown_seconds
        PredatorState.FLEE:
            if player:
                var dir := (global_position - player.global_position).normalized()
                velocity = dir * flee_speed
        _:
            velocity = Vector2.ZERO

func _deal_contact_damage(player: Node2D) -> void:
    if player.has_method("take_damage"):
        player.take_damage(contact_damage)

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
