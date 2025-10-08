# Enemigo.gd
extends Node2D

const SPEED = 50
const MAX_HEALTH = 2

var direction = 1
var current_health := MAX_HEALTH
var alive := true

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft

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

## === Damage ===
#func hit(amount: int):
	#current_health -= amount
	#if current_health <= 0:
		#die()
		#
#func die():
	#alive = false
	#animated_sprite.play("dead")
	

func _on_hitbox_body_entered(body: Node2D) -> void:
	if "player" in body.get_groups():
		body.hit(1)
