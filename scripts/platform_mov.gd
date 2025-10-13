# Plataforma.gd
extends AnimatableBody2D

@export var start_position: Vector2 = Vector2.ZERO
@export var end_position: Vector2 = Vector2(200, 0)
@export var speed: float = 100.0
@export var wait_time: float = 0.5  # segundos en cada extremo

var _dir: int = 1
var _target: Vector2
var _wait_timer: float = 0.0

func _ready():
	position = start_position
	_target = end_position

func _physics_process(delta: float) -> void:
	if _wait_timer > 0.0:
		_wait_timer -= delta
		return

	var next_pos = position.move_toward(_target, speed * delta)
	position = next_pos

	if position.distance_to(_target) < 1.0:
		_wait_timer = wait_time
		_dir *= -1
		_target = end_position if _dir == 1 else start_position
