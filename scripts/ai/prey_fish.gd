extends CharacterBody2D

const Loot = preload("res://scripts/core/loot.gd")

@export var swim_speed: float = 240.0
@export var turn_speed: float = 8.0
@export var avoid_radius: float = 160.0
@export var wander_jitter: float = 0.8
@export var max_hp: int = 1
@export var loot_min: int = 1
@export var loot_max: int = 2

var _desired_direction: Vector2 = Vector2.RIGHT
var _hp: int
var _hit_flash_time: float = 0.0

func _ready() -> void:
    add_to_group("prey")
    randomize()
    _assign_random_texture()
    _desired_direction = Vector2(randf() * 2.0 - 1.0, randf() * 2.0 - 1.0).normalized()
    _hp = max_hp

func _assign_random_texture() -> void:
    var sprite := get_node_or_null("Sprite") as Sprite2D
    if sprite == null:
        return
    var idx := randi() % 4 + 1
    var path := "res://images/prey-%d.png" % idx
    if ResourceLoader.exists(path):
        var tex := load(path) as Texture2D
        if tex:
            sprite.texture = tex

func _physics_process(delta: float) -> void:
    var avoid := _compute_avoidance()
    var target := (_desired_direction + avoid).normalized()
    var current_dir := velocity.normalized() if velocity.length() > 0.01 else _desired_direction
    var new_dir := current_dir.lerp(target, clamp(turn_speed * delta, 0.0, 1.0)).normalized()
    velocity = new_dir * swim_speed
    move_and_slide()
    _maybe_change_wander(delta)
    _update_hit_flash(delta)

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
    var root := get_tree().current_scene
    if root == null:
        return null
    return root.find_child("Player", true, false) as Node2D

func _maybe_change_wander(delta: float) -> void:
    var jitter := Vector2(randf() - 0.5, randf() - 0.5) * wander_jitter * delta * 10.0
    _desired_direction = (_desired_direction + jitter).normalized()

func take_damage(amount: int) -> void:
    _hp = max(0, _hp - amount)
    _flash_hit()
    if _hp <= 0:
        _die()

func _die() -> void:
    var parent := get_parent()
    if parent:
        var amount := randi_range(loot_min, loot_max)
        Loot.spawn_pickup_with_bonus(amount, self, global_position, parent)
    queue_free()

func _flash_hit() -> void:
    _hit_flash_time = 0.12
    var sprite := get_node_or_null("Sprite") as Sprite2D
    if sprite:
        sprite.modulate = Color(1, 0.5, 0.5, 1)

func _update_hit_flash(delta: float) -> void:
    if _hit_flash_time <= 0.0:
        return
    _hit_flash_time = max(0.0, _hit_flash_time - delta)
    if _hit_flash_time == 0.0:
        var sprite := get_node_or_null("Sprite") as Sprite2D
        if sprite:
            sprite.modulate = Color(1, 1, 1, 1)
