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

@export var coin_quantity: int = 0
@export var time_quantity: int = 0
@export var upgrade_coin_percentage: float = 1.58
@export var upgrade_time_reduction: int = 1

var quantity_laundry: int
var washing_machine: Texture2D
var wash_level: int = 0
var isOccupied = false
var customerAssigned: Customer

func washMachine_init() -> void:
	body.texture = wash_0

func level_up() -> void:
	if wash_level == 6:
		return
	wash_level += 1
	match wash_level:
		0:
			body.texture = wash_0
		1:
			coin_quantity = 3
			time_quantity = 7
			body.texture = wash_1
			body.scale *= 2
			GameManager.level_1_machines_quantity += 1
			GameManager.availableWashingMachines.append(self)			
			GameManager.my_washers += 1
		2:
			body.texture = wash_2
			GameManager.level_1_machines_quantity -= 1
			GameManager.level_2_machines_quantity += 1
		3:
			body.texture = wash_3
			GameManager.level_2_machines_quantity -= 1
			GameManager.level_3_machines_quantity += 1
		4:
			body.texture = wash_4
			GameManager.level_3_machines_quantity -= 1
			GameManager.level_4_machines_quantity += 1
		5:
			body.texture = wash_5
			GameManager.level_4_machines_quantity -= 1
			GameManager.level_5_machines_quantity += 1
		6:
			body.texture = wash_6
			GameManager.level_5_machines_quantity -= 1
			GameManager.level_6_machines_quantity += 1
	
	coin_quantity = ceil(coin_quantity * upgrade_coin_percentage)
	time_quantity -= upgrade_time_reduction
	GameManager.on_washer_selected.emit(self)
	GameManager.on_level_up.emit(self)
	

func get_coin_time_when_level_up() -> Array[int]:
	var local_wash_level = wash_level + 1
	var local_coin_quantity = coin_quantity
	var local_time_quantity = time_quantity
	match local_wash_level:
		1:
			local_coin_quantity = 3
			local_time_quantity = 7
	local_coin_quantity = ceil(local_coin_quantity * upgrade_coin_percentage)
	local_time_quantity -= upgrade_time_reduction
	return [local_coin_quantity,local_time_quantity]
	
func get_wash_texture_when_level_up() -> CompressedTexture2D:
	var local_wash_level = wash_level + 1
	match local_wash_level:
		0:
			return wash_0
		1:
			return wash_1
		2:
			return wash_2
		3:
			return wash_3
		4:
			return wash_4
		5:
			return wash_5
	return wash_0

func reset_machine() -> void:
		isOccupied = false
		animation_player.play("RESET")

func wash() -> void:
	GameManager.current_coins += customerAssigned.quantity_laundry * coin_quantity
	customerAssigned.change_state(GameManager.character_state.LOADING_LAUNDRY)
	await get_tree().create_timer(2.0).timeout
	
	customerAssigned.change_state(GameManager.character_state.WAITING)
	customerAssigned.animation_player.play("Waiting")
	var wash_string: String = "wash_%d" % wash_level
	var timeToFinish = customerAssigned.quantity_laundry * time_quantity
	animation_player.play(wash_string)
	await get_tree().create_timer(timeToFinish).timeout
	reset_machine()
	customerAssigned.change_state(GameManager.character_state.WALKING_CLEAN)
	GameManager.assign_customer(self)
	

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		GameManager.on_washer_selected.emit(self)
