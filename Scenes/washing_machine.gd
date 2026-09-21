extends Node2D
class_name WashingMachine

@export var washing_bar: WashingBar
@export var animation_player: AnimationPlayer
@export var wash_0: CompressedTexture2D
@export var wash_1: CompressedTexture2D
@export var wash_2: CompressedTexture2D
@export var wash_3: CompressedTexture2D
@export var wash_4: CompressedTexture2D
@export var wash_5: CompressedTexture2D
@export var wash_6: CompressedTexture2D
@export var washOG_0: CompressedTexture2D
@export var washOG_1: CompressedTexture2D
@export var washOG_2: CompressedTexture2D
@export var washOG_3: CompressedTexture2D
@export var washOG_4: CompressedTexture2D
@export var washOG_5: CompressedTexture2D
@export var washOG_6: CompressedTexture2D
@export var body: Sprite2D

@export var coin_quantity: int = 0
@export var time_quantity: int = 0
@export var upgrade_coin_percentage: float
@export var upgrade_time_reduction: int = 1

var quantity_laundry: int
var washing_machine: Texture2D
var wash_level: int = 0
var isOccupied = false
var customerAssigned: Customer
var currentIndexUnlockedSkins: int = 0

func _ready() -> void:
	GameManager.on_AIAssetChange.connect(_setSkinOnAIAssetChange)
	if(GameManager.isAIAssetActive):
		body.texture = wash_0
	else:
		body.texture = washOG_0

func level_up() -> void:
	if wash_level == 6:
		return
	wash_level += 1
	match wash_level:
		0:
			if(GameManager.isAIAssetActive):
				body.texture = wash_0
			else:
				body.texture = washOG_0
		1:
			coin_quantity = 9
			time_quantity = 8
			if(GameManager.isAIAssetActive):
				body.texture = wash_1
			else:
				body.texture = washOG_1
			body.scale *= 2
			upgrade_coin_percentage = 1
			GameManager.level_1_machines_quantity += 1
			GameManager.availableWashingMachines.append(self)			
			GameManager.my_washers += 1
			GameManager.level1MachinesUnlocked +=1
		2:
			if(GameManager.isAIAssetActive):
				body.texture = wash_2
			else:
				body.texture = washOG_2
			upgrade_coin_percentage = 1.95
			GameManager.level_1_machines_quantity -= 1
			GameManager.level_2_machines_quantity += 1
			GameManager.level2MachinesUnlocked +=1
		3:
			if(GameManager.isAIAssetActive):
				body.texture = wash_3
			else:
				body.texture = washOG_3
			upgrade_coin_percentage = 3.06
			GameManager.level_2_machines_quantity -= 1
			GameManager.level_3_machines_quantity += 1
			GameManager.level3MachinesUnlocked +=1
		4:
			if(GameManager.isAIAssetActive):
				body.texture = wash_4
			else:
				body.texture = washOG_4
			upgrade_coin_percentage = 5.36
			GameManager.level_3_machines_quantity -= 1
			GameManager.level_4_machines_quantity += 1
			GameManager.level4MachinesUnlocked +=1
		5:
			if(GameManager.isAIAssetActive):
				body.texture = wash_5
			else:
				body.texture = washOG_5
			upgrade_coin_percentage = 9.38
			GameManager.level_4_machines_quantity -= 1
			GameManager.level_5_machines_quantity += 1
			GameManager.level5MachinesUnlocked +=1
		6:
			if(GameManager.isAIAssetActive):
				body.texture = wash_6
			else:
				body.texture = washOG_6
			upgrade_coin_percentage = 5.41
			GameManager.level_5_machines_quantity -= 1
			GameManager.level_6_machines_quantity += 1
			GameManager.level6MachinesUnlocked +=1
	
	coin_quantity = ceil(coin_quantity * upgrade_coin_percentage)
	time_quantity -= upgrade_time_reduction
	GameManager.on_washer_selected.emit(self)
	GameManager.on_level_up.emit(self)
	

func get_coin_time_when_level_up() -> Array[int]:
	var local_wash_level = wash_level + 1
	var local_coin_quantity = coin_quantity
	var local_time_quantity = time_quantity
	var local_upgrade_coin_percentage = upgrade_coin_percentage
	match local_wash_level:
		1:
			local_coin_quantity = 9
			local_time_quantity = 8
			local_upgrade_coin_percentage = 1
		2:
			local_upgrade_coin_percentage = 1.95
		3:
			local_upgrade_coin_percentage = 3.06
		4:
			local_upgrade_coin_percentage = 5.36
		5:
			local_upgrade_coin_percentage = 9.38
		6:
			local_upgrade_coin_percentage = 5.41
	local_coin_quantity = ceil(local_coin_quantity * local_upgrade_coin_percentage)
	local_time_quantity -= upgrade_time_reduction
	return [local_coin_quantity,local_time_quantity]
	
func get_wash_texture_when_level_up() -> CompressedTexture2D:
	var local_wash_level = wash_level + 1
		
	if(GameManager.isAIAssetActive):
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
			6:
				return wash_6
	else:
		match local_wash_level:
			0:
				return washOG_0
			1:
				return washOG_1
			2:
				return washOG_2
			3:
				return washOG_3
			4:
				return washOG_4
			5:
				return washOG_5
			6:
				return washOG_6
	return wash_0

func reset_machine() -> void:
		isOccupied = false
		animation_player.play("RESET")

func wash() -> void:
	washing_bar.reset_bar()
	washing_bar.show()
	GameManager.play_coin_vfx(customerAssigned.position)
	SoundManager.play_coins()
	GameManager.current_coins += customerAssigned.quantity_laundry * coin_quantity
	customerAssigned.change_state(GameManager.character_state.LOADING_LAUNDRY)
	await get_tree().create_timer(2.0).timeout
	
	customerAssigned.change_state(GameManager.character_state.WAITING)
	customerAssigned.animation_player.play("Waiting")
	var wash_string: String = "wash_%d" % wash_level
	var timeToFinish = customerAssigned.quantity_laundry * time_quantity
	animation_player.play(wash_string)
	washing_bar.washingBarProgress(timeToFinish)
	await get_tree().create_timer(timeToFinish).timeout
	reset_machine()
	washing_bar.hide()
	GameManager.on_moveCustomerToExit.emit(self, customerAssigned)
	GameManager.assign_customer(self)
	

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		GameManager.on_washer_selected.emit(self)

func next_skin() -> CompressedTexture2D:
	if(GameManager.isAIAssetActive):
		currentIndexUnlockedSkins = (currentIndexUnlockedSkins + 1) % GameManager.unlockedWashingMachinesSkins.size()
		var skin = GameManager.unlockedWashingMachinesSkins[currentIndexUnlockedSkins]
		body.texture = skin
		return skin
	else:
		currentIndexUnlockedSkins = (currentIndexUnlockedSkins + 1) % GameManager.unlockedWashingMachinesOGSkins.size()
		var skin = GameManager.unlockedWashingMachinesOGSkins[currentIndexUnlockedSkins]
		body.texture = skin
		return skin
	
func previous_skin() -> CompressedTexture2D:
	if(GameManager.isAIAssetActive):
		currentIndexUnlockedSkins = (currentIndexUnlockedSkins - 1) % GameManager.unlockedWashingMachinesOGSkins.size()
		var skin = GameManager.unlockedWashingMachinesSkins[currentIndexUnlockedSkins]
		body.texture = skin
		return skin
	else:
		currentIndexUnlockedSkins = (currentIndexUnlockedSkins - 1) % GameManager.unlockedWashingMachinesOGSkins.size()
		var skin = GameManager.unlockedWashingMachinesOGSkins[currentIndexUnlockedSkins]
		body.texture = skin
		return skin
		
func _setSkinOnAIAssetChange() -> void:
	match wash_level:
		0:
			if(GameManager.isAIAssetActive):
				body.texture = wash_0
			else:
				body.texture = washOG_0
		1:
			if(GameManager.isAIAssetActive):
				body.texture = wash_1
			else:
				body.texture = washOG_1
		2:
			if(GameManager.isAIAssetActive):
				body.texture = wash_2
			else:
				body.texture = washOG_2
		3:
			if(GameManager.isAIAssetActive):
				body.texture = wash_3
			else:
				body.texture = washOG_3
		4:
			if(GameManager.isAIAssetActive):
				body.texture = wash_4
			else:
				body.texture = washOG_4
		5:
			if(GameManager.isAIAssetActive):
				body.texture = wash_5
			else:
				body.texture = washOG_5
		6:
			if(GameManager.isAIAssetActive):
				body.texture = wash_6
			else:
				body.texture = washOG_6
