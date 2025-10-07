extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_hitbox: Area2D = $Attack_Hitbox

var is_attacking = false

func _ready():
	attack_hitbox.monitoring = false  # Desactivada al inicio

func _physics_process(delta: float) -> void:
	if is_attacking:
		velocity.x = 0
	else:
		handle_movement()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	move_and_slide()
	
func handle_movement():
	# Get the input direction: -1, 0, 1
	var direction := Input.get_axis("m_left", "m_right")
	
	#Flip the Sprite
	if direction > 0:
		animated_sprite.flip_h = false
	if direction < 0:
		animated_sprite.flip_h = true
		
	# Horizontal movement
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Play animation
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("fall")
		

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()
		
func attack():
	is_attacking = true
	animated_sprite.play("attack")
	
	await get_tree().create_timer(0.1).timeout  # delay
	attack_hitbox.monitoring = true
	
	await get_tree().create_timer(0.2).timeout  # attacking time
	attack_hitbox.monitoring = false

func _on_Hitbox_body_entered(body):
	if body.is_in_group("Enemy"):
		body.take_damage(10)


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		is_attacking = false
