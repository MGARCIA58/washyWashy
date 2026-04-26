extends Node
class_name CustomerManager

signal on_customer_spawn()

@export var customerScene: PackedScene
@export var customerBodies: Array[CustomerBodies]
@export var spawn_marker: Marker2D
@export var corner_marker: Marker2D
@export var front_marker: Marker2D
@export var waiting_marker: Marker2D
@export var timer: Timer
@export var limitCustomers = 20
@export var lane_a: Marker2D
@export var lane_a_2: Marker2D
@export var lane_a_3: Marker2D
@export var lane_a_4: Marker2D
@export var lane_b_2: Marker2D
@export var lane_c: Marker2D
@export var lane_c_2: Marker2D
@export var lane_c_3: Marker2D
@export var laneAMachines: Array[WashingMachine]
@export var laneA2Machines: Array[WashingMachine]
@export var laneA3Machines: Array[WashingMachine]
@export var laneA4Machines: Array[WashingMachine]
@export var laneBMachines: Array[WashingMachine]
@export var laneB2Machines: Array[WashingMachine]
@export var laneCMachines: Array[WashingMachine]
@export var laneC2Machines: Array[WashingMachine]
@export var laneC3Machines: Array[WashingMachine]
@export var exit_marker: Marker2D

func _ready() -> void:
	spawn_customer()
	GameManager.on_move_line.connect(_on_move_line)
	GameManager.on_moveCustomerToWashingMachine.connect(_on_moveCustomerToWashingMachine)

func spawn_customer() -> void:
	var customer: Customer = customerScene.instantiate()
	add_child(customer)
	
	#Get random sprites
	var assetData: CustomerBodies = customerBodies.pick_random()
	customer.setAssets(assetData)
	
	#Get random quantity
	var quantity: int = randi_range(2,6)
	customer.initCustomer(quantity)
	
	customer.position = spawn_marker.position
	
	GameManager.customersWaiting.append(customer)
	moveToLine(customer)
	on_customer_spawn.emit(GameManager.customersWaiting)
	
func moveToLine(customer: Customer) -> void:
	var index = GameManager.customersWaiting.find(customer)
	var timeAnimation = 1
	match index:
		0:
			customer.change_state(GameManager.character_state.WALKING_DIRTY)
			await customer.moveCharacter(corner_marker.position, timeAnimation)
			
			customer.flipAsset()
			await customer.moveCharacter(front_marker.position, timeAnimation)
			
			customer.change_state(GameManager.character_state.WALKING_DIRTY_BACK)
			await customer.moveCharacter(waiting_marker.position, timeAnimation)
			customer.isWaitingWasher = true
			GameManager.lookForWasher(customer)
		1,2:
			customer.change_state(GameManager.character_state.WALKING_DIRTY)
			await customer.moveCharacter(corner_marker.position, timeAnimation)
			
			customer.flipAsset()
			await customer.moveCharacter(front_marker.position, timeAnimation)
			
			customer.change_state(GameManager.character_state.WALKING_DIRTY_BACK)
			await customer.moveCharacter(Vector2(GameManager.customersWaiting[index-1].finalPosition.x-50,GameManager.customersWaiting[index-1].finalPosition.y+30), timeAnimation)
			
		3:
			customer.change_state(GameManager.character_state.WALKING_DIRTY)
			await customer.moveCharacter(corner_marker.position, timeAnimation)
			
			customer.flipAsset()
			await customer.moveCharacter(front_marker.position, timeAnimation)
			
			customer.change_state(GameManager.character_state.WALKING_DIRTY_BACK)
			
		4,5,6,7,8,_:
			customer.change_state(GameManager.character_state.WALKING_DIRTY)
			await customer.moveCharacter(corner_marker.position, timeAnimation)
			
			customer.flipAsset()
			var to_position: Vector2
			if  index < GameManager.customersWaiting.size():
				to_position = Vector2(GameManager.customersWaiting[index-1].finalPosition.x-80,GameManager.customersWaiting[index-1].finalPosition.y-50)
			else:
				to_position = Vector2(front_marker.position.x-(80*index-4),front_marker.position.y-(50*index-4))
			await customer.moveCharacter(to_position, timeAnimation)
			
			customer.change_state(GameManager.character_state.WAITING_DIRTY)
			
func _on_timer_timeout() -> void:
	if GameManager.customersWaiting.size() < limitCustomers:
		spawn_customer()
	else:
		timer.stop()

func _on_move_line() -> void:
	for customer in GameManager.customersWaiting:
		var index = GameManager.customersWaiting.find(customer)
		var timeAnimation = 1
		match index:
			0:
				customer.change_state(GameManager.character_state.WALKING_DIRTY_BACK)
				await customer.moveCharacter(waiting_marker.position, timeAnimation)
				customer.isWaitingWasher = true
				GameManager.lookForWasher(customer)
			1,2:
				customer.change_state(GameManager.character_state.WALKING_DIRTY_BACK)
				await customer.moveCharacter(Vector2(GameManager.customersWaiting[index-1].finalPosition.x-50,GameManager.customersWaiting[index-1].finalPosition.y+30), timeAnimation)
				
			3:
				customer.change_state(GameManager.character_state.WALKING_DIRTY)
				await customer.moveCharacter(front_marker.position, timeAnimation)	
				customer.change_state(GameManager.character_state.WALKING_DIRTY_BACK)
				
			4,5,6,7,8,_:	
				customer.change_state(GameManager.character_state.WALKING_DIRTY)
				await customer.moveCharacter(Vector2(GameManager.customersWaiting[index-1].finalPosition.x-80,GameManager.customersWaiting[index-1].finalPosition.y-50), timeAnimation)
				customer.change_state(GameManager.character_state.WAITING_DIRTY)
	if GameManager.customersWaiting.size() < limitCustomers:
		spawn_customer()


func _on_moveCustomerToWashingMachine(washer: WashingMachine, customer: Customer) -> void:
	var timeAnimation = 1
	var laneChose: String
	if laneAMachines.find(washer) >= 0:
		laneChose = 'A'
	if laneA2Machines.find(washer) >= 0:
		laneChose = 'A2'
	if laneA3Machines.find(washer) >= 0:
		laneChose = 'A3'
	if laneA4Machines.find(washer) >= 0:
		laneChose = 'A4'
	if laneBMachines.find(washer) >= 0:
		laneChose = 'B'
	if laneB2Machines.find(washer) >= 0:
		laneChose = 'B2'
	if laneCMachines.find(washer) >= 0:
		laneChose = 'C'
	if laneC2Machines.find(washer) >= 0:
		laneChose = 'C2'
	if laneC3Machines.find(washer) >= 0:
		laneChose = 'C3'
	match laneChose:
		'A':
			customer.change_state(GameManager.character_state.WALKING_DIRTY)
			customer.flipAsset()
			await customer.moveCharacter(lane_a.position, timeAnimation)
			await customer.moveCharacter(Vector2(washer.position.x-75,washer.position.y), timeAnimation)
			customer.flipAsset()
		'A2':
			customer.change_state(GameManager.character_state.WALKING_DIRTY)
			customer.flipAsset()
			await customer.moveCharacter(lane_a.position, timeAnimation)
			await customer.moveCharacter(lane_a_2.position, timeAnimation)
			await customer.moveCharacter(Vector2(washer.position.x-75,washer.position.y), timeAnimation)
			customer.flipAsset()
		'A3':
			customer.change_state(GameManager.character_state.WALKING_DIRTY)
			customer.flipAsset()
			await customer.moveCharacter(lane_a.position, timeAnimation)
			customer.flipAsset()
			await customer.moveCharacter(lane_a_3.position, timeAnimation)
			await customer.moveCharacter(Vector2(washer.position.x-75,washer.position.y), timeAnimation)
		'A4':
			customer.change_state(GameManager.character_state.WALKING_DIRTY)
			customer.flipAsset()
			await customer.moveCharacter(lane_a.position, timeAnimation)
			customer.flipAsset()
			await customer.moveCharacter(lane_a_4.position, timeAnimation)
			await customer.moveCharacter(Vector2(washer.position.x-75,washer.position.y), timeAnimation)
		'B':
			customer.change_state(GameManager.character_state.WALKING_DIRTY)
			await customer.moveCharacter(Vector2(washer.position.x-75,washer.position.y), timeAnimation)
		'B2':
			customer.change_state(GameManager.character_state.WALKING_DIRTY)
			await customer.moveCharacter(lane_b_2.position, timeAnimation)
			await customer.moveCharacter(Vector2(washer.position.x-75,washer.position.y), timeAnimation)
		'C':
			customer.change_state(GameManager.character_state.WALKING_DIRTY)
			await customer.moveCharacter(lane_c.position, timeAnimation)
			await customer.moveCharacter(Vector2(washer.position.x-75,washer.position.y), timeAnimation)
		'C2':
			customer.change_state(GameManager.character_state.WALKING_DIRTY)
			await customer.moveCharacter(lane_c.position, timeAnimation)
			await customer.moveCharacter(lane_c_2.position, timeAnimation)
			await customer.moveCharacter(Vector2(washer.position.x-75,washer.position.y), timeAnimation)
		'C3':
			customer.change_state(GameManager.character_state.WALKING_DIRTY)
			await customer.moveCharacter(lane_c.position, timeAnimation)
			await customer.moveCharacter(lane_c_3.position, timeAnimation)
			await customer.moveCharacter(Vector2(washer.position.x-75,washer.position.y), timeAnimation)
	
	customer.isWaitingWasher = false
	washer.customerAssigned = customer
	washer.wash()
	
	
func _on_moveCustomerToExit(washer: WashingMachine, customer: Customer) -> void:
	var timeAnimation = 1
	var laneChose: String
	if laneAMachines.find(washer) >= 0:
		laneChose = 'A'
	if laneA2Machines.find(washer) >= 0:
		laneChose = 'A2'
	if laneA3Machines.find(washer) >= 0:
		laneChose = 'A3'
	if laneA4Machines.find(washer) >= 0:
		laneChose = 'A4'
	if laneBMachines.find(washer) >= 0:
		laneChose = 'B'
	if laneB2Machines.find(washer) >= 0:
		laneChose = 'B2'
	if laneCMachines.find(washer) >= 0:
		laneChose = 'C'
	if laneC2Machines.find(washer) >= 0:
		laneChose = 'C2'
	if laneC3Machines.find(washer) >= 0:
		laneChose = 'C3'
	match laneChose:
		'A':
			customer.change_state(GameManager.character_state.WALKING_DIRTY)
			customer.flipAsset()
			await customer.moveCharacter(lane_a.position, timeAnimation)
			await customer.moveCharacter(exit_marker.position, timeAnimation)
			customer.flipAsset()
		'A2':
			customer.change_state(GameManager.character_state.WALKING_DIRTY)
			customer.flipAsset()
			await customer.moveCharacter(lane_a.position, timeAnimation)
			await customer.moveCharacter(lane_a_2.position, timeAnimation)
			await customer.moveCharacter(Vector2(washer.position.x-75,washer.position.y), timeAnimation)
			customer.flipAsset()
		'A3':
			customer.change_state(GameManager.character_state.WALKING_DIRTY)
			customer.flipAsset()
			await customer.moveCharacter(lane_a.position, timeAnimation)
			customer.flipAsset()
			await customer.moveCharacter(lane_a_3.position, timeAnimation)
			await customer.moveCharacter(Vector2(washer.position.x-75,washer.position.y), timeAnimation)
		'A4':
			customer.change_state(GameManager.character_state.WALKING_DIRTY)
			customer.flipAsset()
			await customer.moveCharacter(lane_a.position, timeAnimation)
			customer.flipAsset()
			await customer.moveCharacter(lane_a_4.position, timeAnimation)
			await customer.moveCharacter(Vector2(washer.position.x-75,washer.position.y), timeAnimation)
		'B':
			customer.change_state(GameManager.character_state.WALKING_DIRTY)
			await customer.moveCharacter(Vector2(washer.position.x-75,washer.position.y), timeAnimation)
		'B2':
			customer.change_state(GameManager.character_state.WALKING_DIRTY)
			await customer.moveCharacter(lane_b_2.position, timeAnimation)
			await customer.moveCharacter(Vector2(washer.position.x-75,washer.position.y), timeAnimation)
		'C':
			customer.change_state(GameManager.character_state.WALKING_DIRTY)
			await customer.moveCharacter(lane_c.position, timeAnimation)
			await customer.moveCharacter(Vector2(washer.position.x-75,washer.position.y), timeAnimation)
		'C2':
			customer.change_state(GameManager.character_state.WALKING_DIRTY)
			await customer.moveCharacter(lane_c.position, timeAnimation)
			await customer.moveCharacter(lane_c_2.position, timeAnimation)
			await customer.moveCharacter(Vector2(washer.position.x-75,washer.position.y), timeAnimation)
		'C3':
			customer.change_state(GameManager.character_state.WALKING_DIRTY)
			await customer.moveCharacter(lane_c.position, timeAnimation)
			await customer.moveCharacter(lane_c_3.position, timeAnimation)
			await customer.moveCharacter(Vector2(washer.position.x-75,washer.position.y), timeAnimation)
	
	
