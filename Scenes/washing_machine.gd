extends Node2D
class_name WashingMachine
@export var animation_player: AnimationPlayer
@export var wash_0: CompressedTexture2D
@export var wash_1: CompressedTexture2D
@export var wash_2: CompressedTexture2D
@export var wash_3: CompressedTexture2D
@export var wash_4: CompressedTexture2D
@export var wash_5: CompressedTexture2D
@export var wash_6: CompressedTexture2D
@export var body: Sprite2D

var quantity_laundry: int
var washing_machine: Texture2D
var wash_level: int = 0

func washMachine_init() -> void:
	body.texture = wash_0

func level_up() -> void:
	wash_level += 1
	match wash_level:
		0:
			body.texture = wash_0
		1:
			body.texture = wash_1
		2:
			body.texture = wash_2
		3:
			body.texture = wash_3
		4:
			body.texture = wash_4
		5:
			body.texture = wash_5
			
func load_laundry(quantity: int) -> void:
	quantity_laundry = quantity
	

func wash() -> void:
	var wash_string: String = 'washing_%i' % wash_level
	animation_player.play(wash_string)
