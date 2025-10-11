extends Control

const MAX_HEALTH := 3
@onready var hearts := $HeartsContainer.get_children()
@onready var label: Label = $Label

func update_hearts(current_health: int):
	for i in range(MAX_HEALTH):
		var heart = hearts[i]

		if i < current_health:
			if heart.animation == "hit":  
				heart.play("up")         
				await heart.animation_finished
				heart.play("idle")        
			else:
				heart.play("idle")       

		else:
			if heart.animation != "hit":  
				heart.play("hit")          

func update_diamonds(diamonds: int):
	label.text = str(diamonds)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
