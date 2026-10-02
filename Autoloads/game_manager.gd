extends Node

signal on_washer_selected(washer: WashingMachine)
signal on_level_up(washer: WashingMachine)
signal on_move_line()
signal on_moveCustomerToWashingMachine()
signal on_moveCustomerToExit(washer: WashingMachine, customer: Customer)
signal on_skin_unlocked(washingMachineSkinUnlocked:CompressedTexture2D)
signal on_AIAssetChange()
enum character_state {WAITING, WAITING_DIRTY, WALKING_CLEAN, WALKING_DIRTY, WALKING_DIRTY_BACK, LOADING_LAUNDRY}

@export var isAIAssetActive : bool = false
@export var level_1_machines_quantity: int = 0
@export var level_2_machines_quantity: int = 0
@export var level_3_machines_quantity: int = 0
@export var level_4_machines_quantity: int = 0
@export var level_5_machines_quantity: int = 0
@export var level_6_machines_quantity: int = 0
@export var my_washers: int = 0
@export var upgrade_percentage: float = 2.58
@onready var lane_a: Marker2D
@onready var lane_b: Marker2D
@onready var lane_c: Marker2D


const COIN_VFX = preload("uid://bkxu01pi4e3tg")
const wash_0 = preload("uid://ckf4yi7wfw8tk")
const wash_1 = preload("uid://34kbjhghgvmh")
const wash_2 = preload("uid://cr2yd674nooje")
const wash_3 = preload("uid://bpho34sne2i3m")
const wash_4 = preload("uid://d157qdcf1rpe8")
const wash_5 = preload("uid://dxiijg2x2uwuu")
const wash_6 = preload("uid://db6j6282uurql")
const wash_skin_1 = preload("uid://op3e7wjctb0x")
const wash_skin_2 = preload("uid://ca6fps2bmm2dh")
const wash_skin_3 = preload("uid://dpk5dxilb5a5p")
const wash_skin_4 = preload("uid://cfkpvqt6kpat4")
const wash_skin_5 = preload("uid://dthjfc78ov4f7")
const wash_skin_6 = preload("uid://bq1b72yw6huml")

const WASH_SKIN_1 = preload("uid://f3nkv40voev4")
const WASH_SKIN_2 = preload("uid://cknw3ypbh6drm")
const WASH_SKIN_3 = preload("uid://bg5he825lpy8a")
const WASH_SKIN_4 = preload("uid://cdu8o7mif5sdp")
const WASH_SKIN_5 = preload("uid://cwon4niajsh6b")
const WASH_SKIN_6 = preload("uid://dmkf4ye1a17e6")
const WASH_0 = preload("uid://65p10q4uctjk")
const WASH_1 = preload("uid://crwcgahvs10t8")
const WASH_2 = preload("uid://dicam4v8ejj7q")
const WASH_3 = preload("uid://dscld865o5dd8")
const WASH_4 = preload("uid://btgkavcbawqog")
const WASH_5 = preload("uid://w5d4ny28wrwr")
const WASH_6 = preload("uid://cirnwj5oc21ox")



var customersWaiting : Array[Customer] = []
var availableWashingMachines: Array[WashingMachine]
var current_coins = 0.0
var unlockedWashingMachinesSkins: Array[CompressedTexture2D]
var unlockedWashingMachinesOGSkins: Array[CompressedTexture2D]

var level1MachinesUnlocked: int = 0
var level2MachinesUnlocked: int = 0
var level3MachinesUnlocked: int = 0
var level4MachinesUnlocked: int = 0
var level5MachinesUnlocked: int = 0
var level6MachinesUnlocked: int = 0

var islevel1MachinesUnlocked: bool = false
var islevel2MachinesUnlocked: bool = false
var islevel3MachinesUnlocked: bool = false
var islevel4MachinesUnlocked: bool = false
var islevel5MachinesUnlocked: bool = false
var islevel6MachinesUnlocked: bool = false
var islevel1SkinMachinesUnlocked: bool = false
var islevel2SkinMachinesUnlocked: bool = false
var islevel3SkinMachinesUnlocked: bool = false
var islevel4SkinMachinesUnlocked: bool = false
var islevel5SkinMachinesUnlocked: bool = false
var islevel6SkinMachinesUnlocked: bool = false
func _ready() -> void:
	on_level_up.connect(_on_level_up)
	current_coins = get_upgrade_cost(0)
	
	

func get_upgrade_cost(washer_level) -> float:
	if my_washers != 0:
		washer_level += 1
	var costoBase = 0
	match washer_level:
		1:
			costoBase = 25
		2:
			costoBase = 113
		3:
			costoBase = 506
		4:
			costoBase = 2200
		5:
			costoBase = 10000
		6:
			costoBase = 86000
	
	return costoBase * upgrade_percentage * washer_level

func format_coins(amount: float) -> String:
	var suffixes: Array = ["","K","M","B","T","Q"]
	var index := 0
	var display_amount := float(amount)
	
	while display_amount >= 1000 and index < suffixes.size() -1:
		display_amount /= 1000
		index += 1
		
	return str(round_to_one_decimal(display_amount)) + suffixes[index]
	
func round_to_one_decimal(amount: float) -> float:
	return floor(amount * 100)/100.0

func _on_level_up(washer: WashingMachine) -> void:
	assign_customer(washer)
	checkUnlockedSkins()

func lookForWasher(customer: Customer) -> void:
	for washer in availableWashingMachines:
		assign_customer(washer)

func assign_customer(washer: WashingMachine) -> void:
	if customersWaiting[0].isWaitingWasher && !washer.isOccupied && customersWaiting.size() >= 1:
		washer.isOccupied = true
		var customer = customersWaiting.pop_front()
		on_move_line.emit()
		on_moveCustomerToWashingMachine.emit(washer,customer)

func checkUnlockedSkins() -> void:
	if level1MachinesUnlocked == 1 && !islevel1MachinesUnlocked:
		unlockedWashingMachinesSkins.append(wash_1)
		unlockedWashingMachinesOGSkins.append(WASH_1)
		islevel1MachinesUnlocked = true
	if level2MachinesUnlocked == 1 && !islevel2MachinesUnlocked:
		unlockedWashingMachinesSkins.append(wash_2)
		unlockedWashingMachinesOGSkins.append(WASH_2)
		if(isAIAssetActive):
			on_skin_unlocked.emit(wash_2)
		else:
			on_skin_unlocked.emit(WASH_2)
		islevel2MachinesUnlocked = true
	if level3MachinesUnlocked == 1 && !islevel3MachinesUnlocked:
		unlockedWashingMachinesSkins.append(wash_3)
		unlockedWashingMachinesOGSkins.append(WASH_3)
		if(isAIAssetActive):
			on_skin_unlocked.emit(wash_3)
		else:
			on_skin_unlocked.emit(WASH_3)
		islevel3MachinesUnlocked = true
	if level4MachinesUnlocked == 1 && !islevel4MachinesUnlocked:
		unlockedWashingMachinesSkins.append(wash_4)
		unlockedWashingMachinesOGSkins.append(WASH_4)
		if(isAIAssetActive):
			on_skin_unlocked.emit(wash_4)
		else:
			on_skin_unlocked.emit(WASH_4)
		islevel4MachinesUnlocked = true
	if level5MachinesUnlocked == 1 && !islevel5MachinesUnlocked:
		unlockedWashingMachinesSkins.append(wash_5)
		unlockedWashingMachinesOGSkins.append(WASH_5)
		if(isAIAssetActive):
			on_skin_unlocked.emit(wash_5)
		else:
			on_skin_unlocked.emit(WASH_5)
		islevel5MachinesUnlocked = true
	if level6MachinesUnlocked == 1 && !islevel6MachinesUnlocked:
		unlockedWashingMachinesSkins.append(wash_6)
		unlockedWashingMachinesOGSkins.append(WASH_6)
		if(isAIAssetActive):
			on_skin_unlocked.emit(wash_6)
		else:
			on_skin_unlocked.emit(WASH_6)
		islevel6MachinesUnlocked = true

	if level1MachinesUnlocked == 8 && !islevel1SkinMachinesUnlocked:
		unlockedWashingMachinesSkins.append(wash_skin_1)
		unlockedWashingMachinesOGSkins.append(WASH_SKIN_1)
		if(isAIAssetActive):
			on_skin_unlocked.emit(wash_skin_1)
		else:
			on_skin_unlocked.emit(WASH_SKIN_1)
		islevel1SkinMachinesUnlocked = true
	if level2MachinesUnlocked == 8 && !islevel2SkinMachinesUnlocked:
		unlockedWashingMachinesSkins.append(wash_skin_2)
		unlockedWashingMachinesOGSkins.append(WASH_SKIN_2)
		if(isAIAssetActive):
			on_skin_unlocked.emit(wash_skin_2)
		else:
			on_skin_unlocked.emit(WASH_SKIN_2)
		islevel2SkinMachinesUnlocked = true
	if level3MachinesUnlocked == 8 && !islevel3SkinMachinesUnlocked:
		unlockedWashingMachinesSkins.append(wash_skin_3)
		unlockedWashingMachinesOGSkins.append(WASH_SKIN_3)
		if(isAIAssetActive):
			on_skin_unlocked.emit(wash_skin_3)
		else:
			on_skin_unlocked.emit(WASH_SKIN_3)
		islevel3SkinMachinesUnlocked = true
	if level4MachinesUnlocked == 8 && !islevel4SkinMachinesUnlocked:
		unlockedWashingMachinesSkins.append(wash_skin_4)
		unlockedWashingMachinesOGSkins.append(WASH_SKIN_4)
		if(isAIAssetActive):
			on_skin_unlocked.emit(wash_skin_4)
		else:
			on_skin_unlocked.emit(WASH_SKIN_4)
		islevel4SkinMachinesUnlocked = true
	if level5MachinesUnlocked == 8 && !islevel5SkinMachinesUnlocked:
		unlockedWashingMachinesSkins.append(wash_skin_5)
		unlockedWashingMachinesOGSkins.append(WASH_SKIN_5)
		if(isAIAssetActive):
			on_skin_unlocked.emit(wash_skin_5)
		else:
			on_skin_unlocked.emit(WASH_SKIN_5)
		islevel5SkinMachinesUnlocked = true
	if level6MachinesUnlocked == 8 && !islevel6SkinMachinesUnlocked:
		unlockedWashingMachinesSkins.append(wash_skin_6)
		unlockedWashingMachinesOGSkins.append(WASH_SKIN_6)
		if(isAIAssetActive):
			on_skin_unlocked.emit(wash_skin_6)
		else:
			on_skin_unlocked.emit(WASH_SKIN_6)
		islevel6SkinMachinesUnlocked = true
	

func play_coin_vfx(spawn_pos: Vector2) -> void:
	var coin_instance = COIN_VFX.instantiate()
	get_tree().root.add_child(coin_instance)
	#SoundManager.play_coins()
	var new_pos := Vector2(spawn_pos.x + 50, spawn_pos.y - 60)
	coin_instance.global_position = new_pos
	coin_instance.emitting = true
	coin_instance.finished.connect(func(): coin_instance.queue_free())
	
func toogleAIAsset() -> void:
	isAIAssetActive = !isAIAssetActive
	on_AIAssetChange.emit()
