extends Node

signal on_washer_selected(washer: WashingMachine)
signal on_level_up(washer: WashingMachine)
signal on_move_line()

enum character_state {WAITING, WAITING_DIRTY, WALKING_CLEAN, WALKING_DIRTY, WALKING_DIRTY_BACK, LOADING_LAUNDRY}

@export var level_1_machines_quantity: int = 0
@export var level_2_machines_quantity: int = 0
@export var level_3_machines_quantity: int = 0
@export var level_4_machines_quantity: int = 0
@export var level_5_machines_quantity: int = 0
@export var level_6_machines_quantity: int = 0
@export var my_washers: int = 0
@export var upgrade_percentage: float = 2.58
@export var waiting_marker: Marker2D

var customersWaiting : Array[Customer] = []
var availableWashingMachines: Array[WashingMachine]
var current_coins = 0.0

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

func lookForWasher(customer: Customer) -> void:
	for washer in availableWashingMachines:
		assign_customer(washer)

func assign_customer(washer: WashingMachine) -> void:
	if customersWaiting[0].isWaitingWasher && !washer.isOccupied && customersWaiting.size() >= 1:
		washer.isOccupied = true
		var timeAnimation = 5
		var customer = customersWaiting.pop_front()
		on_move_line.emit()
		customer.change_state(GameManager.character_state.WALKING_DIRTY)
		await customer.moveCharacter(Vector2(washer.position.x-80,washer.position.y+5), timeAnimation)
		customer.isWaitingWasher = false
		washer.customerAssigned = customer
		washer.wash()
