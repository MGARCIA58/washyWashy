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


func _ready() -> void:
		spawn_customer()
		GameManager.on_move_line.connect(_on_move_line)

func spawn_customer() -> void:
	var customer: Customer = customerScene.instantiate()
	add_child(customer)
	
	#Get random sprites
	var assetData: CustomerBodies = customerBodies.pick_random()
	customer.setAssets(assetData)
	
	#Get random quantity
	var quantity: int = randi_range(1,5)
	customer.initCustomer(quantity)
	
	customer.position = spawn_marker.position
	
	GameManager.customersWaiting.append(customer)
	moveToLine(customer)
	on_customer_spawn.emit(GameManager.customersWaiting)
	
func moveToLine(customer: Customer) -> void:
	var index = GameManager.customersWaiting.find(customer)
	var timeAnimation = 5
	match index:
		0:
			customer.change_state(GameManager.character_state.WALKING_DIRTY)
			await customer.moveCharacter(corner_marker.position, timeAnimation)
			
			customer.flipAsset()
			await customer.moveCharacter(front_marker.position, timeAnimation)
			
			customer.change_state(GameManager.character_state.WALKING_DIRTY_BACK)
			await customer.moveCharacter(waiting_marker.position, timeAnimation-2)
			customer.isWaitingWasher = true
			GameManager.lookForWasher(customer)
		1,2:
			customer.change_state(GameManager.character_state.WALKING_DIRTY)
			await customer.moveCharacter(corner_marker.position, timeAnimation)
			
			customer.flipAsset()
			await customer.moveCharacter(front_marker.position, timeAnimation)
			
			customer.change_state(GameManager.character_state.WALKING_DIRTY_BACK)
			await customer.moveCharacter(Vector2(GameManager.customersWaiting[index-1].finalPosition.x-50,GameManager.customersWaiting[index-1].finalPosition.y+30), timeAnimation-2)
			
		3:
			customer.change_state(GameManager.character_state.WALKING_DIRTY)
			await customer.moveCharacter(corner_marker.position, timeAnimation)
			
			customer.flipAsset()
			await customer.moveCharacter(front_marker.position, timeAnimation)
			
			customer.change_state(GameManager.character_state.WALKING_DIRTY_BACK)
			
		4,5,6,7,8:
			customer.change_state(GameManager.character_state.WALKING_DIRTY)
			await customer.moveCharacter(corner_marker.position, timeAnimation)
			
			customer.flipAsset()
			var to_position: Vector2
			if  index < GameManager.customersWaiting.size():
				to_position = Vector2(GameManager.customersWaiting[index-1].finalPosition.x-80,GameManager.customersWaiting[index-1].finalPosition.y-40)
			else:
				to_position = Vector2(front_marker.position.x-(80*index-4),front_marker.position.y-(40*index-4))
			await customer.moveCharacter(to_position, timeAnimation-2)
			
			customer.change_state(GameManager.character_state.WAITING_DIRTY)
			
func _on_timer_timeout() -> void:
	if GameManager.customersWaiting.size() < 9:
		spawn_customer()
	else:
		timer.stop()

func _on_move_line() -> void:
	for customer in GameManager.customersWaiting:
		var index = GameManager.customersWaiting.find(customer)
		var timeAnimation = 3
		match index:
			0:
				customer.change_state(GameManager.character_state.WALKING_DIRTY_BACK)
				await customer.moveCharacter(waiting_marker.position, timeAnimation)
				customer.isWaitingWasher = true
				GameManager.lookForWasher(customer)
			1,2:
				customer.change_state(GameManager.character_state.WALKING_DIRTY_BACK)
				await customer.moveCharacter(Vector2(GameManager.customersWaiting[index-1].finalPosition.x-50,GameManager.customersWaiting[index-1].finalPosition.y+30), timeAnimation-2)
				
			3:
				customer.change_state(GameManager.character_state.WALKING_DIRTY)
				await customer.moveCharacter(front_marker.position, timeAnimation)	
				customer.change_state(GameManager.character_state.WALKING_DIRTY_BACK)
				
			4,5,6,7,8:	
				customer.change_state(GameManager.character_state.WALKING_DIRTY)
				await customer.moveCharacter(Vector2(GameManager.customersWaiting[index-1].finalPosition.x-80,GameManager.customersWaiting[index-1].finalPosition.y-40), timeAnimation-2)
				customer.change_state(GameManager.character_state.WAITING_DIRTY)
	if GameManager.customersWaiting.size() < 9:
		spawn_customer()
