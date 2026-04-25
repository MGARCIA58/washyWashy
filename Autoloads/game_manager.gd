extends Node

signal on_washer_selected(washer: WashingMachine)
signal on_level_up()

enum character_state {WAITING, WAITING_DIRTY, WALKING_CLEAN, WALKING_DIRTY, WALKING_DIRTY_BACK, LOADING_LAUNDRY}

@export var level_1_machines_quantity: int = 0
@export var level_2_machines_quantity: int = 0
@export var level_3_machines_quantity: int = 0
@export var level_4_machines_quantity: int = 0
@export var level_5_machines_quantity: int = 0
@export var level_6_machines_quantity: int = 0
@export var my_washers: int = 0
@export var upgrade_cost: float = 50
@export var upgrade_percentage: float = 1.5

var current_coins = 0.0

func get_upgrade_cost(washer_level) -> float:
	if my_washers != 0:
		washer_level += 1
	return upgrade_cost * upgrade_percentage * my_washers * washer_level

func format_coins(amount: float) -> String:
	var suffixes: Array = ["","K","M","B","T","Q"]
	var index := 0
	var display_amount := float(amount)
	
	while display_amount >= 1000 and index < suffixes.size() -1:
		display_amount /= 1000
		index += 1
		
	return "$" + str(round_to_one_decimal(display_amount)) + suffixes[index]
	
func round_to_one_decimal(amount: float) -> float:
	return floor(amount * 100)/100.0
