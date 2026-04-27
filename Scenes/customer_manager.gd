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
@export var exit_marker: Marker2D
@export var front_2_marker: Marker2D
@export var destroy_marker: Marker2D
@export var laneAMachines: Array[WashingMachine]
@export var laneA2Machines: Array[WashingMachine]
@export var laneA3Machines: Array[WashingMachine]
@export var laneA4Machines: Array[WashingMachine]
@export var laneBMachines: Array[WashingMachine]
@export var laneB2Machines: Array[WashingMachine]
@export var laneB3Machines: Array[WashingMachine]
@export var laneCMachines: Array[WashingMachine]
@export var laneC2Machines: Array[WashingMachine]
@export var laneC3Machines: Array[WashingMachine]
@export var washing_machine: WashingMachine
@export var washing_machine_2: WashingMachine
@export var washing_machine_3: WashingMachine
@export var washing_machine_4: WashingMachine
@export var washing_machine_5: WashingMachine
@export var washing_machine_6: WashingMachine
@export var washing_machine_7: WashingMachine
@export var washing_machine_8: WashingMachine
@export var washing_machine_9: WashingMachine
@export var washing_machine_10: WashingMachine
@export var washing_machine_11: WashingMachine
@export var washing_machine_12: WashingMachine
@export var washing_machine_13: WashingMachine
@export var washing_machine_14: WashingMachine
@export var washing_machine_15: WashingMachine
@export var washing_machine_16: WashingMachine


func _ready() -> void:
	spawn_customer()
	GameManager.on_move_line.connect(_on_move_line)
	GameManager.on_moveCustomerToWashingMachine.connect(_on_moveCustomerToWashingMachine)
	GameManager.on_moveCustomerToExit.connect(_on_moveCustomerToExit)

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
			showWashingMachines()
			customer.isWaitingWasher = true
			GameManager.lookForWasher(customer)
		1,2,3:
			customer.change_state(GameManager.character_state.WALKING_DIRTY)
			await customer.moveCharacter(corner_marker.position, timeAnimation)
			
			customer.flipAsset()
			await customer.moveCharacter(front_marker.position, timeAnimation)
			
			customer.change_state(GameManager.character_state.WALKING_DIRTY_BACK)
			await customer.moveCharacter(Vector2(GameManager.customersWaiting[index-1].finalPosition.x-50,GameManager.customersWaiting[index-1].finalPosition.y+30), timeAnimation)
			
		4:
			customer.change_state(GameManager.character_state.WALKING_DIRTY)
			await customer.moveCharacter(corner_marker.position, timeAnimation)
			
			customer.flipAsset()
			await customer.moveCharacter(front_marker.position, timeAnimation)
			
			customer.change_state(GameManager.character_state.WALKING_DIRTY_BACK)
			
		5,6,7,8,_:
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
				await customer.moveCharacter(waiting_marker.position, timeAnimation - 0.5)
				customer.isWaitingWasher = true
				GameManager.lookForWasher(customer)
			1,2,3:
				customer.change_state(GameManager.character_state.WALKING_DIRTY_BACK)
				await customer.moveCharacter(Vector2(GameManager.customersWaiting[index-1].finalPosition.x-50,GameManager.customersWaiting[index-1].finalPosition.y+30), timeAnimation)
				
			4:
				customer.change_state(GameManager.character_state.WALKING_DIRTY)
				await customer.moveCharacter(front_marker.position, timeAnimation)	
				customer.change_state(GameManager.character_state.WALKING_DIRTY_BACK)
				
			5,6,7,8,_:	
				customer.change_state(GameManager.character_state.WALKING_DIRTY)
				await customer.moveCharacter(Vector2(GameManager.customersWaiting[index-1].finalPosition.x-80,GameManager.customersWaiting[index-1].finalPosition.y-50), timeAnimation)
				customer.change_state(GameManager.character_state.WAITING_DIRTY)
	if GameManager.customersWaiting.size() < limitCustomers:
		spawn_customer()

func showWashingMachines() -> void:
	washing_machine.show()
	washing_machine_2.show()
	washing_machine_3.show()
	washing_machine_4.show()
	washing_machine_5.show()
	washing_machine_6.show()
	washing_machine_7.show()
	washing_machine_8.show()
	washing_machine_9.show()
	washing_machine_10.show()
	washing_machine_11.show()
	washing_machine_12.show()
	washing_machine_13.show()
	washing_machine_14.show()
	washing_machine_15.show()
	washing_machine_16.show()

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
	if laneB3Machines.find(washer) >= 0:
		laneChose = 'B3'
	if laneCMachines.find(washer) >= 0:
		laneChose = 'C'
	if laneC2Machines.find(washer) >= 0:
		laneChose = 'C2'
	if laneC3Machines.find(washer) >= 0:
		laneChose = 'C3'
	customer.change_state(GameManager.character_state.WALKING_DIRTY)
	match laneChose:
		'A':
			customer.flipAsset()
			await customer.moveCharacter(lane_a.position, timeAnimation)
			await customer.moveCharacter(Vector2(washer.position.x-75,washer.position.y), timeAnimation)
			customer.flipAsset()
		'A2':
			customer.flipAsset()
			await customer.moveCharacter(lane_a.position, timeAnimation)
			customer.flipAsset()
			await customer.moveCharacter(lane_a_2.position, timeAnimation)
			customer.flipAsset()
			await customer.moveCharacter(Vector2(washer.position.x-75,washer.position.y), timeAnimation)
			customer.flipAsset()
		'A3':
			customer.flipAsset()
			await customer.moveCharacter(lane_a.position, timeAnimation)
			customer.flipAsset()
			await customer.moveCharacter(lane_a_3.position, timeAnimation)
			await customer.moveCharacter(Vector2(washer.position.x-75,washer.position.y), timeAnimation)
		'A4':
			customer.flipAsset()
			await customer.moveCharacter(lane_a.position, timeAnimation)
			customer.flipAsset()
			await customer.moveCharacter(lane_a_4.position, timeAnimation)
			await customer.moveCharacter(Vector2(washer.position.x-75,washer.position.y), timeAnimation)
		'B':
			await customer.moveCharacter(Vector2(washer.position.x-75,washer.position.y), timeAnimation)
		'B2':
			await customer.moveCharacter(lane_b_2.position, timeAnimation)
			await customer.moveCharacter(Vector2(washer.position.x-75,washer.position.y), timeAnimation)
		'B3':
			await customer.moveCharacter(Vector2(washer.position.x-75,washer.position.y), timeAnimation)
		'C':
			await customer.moveCharacter(lane_c.position, timeAnimation)
			await customer.moveCharacter(Vector2(washer.position.x-75,washer.position.y), timeAnimation)
		'C2':
			await customer.moveCharacter(lane_c.position, timeAnimation)
			await customer.moveCharacter(lane_c_2.position, timeAnimation)
			await customer.moveCharacter(Vector2(washer.position.x-75,washer.position.y), timeAnimation)
		'C3':
			await customer.moveCharacter(lane_c.position, timeAnimation)
			await customer.moveCharacter(lane_c_3.position, timeAnimation)
			await customer.moveCharacter(Vector2(washer.position.x-75,washer.position.y), timeAnimation)
	
	customer.isWaitingWasher = false
	washer.customerAssigned = customer
	customer.quantity_label.hide()
	customer.cloth_texture.hide()
	washer.wash()
	
	
func _on_moveCustomerToExit(washer: WashingMachine, customer: Customer) -> void:
	customer.change_state(GameManager.character_state.LOADING_LAUNDRY)
	await get_tree().create_timer(2.0).timeout
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
	if laneB3Machines.find(washer) >= 0:
		laneChose = 'B3'
	if laneCMachines.find(washer) >= 0:
		laneChose = 'C'
	if laneC2Machines.find(washer) >= 0:
		laneChose = 'C2'
	if laneC3Machines.find(washer) >= 0:
		laneChose = 'C3'
	customer.change_state(GameManager.character_state.WALKING_CLEAN)
	match laneChose:
		'A':
			await customer.moveCharacter(lane_a.position, timeAnimation)
			await customer.moveCharacter(exit_marker.position, timeAnimation)
			customer.flipAsset()
		'A2':
			await customer.moveCharacter(lane_a_2.position, timeAnimation)
			customer.flipAsset()
			await customer.moveCharacter(lane_a.position, timeAnimation)
			customer.flipAsset()
			await customer.moveCharacter(exit_marker.position, timeAnimation)
			customer.flipAsset()
		'A3':
			customer.flipAsset()
			await customer.moveCharacter(lane_a_3.position, timeAnimation)
			await customer.moveCharacter(lane_a.position, timeAnimation)
			customer.flipAsset()
			await customer.moveCharacter(exit_marker.position, timeAnimation)
			customer.flipAsset()
		'A4':
			customer.flipAsset()
			await customer.moveCharacter(lane_a_4.position, timeAnimation)
			await customer.moveCharacter(lane_a.position, timeAnimation)
			customer.flipAsset()
			await customer.moveCharacter(exit_marker.position, timeAnimation)
			customer.flipAsset()
		'B':
			await customer.moveCharacter(exit_marker.position, timeAnimation)
			customer.flipAsset()
		'B2':
			customer.flipAsset()
			await customer.moveCharacter(lane_b_2.position, timeAnimation)
			await customer.moveCharacter(exit_marker.position, timeAnimation)
		'B3':
			customer.flipAsset()
			await customer.moveCharacter(waiting_marker.position, timeAnimation)
			customer.flipAsset()
			await customer.moveCharacter(exit_marker.position, timeAnimation)
			customer.flipAsset()
		'C':
			customer.flipAsset()
			await customer.moveCharacter(lane_c.position, timeAnimation)
			await customer.moveCharacter(exit_marker.position, timeAnimation)
		'C2':
			customer.flipAsset()
			await customer.moveCharacter(lane_c_2.position, timeAnimation)
			await customer.moveCharacter(lane_c.position, timeAnimation)
			await customer.moveCharacter(exit_marker.position, timeAnimation)
		'C3':
			customer.flipAsset()
			await customer.moveCharacter(lane_c_3.position, timeAnimation)
			await customer.moveCharacter(lane_c.position, timeAnimation)
			await customer.moveCharacter(exit_marker.position, timeAnimation)
	customer.z_index +=1
	await customer.moveCharacter(front_2_marker.position, timeAnimation+1)
	customer.flipAsset()
	await customer.moveCharacter(destroy_marker.position, timeAnimation+2)
	await get_tree().create_timer(10.0).timeout
	if customer:
		customer.queue_free()
	
