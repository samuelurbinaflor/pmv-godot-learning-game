extends Control

const MAX_HEALTH := 3
@onready var hearts := $HeartsContainer.get_children()

func update_hearts(current_health: int):
	for i in range(MAX_HEALTH):
		var heart = hearts[i]
		if i < current_health:
			heart.visible = true
			heart.play("idle")
		else:
			if heart.visible:
				heart.play("hit")
				await heart.animation_finished
				heart.visible = false
				

		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
