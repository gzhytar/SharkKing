extends Node

const BUTTON_LEFT := 1

func _ready() -> void:
    # Movement
    _ensure_action("move_left", [ _key(Key.KEY_A), _key(Key.KEY_LEFT) ])
    _ensure_action("move_right", [ _key(Key.KEY_D), _key(Key.KEY_RIGHT) ])
    _ensure_action("move_up", [ _key(Key.KEY_W), _key(Key.KEY_UP) ])
    _ensure_action("move_down", [ _key(Key.KEY_S), _key(Key.KEY_DOWN) ])
    # Dash
    _ensure_action("dash", [ _key(Key.KEY_SHIFT), _key(Key.KEY_SPACE), _mouse(MouseButton.MOUSE_BUTTON_RIGHT) ])
    # Bite/Attack
    _ensure_action("bite", [ _mouse(MouseButton.MOUSE_BUTTON_LEFT), _key(Key.KEY_ENTER) ])
    # Interact & Pause
    _ensure_action("interact", [ _key(Key.KEY_E) ])
    _ensure_action("pause", [ _key(Key.KEY_ESCAPE) ])

func _ensure_action(action_name: String, events: Array) -> void:
    if not InputMap.has_action(action_name):
        InputMap.add_action(action_name)
    for ev in events:
        InputMap.action_add_event(action_name, ev)

func _key(code: Key) -> InputEventKey:
    var ev := InputEventKey.new()
    ev.keycode = code
    return ev

func _mouse(button: MouseButton) -> InputEventMouseButton:
    var ev := InputEventMouseButton.new()
    ev.button_index = button
    return ev
