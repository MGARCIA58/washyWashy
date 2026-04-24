extends Node2D
class_name Customer
@export var body: Sprite2D
@export var animation_player: AnimationPlayer

var quantity_laundry
var waiting_dirty: Texture2D
var waiting: Texture2D
var walking_clean: Texture2D
var walking_dirty: Texture2D
var walking_dirty_back: Texture2D
var loading_laundry: Texture2D
var finalPosition: Vector2

func initCustomer(quantity: int) -> void:
	quantity_laundry = quantity
	
func setAssets(customerBodies: CustomerBodies) -> void:
	waiting_dirty = customerBodies.waiting_dirty
	waiting = customerBodies.waiting
	walking_clean = customerBodies.walking_clean
	walking_dirty = customerBodies.walking_dirty
	walking_dirty_back = customerBodies.walking_dirty_back
	loading_laundry = customerBodies.loading_laundry
	body.texture = waiting_dirty
	flipAsset()

func change_state(newState: GameManager.character_state) -> void:
	match newState:
		GameManager.character_state.WAITING:
			body.texture = waiting
			animation_player.play("Waiting")
		GameManager.character_state.WAITING_DIRTY:
			body.texture = waiting_dirty
			animation_player.play("Waiting")
		GameManager.character_state.WALKING_CLEAN:
			body.texture = walking_clean
			animation_player.play("Walking")
		GameManager.character_state.WALKING_DIRTY:
			body.texture = walking_dirty
			animation_player.play("Walking")
		GameManager.character_state.WALKING_DIRTY_BACK:
			body.texture = walking_dirty_back
			animation_player.play("Waiting")
		GameManager.character_state.LOADING_LAUNDRY:
			body.texture = loading_laundry
			animation_player.play("Waiting")
		_:
			body.texture = waiting
			animation_player.play("Waiting")

func moveCharacter(position: Vector2, timeAnimation: int) -> void:
	finalPosition = position
	var tween := create_tween()
	tween.tween_property(self, "position", position, timeAnimation)
	await tween.finished
	

func flipAsset():
	body.flip_h = !body.flip_h
