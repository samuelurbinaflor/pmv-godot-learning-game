extends RigidBody2D

@export var speed := 250.0
@export var gravity := 100.0
@export var damage := 1                  

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_detector: Area2D = $CollisionDetector
@onready var explosion_area: Area2D = $ExplosionArea
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var bomb: RigidBody2D = $"."

var exploded := false

func _ready():
	collision_detector.body_entered.connect(_on_body_entered)
	collision_detector.body_shape_entered.connect(_on_body_shape_entered)
	explosion_area.monitoring = false

func _physics_process(delta):
	if exploded:
		return
	linear_velocity.y += gravity * delta

func _on_body_entered(body):
	if exploded:
		return
	explode()

func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	if exploded:
		return
	explode()


func explode():
	if exploded:
		return
	exploded = true
	
	# Stops the movement
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	set_deferred("freeze", true)

	collision_detector.monitoring = false
	collision_shape_2d.disabled = true

	# Explosion animation
	animated_sprite_2d.play("explode")
	explosion_area.monitoring = true

	# Area damage
	for body in explosion_area.get_overlapping_bodies():
		if body.is_in_group("player") and body.has_method("hit"):
			body.hit(damage)

	await get_tree().create_timer(1).timeout
	queue_free()
	
func start_auto_explode_timer(seconds: float):
	await get_tree().create_timer(seconds).timeout
	if not exploded:
		explode()
