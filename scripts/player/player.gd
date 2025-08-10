extends CharacterBody2D

@export var max_swim_speed: float = 420.0
@export var swim_acceleration: float = 1800.0
@export var water_drag: float = 6.0

@export var dash_speed_multiplier: float = 2.5
@export var dash_duration_seconds: float = 0.15
@export var dash_cooldown_seconds: float = 1.0

@export var bite_damage: int = 1
@export var bite_cooldown_seconds: float = 0.35

var _dash_time_remaining: float = 0.0
var _dash_cooldown_remaining: float = 0.0
var _bite_cooldown_remaining: float = 0.0

func _physics_process(delta: float) -> void:
	_update_dash_timers(delta)
	_update_bite_timer(delta)
	var input_direction := _get_input_direction()
	if _is_dashing():
		_apply_dash_motion(input_direction)
	else:
		_apply_swim_motion(delta, input_direction)
		_maybe_start_dash(input_direction)
	_apply_drag(delta)
	_clamp_speed()
	move_and_slide()
	_update_facing()
	_clamp_to_world_bounds()
	_maybe_bite()

func _get_input_direction() -> Vector2:
	var dir := Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		dir.x -= 1.0
	if Input.is_action_pressed("move_right"):
		dir.x += 1.0
	if Input.is_action_pressed("move_up"):
		dir.y -= 1.0
	if Input.is_action_pressed("move_down"):
		dir.y += 1.0
	return dir.normalized()

func _apply_swim_motion(delta: float, input_direction: Vector2) -> void:
	if input_direction == Vector2.ZERO:
		return
	var target_velocity := input_direction * max_swim_speed
	var delta_velocity := target_velocity - velocity
	var accel_step := swim_acceleration * delta
	if delta_velocity.length() > accel_step:
		velocity += delta_velocity.normalized() * accel_step
	else:
		velocity = target_velocity

func _maybe_start_dash(input_direction: Vector2) -> void:
	if _dash_cooldown_remaining > 0.0:
		return
	if input_direction == Vector2.ZERO:
		return
	if Input.is_action_just_pressed("dash"):
		_dash_time_remaining = dash_duration_seconds
		_dash_cooldown_remaining = dash_cooldown_seconds
		var dash_velocity := input_direction * (max_swim_speed * dash_speed_multiplier)
		velocity = dash_velocity

func _apply_dash_motion(input_direction: Vector2) -> void:
	if input_direction != Vector2.ZERO:
		var dash_velocity := input_direction * (max_swim_speed * dash_speed_multiplier)
		velocity = dash_velocity

func _apply_drag(delta: float) -> void:
	if velocity == Vector2.ZERO:
		return
	var drag_factor: float = max(0.0, 1.0 - water_drag * delta)
	velocity *= drag_factor

func _clamp_speed() -> void:
	var speed := velocity.length()
	var current_max := max_swim_speed * (dash_speed_multiplier if _is_dashing() else 1.0)
	if speed > current_max:
		velocity = velocity.normalized() * current_max

func _update_dash_timers(delta: float) -> void:
	if _dash_time_remaining > 0.0:
		_dash_time_remaining = max(0.0, _dash_time_remaining - delta)
	if _dash_cooldown_remaining > 0.0:
		_dash_cooldown_remaining = max(0.0, _dash_cooldown_remaining - delta)

func _is_dashing() -> bool:
	return _dash_time_remaining > 0.0

func _update_facing() -> void:
	var sprite: Sprite2D = get_node_or_null("Sprite") as Sprite2D
	if sprite == null:
		return
	if velocity.x != 0.0:
		sprite.scale.x = 1.0 if velocity.x >= 0.0 else -1.0

func _clamp_to_world_bounds() -> void:
	var world := get_parent()
	if world == null:
		return
	var play_area: Rect2
	if world.has_method("get_play_area"):
		play_area = world.get_play_area()
	elif "play_area" in world:
		play_area = world.play_area
	else:
		return
	var pos := position
	pos.x = clampf(pos.x, play_area.position.x, play_area.position.x + play_area.size.x)
	pos.y = clampf(pos.y, play_area.position.y, play_area.position.y + play_area.size.y)
	position = pos

func _update_bite_timer(delta: float) -> void:
	if _bite_cooldown_remaining > 0.0:
		_bite_cooldown_remaining = max(0.0, _bite_cooldown_remaining - delta)

func _maybe_bite() -> void:
	if _bite_cooldown_remaining > 0.0:
		return
	if not Input.is_action_just_pressed("bite"):
		return
	var area := get_node_or_null("BiteArea") as Area2D
	if area == null:
		return
	var bodies := area.get_overlapping_bodies()
	for b in bodies:
		if b != null and b.has_method("take_damage"):
			b.take_damage(bite_damage)
	_bite_cooldown_remaining = bite_cooldown_seconds
