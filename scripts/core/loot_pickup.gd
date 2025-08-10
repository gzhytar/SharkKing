extends Area2D

@export var amount: int = 1
@export var resource_type: StringName = "biomass"

var _base_y: float = 0.0
var _time_accum: float = 0.0

func _ready() -> void:
    _base_y = position.y
    body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
    _time_accum += delta
    var bob_offset := sin(_time_accum * 3.0) * 4.0
    position.y = _base_y + bob_offset
    var visual := get_node_or_null("Visual") as Node2D
    if visual:
        var pulse := 1.0 + 0.05 * sin(_time_accum * 5.0)
        visual.scale = Vector2.ONE * pulse

func _on_body_entered(body: Node) -> void:
    if body == null:
        return
    if resource_type == StringName("biomass") and body.has_method("add_biomass"):
        body.add_biomass(amount)
        queue_free()


