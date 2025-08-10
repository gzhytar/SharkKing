extends CharacterBody2D

const Loot = preload("res://scripts/core/loot.gd")

enum State { PATROL, CHASE, ATTACK, FLEE }

@export var patrol_speed: float = 180.0
@export var chase_speed: float = 260.0
@export var flee_speed: float = 300.0
@export var detection_radius: float = 520.0
@export var attack_range: float = 56.0
@export var attack_cooldown_seconds: float = 1.2
@export var contact_damage: int = 1
@export var max_hp: int = 6
@export var flee_hp_threshold: float = 0.1
@export var loot_min: int = 2
@export var loot_max: int = 4

var _state: State = State.PATROL
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
    if dist <= attack_range and _attack_cd == 0.0:
        _state = State.ATTACK
    elif dist <= detection_radius:
        _state = State.CHASE
    else:
        _state = State.PATROL

func _apply_state_logic(player: Node2D) -> void:
    match _state:
        State.PATROL:
            velocity = _patrol_dir * patrol_speed
            _patrol_dir = (_patrol_dir + Vector2(randf() - 0.5, randf() - 0.5) * 0.18).normalized()
        State.CHASE:
            if player:
                var dir := (player.global_position - global_position).normalized()
                velocity = dir * chase_speed
        State.ATTACK:
            if player:
                var dir := (player.global_position - global_position).normalized()
                velocity = dir * chase_speed
                _deal_contact_damage(player)
                _attack_cd = attack_cooldown_seconds
        State.FLEE:
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
        Loot.spawn_pickup_with_bonus(amount, self, global_position, parent)
    queue_free()

func _find_player() -> Node2D:
    var root := get_tree().current_scene
    if root == null:
        return null
    return root.find_child("Player", true, false) as Node2D
