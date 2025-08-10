extends Node

@export var water_tint: Color = Color(0.85, 0.95, 1.0, 1.0)
@export var bubble_amount: int = 64

func _ready() -> void:
    _apply_biome()

func _apply_biome() -> void:
    var canvas := get_parent().get_node_or_null("CanvasModulate") as CanvasModulate
    if canvas:
        canvas.color = water_tint
    var bubbles := get_parent().get_node_or_null("Bubbles") as GPUParticles2D
    if bubbles:
        bubbles.amount = bubble_amount
