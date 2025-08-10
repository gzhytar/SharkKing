extends Node

# Default to a dark, abyssal tint suitable for volcanic vents
@export var water_tint: Color = Color(0.08, 0.07, 0.10, 1.0)
@export var bubble_amount: int = 72

# Background texture for current biome. Loaded at runtime to avoid scene parse errors if missing.
@export var background_texture_path: String = "res://images/biome-volcanic-vent.png"
@export var background_alpha: float = 0.9

# Optional mid-detail overlay (lava cracks). If empty, uses background texture.
@export var mid_detail_texture_path: String = ""
@export var mid_detail_alpha: float = 0.6

# Parallax autoscroll speeds (pixels/sec) for subtle motion
@export var autoscroll_speed_back: Vector2 = Vector2(2.0, 0.0)
@export var autoscroll_speed_mid: Vector2 = Vector2(6.0, 0.0)
@export var autoscroll_speed_fore: Vector2 = Vector2(12.0, 0.0)

func _ready() -> void:
    _apply_biome()
    set_process(true)

func _apply_biome() -> void:
    var world := get_parent()
    var canvas := world.get_node_or_null("CanvasModulate") as CanvasModulate
    if canvas:
        canvas.color = water_tint
    var bubbles := world.get_node_or_null("Bubbles") as GPUParticles2D
    if bubbles:
        bubbles.amount = bubble_amount
    _ensure_backdrop(world)
    _ensure_mid_detail(world)
    _ensure_fore_plumes(world)

func _process(delta: float) -> void:
    _auto_scroll_layers(delta)

func _ensure_backdrop(world: Node) -> void:
    var layer_back := world.get_node_or_null("ParallaxBackground/LayerBack") as ParallaxLayer
    if layer_back == null:
        return
    var sprite := layer_back.get_node_or_null("VentBackdrop") as Sprite2D
    if sprite == null:
        sprite = Sprite2D.new()
        sprite.name = "VentBackdrop"
        layer_back.add_child(sprite)
    sprite.modulate = Color(1, 1, 1, clamp(background_alpha, 0.0, 1.0))
    _load_and_fit_texture(sprite)

func _load_and_fit_texture(sprite: Sprite2D) -> void:
    if background_texture_path.is_empty():
        return
    if not ResourceLoader.exists(background_texture_path):
        return
    var tex := load(background_texture_path) as Texture2D
    if tex == null:
        return
    sprite.texture = tex
    sprite.centered = true
    sprite.position = Vector2.ZERO
    _fit_sprite_to_viewport(sprite, tex)

func _fit_sprite_to_viewport(sprite: Sprite2D, tex: Texture2D) -> void:
    var viewport := get_viewport()
    if viewport == null:
        return
    var viewport_size := viewport.get_visible_rect().size
    if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
        return
    var scale_x: float = viewport_size.x / float(tex.get_width())
    var scale_y: float = viewport_size.y / float(tex.get_height())
    var s: float = max(scale_x, scale_y) * 1.2
    sprite.scale = Vector2(s, s)

func _ensure_mid_detail(world: Node) -> void:
    var parent := world.get_node_or_null("ParallaxBackground") as ParallaxBackground
    if parent == null:
        return
    var layer := parent.get_node_or_null("LayerMidDetail") as ParallaxLayer
    if layer == null:
        layer = ParallaxLayer.new()
        layer.name = "LayerMidDetail"
        layer.motion_scale = Vector2(0.8, 0.8)
        parent.add_child(layer)
    var sprite := layer.get_node_or_null("LavaCracks") as Sprite2D
    if sprite == null:
        sprite = Sprite2D.new()
        sprite.name = "LavaCracks"
        layer.add_child(sprite)
    sprite.modulate = Color(1, 1, 1, clamp(mid_detail_alpha, 0.0, 1.0))
    var tex_path := mid_detail_texture_path
    if tex_path.is_empty():
        tex_path = background_texture_path
    if ResourceLoader.exists(tex_path):
        var tex := load(tex_path) as Texture2D
        if tex:
            sprite.texture = tex
            sprite.centered = true
            sprite.position = Vector2.ZERO
            _fit_sprite_to_viewport(sprite, tex)

func _ensure_fore_plumes(world: Node) -> void:
    var parent := world.get_node_or_null("ParallaxBackground") as ParallaxBackground
    if parent == null:
        return
    var layer := parent.get_node_or_null("LayerFore") as ParallaxLayer
    if layer == null:
        layer = ParallaxLayer.new()
        layer.name = "LayerFore"
        layer.motion_scale = Vector2(1.2, 1.2)
        parent.add_child(layer)
    var plumes := layer.get_node_or_null("VentPlumes") as GPUParticles2D
    if plumes == null:
        plumes = GPUParticles2D.new()
        plumes.name = "VentPlumes"
        layer.add_child(plumes)
    plumes.amount = 80
    plumes.lifetime = 2.6
    plumes.one_shot = false
    plumes.preprocess = 1.0
    plumes.explosiveness = 0.0
    plumes.speed_scale = 1.0
    # Set basic process material for upward motion
    var mat := plumes.process_material as ParticleProcessMaterial
    if mat == null:
        mat = ParticleProcessMaterial.new()
        plumes.process_material = mat
    mat.direction = Vector3(0, -1, 0)
    mat.gravity = Vector3(0, -10, 0)
    mat.initial_velocity_min = 40.0
    mat.initial_velocity_max = 90.0
    mat.angular_velocity_min = -2.0
    mat.angular_velocity_max = 2.0
    mat.scale_min = 0.4
    mat.scale_max = 0.9
    plumes.position = Vector2(-300, 250)

func _auto_scroll_layers(delta: float) -> void:
    var parent := get_parent().get_node_or_null("ParallaxBackground") as ParallaxBackground
    if parent == null:
        return
    var back := parent.get_node_or_null("LayerBack") as ParallaxLayer
    if back:
        back.motion_offset += autoscroll_speed_back * delta
    var mid := parent.get_node_or_null("LayerMid") as ParallaxLayer
    if mid:
        mid.motion_offset += autoscroll_speed_mid * delta
    var mid_detail := parent.get_node_or_null("LayerMidDetail") as ParallaxLayer
    if mid_detail:
        mid_detail.motion_offset += autoscroll_speed_mid * delta
    var fore := parent.get_node_or_null("LayerFore") as ParallaxLayer
    if fore:
        fore.motion_offset += autoscroll_speed_fore * delta
