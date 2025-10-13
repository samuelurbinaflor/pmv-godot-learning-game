extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func open_door():
	if animated_sprite.animation == "Opening":
		return
	animated_sprite.play("Opening")
	await  animated_sprite.animation_finished
	animated_sprite.play("Closing")
