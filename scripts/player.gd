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
var attack_position := Vector2(8,-2)
var cooldown := 0.8 #invulnerability time
var can_take_damage := true
var facing_left := false 
var diamonds := 0

# === REFS ===
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_hitbox: Area2D = $attack_hitbox
@onready var game: Node2D = $".."
@onready var diamond_hitbox: Area2D = $diamond_hitbox

func _ready():
	attack_hitbox.monitoring = false
	diamond_hitbox.monitoring = true

func _physics_process(delta: float) -> void:
	if not alive:
		velocity = Vector2.ZERO #stop movement
		return
	
	if is_attacking and is_on_floor():
		velocity.x = 0  # frena solo si está en suelo
	else:
		handle_movement()
	
	apply_gravity(delta)
	handle_jump()
	move_and_slide()
	

	if not is_attacking and can_take_damage:
		if is_on_floor():
			animated_sprite.play("idle" if velocity.x == 0 else "run")
		else:
			animated_sprite.play("jump" if velocity.y < 0 else "fall")



# === MOVEMENT AND PHISICS ===
func handle_movement() -> void:
	var direction := Input.get_axis("m_left", "m_right")
	
	# Flip del sprite
	animated_sprite.flip_h = direction < 0
	
	# Movimiento
	if direction != 0:
		velocity.x = direction * SPEED
		facing_left = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	animated_sprite.flip_h = facing_left
	flip_attack_hitbox()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_attacking:
		velocity.y = JUMP_VELOCITY
		animated_sprite.play("jump")



# === ATTACK ===
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()
		
func attack() -> void:
	if not alive or is_attacking:
		return
		
	is_attacking = true
	animated_sprite.play("attack")
	
	await get_tree().create_timer(ATTACK_DELAY).timeout
	attack_hitbox.monitoring = true

	
	await get_tree().create_timer(ATTACK_DURATION).timeout
	attack_hitbox.monitoring = false

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		is_attacking = false

func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	var enemy_node = area.get_parent()
	if enemy_node.is_in_group("enemies"):
		enemy_node.hit(1, Vector2(facing_left,0))
	
func flip_attack_hitbox():
	if facing_left:
		attack_hitbox.position = Vector2(-48, attack_position.y)
	else:
		attack_hitbox.position = attack_position

 # === DAMAGE ===
func hit(amount: int):
	if not alive or not can_take_damage:
		return
		
	else:
		current_health -= amount
		can_take_damage = false
		
		
		if current_health <= 0:
			await die()
		else:
			blink_effect()
			await get_tree().create_timer(cooldown).timeout
			can_take_damage = true
		

	
func die():
	alive = false
	animated_sprite.play("dead")
	await animated_sprite.animation_finished
	get_tree().reload_current_scene()

func blink_effect():
	# Parpadea un poco mientras es invulnerable
	for i in range(3):
		modulate = Color(1, 1, 1, 0.3) # transparente
		await get_tree().create_timer(0.1).timeout
		modulate = Color(1, 1, 1, 1) # visible
		await get_tree().create_timer(0.1).timeout
		
# === DIAMONDS === 
func _on_diamond_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("diamonds"):
		diamonds += 1
		area.queue_free()  # elimina el diamante de la escena
		print("Diamantes: ", diamonds)
