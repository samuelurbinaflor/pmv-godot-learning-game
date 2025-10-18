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

var in_knockback := false
var can_take_damage := true

var facing_left := false 
var diamonds := 0

enum PlayerState { NORMAL, ENTERING_DOOR }
var state := PlayerState.NORMAL
@onready var door: Area2D = $"./Door"
var door_near := false

# === REFS ===
@onready var player: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_hitbox: Area2D = $attack_hitbox
@onready var game: Node2D = $".."
@onready var hud = get_parent().get_node("CanvasLayer/HUD")
@onready var collect_hitbox: Area2D = $collect_hitbox


func _ready():
	attack_hitbox.monitoring = false
	collect_hitbox.monitoring = true

func _physics_process(delta: float) -> void:
	if in_knockback:
		return

	if not alive:
		velocity = Vector2.ZERO #stop movement
		return
		
	if state == PlayerState.ENTERING_DOOR:
		move_and_slide()
		return
		
	if is_attacking and is_on_floor():
		velocity.x = 0  # frena solo si está en suelo
	else:
		handle_movement()
	
	apply_gravity(delta)
	handle_jump()
	move_and_slide()
	
	if state == PlayerState.NORMAL:
		if not is_attacking and can_take_damage:
			if is_on_floor():
				player.play("idle" if velocity.x == 0 else "run")
			else:
				player.play("jump" if velocity.y < 0 else "fall")



# === MOVEMENT AND PHISICS ===
func handle_movement() -> void:
	var direction := Input.get_axis("m_left", "m_right")
	
	# Flip del sprite
	player.flip_h = direction < 0
	
	# Movimiento
	if direction != 0:
		velocity.x = direction * SPEED
		facing_left = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	player.flip_h = facing_left
	flip_attack_hitbox()


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_attacking:
		if door_near:
			door_in()
		else:
			velocity.y = JUMP_VELOCITY
			player.play("jump")



# === ATTACK ===
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()
		
func attack() -> void:
	if not alive or is_attacking:
		return
		
	is_attacking = true
	player.play("attack")
	
	await get_tree().create_timer(ATTACK_DELAY).timeout
	attack_hitbox.monitoring = true

	
	await get_tree().create_timer(ATTACK_DURATION).timeout
	attack_hitbox.monitoring = false
	
	await player.animation_finished
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
		hud.update_hearts(current_health)
		can_take_damage = false
		
		
		if current_health <= 0:
			await die()
		else:
			blink_effect()
			apply_knockback()
			await get_tree().create_timer(cooldown).timeout
			can_take_damage = true
			

func apply_knockback():
	in_knockback = true

	# Calcula dirección del empuje según hacia dónde mire
	var knock_dir := Vector2(1 if facing_left else -1, 0)
	var knockback_force := 300.0
	
	velocity = knock_dir * knockback_force
	velocity.y = -150  # lo levanta un poco hacia arriba
	
	in_knockback = false


func die():
	alive = false
	player.play("dead")
	await player.animation_finished
	get_tree().reload_current_scene()

func blink_effect():
	# Parpadea un poco mientras es invulnerable
	for i in range(3):
		modulate = Color(1, 1, 1, 0.3) # transparente
		await get_tree().create_timer(0.1).timeout
		modulate = Color(1, 1, 1, 1) # visible
		await get_tree().create_timer(0.1).timeout
		
# === DIAMONDS === 
func _on_collect_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("diamonds"):
		diamonds += 1
		hud.update_diamonds(diamonds)
		area.queue_free()  # elimina el diamante de la escena
		
	if area.is_in_group("hearts"):
		if current_health < MAX_HEALTH:
			current_health += 1
			hud.update_hearts(current_health)
			area.queue_free()  # elimina el diamante de la escena

# === DOOR ===
func door_in():
	state = PlayerState.ENTERING_DOOR
	velocity = Vector2.ZERO
	player.play("door_in")
	await player.animation_finished
	get_tree().change_scene_to_file("res://scenes/Victoria.tscn")

func door_out():
	state = PlayerState.ENTERING_DOOR
	velocity = Vector2.ZERO
	player.play("door_out")
	await player.animation_finished
	state = PlayerState.NORMAL
	
