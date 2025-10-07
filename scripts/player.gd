extends CharacterBody2D

# === CONST ===
const SPEED := 130.0
const JUMP_VELOCITY := -300.0
const MAX_HEALTH := 3
const ATTACK_DELAY := 0.1
const ATTACK_DURATION := 0.2

# === VAR ===
var current_health := MAX_HEALTH
var alive := true
var is_attacking := false

# === REFS ===
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_hitbox: Area2D = $Attack_Hitbox

func _ready():
	attack_hitbox.monitoring = false

func _physics_process(delta: float) -> void:
	# Movimiento horizontal
	if is_attacking and is_on_floor():
		velocity.x = 0  # frena solo si está en suelo
	else:
		handle_movement()
	
	apply_gravity(delta)
	handle_jump()
	move_and_slide()
	
	# Animaciones (solo si no está atacando)
	if not is_attacking:
		if is_on_floor():
			animated_sprite.play("idle" if velocity.x == 0 else "run")
		else:
			animated_sprite.play("jump" if velocity.y < 0 else "fall")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()

# === Physics y movimiento ===
func handle_movement() -> void:
	var direction := Input.get_axis("m_left", "m_right")
	
	# Flip del sprite
	animated_sprite.flip_h = direction < 0
	
	# Movimiento
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animated_sprite.play("jump")

# === Ataque ===
func attack() -> void:
	is_attacking = true
	animated_sprite.play("attack")
	
	await get_tree().create_timer(ATTACK_DELAY).timeout
	attack_hitbox.monitoring = true
	
	await get_tree().create_timer(ATTACK_DURATION).timeout
	attack_hitbox.monitoring = false

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		is_attacking = false
