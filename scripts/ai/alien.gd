extends CharacterBody2D

const Loot = preload("res://scripts/core/loot.gd")

enum State { STALK, SURGE, FLEE }

@export var stalk_speed: float = 280.0
@export var surge_speed: float = 420.0
@export var detection_radius: float = 700.0
@export var surge_range: float = 120.0
@export var surge_cooldown_seconds: float = 1.0
@export var contact_damage: int = 2
@export var max_hp: int = 8
@export var flee_hp_threshold: float = 0.35
@export var loot_min: int = 2
@export var loot_max: int = 5

var _state: State = State.STALK
var _hp: int
var _surge_cd: float = 0.0

func _ready() -> void:
    add_to_group("predator")
    _hp = max_hp

func _physics_process(delta: float) -> void:
    _surge_cd = max(0.0, _surge_cd - delta)
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
        _state = State.STALK
        return
    var dist := (player.global_position - global_position).length()
    if dist <= surge_range and _surge_cd == 0.0:
        _state = State.SURGE
    elif dist <= detection_radius:
        _state = State.STALK
    else:
        _state = State.STALK

func _apply_state_logic(player: Node2D) -> void:
    match _state:
        State.STALK:
            if player:
                # Circle around the player slightly instead of directly chasing
                var to_player := player.global_position - global_position
                var tangent := Vector2(-to_player.y, to_player.x).normalized()
                var dir := (to_player.normalized() * 0.7 + tangent * 0.3).normalized()
                velocity = dir * stalk_speed
        State.SURGE:
            if player:
                var dir := (player.global_position - global_position).normalized()
                velocity = dir * surge_speed
                _deal_contact_damage(player)
                _surge_cd = surge_cooldown_seconds
        State.FLEE:
            if player:
                var dir := (global_position - player.global_position).normalized()
                velocity = dir * stalk_speed
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
