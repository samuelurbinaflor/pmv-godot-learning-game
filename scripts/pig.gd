# Enemigo.gd
extends Node2D

const SPEED = 50
const MAX_HEALTH = 50

var direction = 1
var current_health := MAX_HEALTH
var alive := true

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var hitbox: Area2D = $hitbox

func _process(delta: float) -> void:
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = false
		
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = true
		
	if direction != 0:
		animated_sprite.play("Run")
		
	position.x += direction * SPEED * delta

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
	direction = 0
	ray_cast_left.enabled = false
	ray_cast_right.enabled = false
	hitbox.monitoring = false

	animated_sprite.play("dead")

	
func blink_effect():
	for i in range(3):
		modulate = Color(1, 1, 1, 0.3) # transparente
		await get_tree().create_timer(0.1).timeout
		modulate = Color(1, 1, 1, 1) # visible
		await get_tree().create_timer(0.1).timeout


func _on_hitbox_body_entered(body: Node2D) -> void:
	if "player" in body.get_groups():
		body.hit(1)
