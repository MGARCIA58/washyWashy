extends Node
class_name CustomerManager

@export var customerScene: PackedScene
@export var customerBodies: Array[CustomerBodies]
@export var spawn_marker: Marker2D
@export var corner_marker: Marker2D
@export var front_marker: Marker2D
@export var waiting_marker: Marker2D

var customersWaiting : Array[Customer] = []

func _ready() -> void:
		spawn_customer()

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
	
	customersWaiting.append(customer)
	moveToLine(customer)
	
	
func moveToLine(customer: Customer) -> void:
	var index = customersWaiting.find(customer)
	var timeAnimation = 5
	match index:
		0:
			customer.change_state(GameManager.character_state.WALKING_DIRTY)
			await customer.moveCharacter(corner_marker.position, timeAnimation)
			
			customer.flipAsset()
			await customer.moveCharacter(front_marker.position, timeAnimation)
			
			customer.change_state(GameManager.character_state.WALKING_DIRTY_BACK)
			await customer.moveCharacter(waiting_marker.position, timeAnimation-2)
			
		1,2:
			customer.change_state(GameManager.character_state.WALKING_DIRTY)
			await customer.moveCharacter(corner_marker.position, timeAnimation)
			
			customer.flipAsset()
			await customer.moveCharacter(front_marker.position, timeAnimation)
			
			customer.change_state(GameManager.character_state.WALKING_DIRTY_BACK)
			await customer.moveCharacter(Vector2(customersWaiting[index-1].finalPosition.x-50,customersWaiting[index-1].finalPosition.y+30), timeAnimation-2)
			
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
			await customer.moveCharacter(Vector2(customersWaiting[index-1].finalPosition.x-80,customersWaiting[index-1].finalPosition.y-40), timeAnimation-2)
			
			customer.change_state(GameManager.character_state.WAITING_DIRTY)
			


func _on_timer_timeout() -> void:
	if customersWaiting.size() < 9:
		spawn_customer()
