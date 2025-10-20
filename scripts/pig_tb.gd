# Enemigo.gd
extends Node2D

const MAX_HEALTH = 3

var current_health := MAX_HEALTH
var alive := true
@export var has_key := false
@export var key_scene: PackedScene

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $hitbox

# === BOMB ===
@export var bomb_scene: PackedScene
@export var throw_cooldown := 2.0
@onready var detection_area: Area2D = $DetectionArea
@onready var bomb_spawn: Marker2D = $BombSpawn
var player_in_range = false
var player_ref: Node2D = null
var can_throw = true

func _process(delta: float) -> void:
	if not alive:
		return
	
	elif can_throw or player_in_range:
			_try_throw_bomb()
		
func _ready() -> void:
	return

# === DAMAGE ===
func hit(amount: int, knockback_dir := Vector2.ZERO):
	if not alive:
		return
	
	current_health -= amount
	blink_effect()
	apply_knockback(knockback_dir)

	if current_health <= 0:
		die()

func apply_knockback(dir: Vector2):
	var knockback_strength := 1
	var original_pos := position
	var target_pos := original_pos + Vector2(dir.x * knockback_strength, 0)
	
	var tween := create_tween()
	tween.tween_property(self, "position", target_pos, 0.1)
	tween.tween_property(self, "position", original_pos, 0.2)

func die():
	alive = false
	hitbox.monitoring = false
	animated_sprite.play("dead")
	await  animated_sprite.animation_finished
	
	if has_key:
		spawn_key()
		
func spawn_key():
	var key_instance = key_scene.instantiate()
	get_tree().current_scene.add_child(key_instance)
	key_instance.global_position = global_position


func blink_effect():
	for i in range(3):
		modulate = Color(1, 1, 1, 0.3) # transparente
		await get_tree().create_timer(0.1).timeout
		modulate = Color(1, 1, 1, 1) # visible
		await get_tree().create_timer(0.1).timeout


# === TRHOW BOMB ===

func _on_detection_area_body_entered(body: Node2D) -> void:
	if not alive:
		return
	if body.is_in_group("player"):
		player_in_range = true
		player_ref = body
		_try_throw_bomb()

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player_ref:
		player_in_range = false
		player_ref = null

func _try_throw_bomb():
	if not alive:
		return
		
	if not can_throw or not player_in_range:
		return

	can_throw = false
	animated_sprite.play("throw") 
	await get_tree().create_timer(0.7).timeout
	_throw_bomb()
	await animated_sprite.animation_finished
	
	animated_sprite.play("idle")
	await get_tree().create_timer(throw_cooldown).timeout
	can_throw = true

func _throw_bomb():
	if not player_ref or not alive:
		return

	var bomb = bomb_scene.instantiate()
	get_tree().current_scene.add_child(bomb)
	bomb.global_position = bomb_spawn.global_position

	var start_pos = bomb_spawn.global_position
	var target_pos = player_ref.global_position

	var distance = target_pos.x - start_pos.x
	var height_offset = start_pos.y - target_pos.y

	var gravity = bomb.gravity
	var speed = bomb.speed

	# Velocidad horizontal (x) y tiempo estimado
	var vx = sign(distance) * speed
	var t = abs(distance) / speed

	# Velocidad vertical inicial para alcanzar el objetivo
	var vy = (-height_offset - 0.5 * gravity * t * t) / t
	vy -= 250  # lanza un poco más hacia arriba

	bomb.linear_velocity = Vector2(vx, vy)
	
	bomb.call_deferred("start_auto_explode_timer", 2)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if not alive:
		return
	if "player" in body.get_groups():
		body.hit(1)
