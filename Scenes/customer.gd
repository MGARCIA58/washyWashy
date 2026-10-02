extends Node2D
class_name Customer
@export var body: Sprite2D
@export var animation_player: AnimationPlayer
@export var quantity_label: Label
@export var cloth_texture: TextureRect

var quantity_laundry
var waiting_dirty: Texture2D
var waiting: Texture2D
var walking_clean: Texture2D
var walking_dirty: Texture2D
var walking_dirty_back: Texture2D
var loading_laundry: Texture2D
var og_waiting_dirty: Texture2D
var og_waiting: Texture2D
var og_walking_clean: Texture2D
var og_walking_dirty: Texture2D
var og_walking_dirty_back: Texture2D
var og_loading_laundry: Texture2D
var finalPosition: Vector2
var isWaitingWasher = false
var currentState: GameManager.character_state

func _ready() -> void:
	GameManager.on_AIAssetChange.connect(_setSkinOnAIAssetChange)

func initCustomer(quantity: int) -> void:
	quantity_laundry = quantity
	quantity_label.text = str(quantity)
	
func setAssets(customerBodies: CustomerBodies) -> void:
	waiting_dirty = customerBodies.waiting_dirty
	waiting = customerBodies.waiting
	walking_clean = customerBodies.walking_clean
	walking_dirty = customerBodies.walking_dirty
	walking_dirty_back = customerBodies.walking_dirty_back
	loading_laundry = customerBodies.loading_laundry
	og_waiting_dirty = customerBodies.og_waiting_dirty
	og_waiting = customerBodies.og_waiting
	og_walking_clean = customerBodies.og_walking_clean
	og_walking_dirty = customerBodies.og_walking_dirty
	og_walking_dirty_back = customerBodies.og_walking_dirty_back
	og_loading_laundry = customerBodies.og_loading_laundry
	body.texture = og_waiting
	if(GameManager.isAIAssetActive):
			body.texture = waiting_dirty
	flipAsset()

func change_state(newState: GameManager.character_state) -> void:
	currentState = newState
	match newState:
		GameManager.character_state.WAITING:
			body.texture = og_waiting
			if(GameManager.isAIAssetActive):
				body.texture = waiting
			animation_player.play("Waiting")
		GameManager.character_state.WAITING_DIRTY:
			body.texture = og_waiting_dirty
			if(GameManager.isAIAssetActive):
				body.texture = waiting_dirty
			animation_player.play("Waiting")
		GameManager.character_state.WALKING_CLEAN:
			body.texture = og_walking_clean
			if(GameManager.isAIAssetActive):
				body.texture = walking_clean
			animation_player.play("Walking")
		GameManager.character_state.WALKING_DIRTY:
			body.texture = og_walking_dirty
			if(GameManager.isAIAssetActive):
				body.texture = walking_dirty
			animation_player.play("Walking")
		GameManager.character_state.WALKING_DIRTY_BACK:
			body.texture = og_walking_dirty_back
			if(GameManager.isAIAssetActive):
				body.texture = walking_dirty_back
			animation_player.play("Waiting")
		GameManager.character_state.LOADING_LAUNDRY:
			body.texture = og_loading_laundry
			if(GameManager.isAIAssetActive):
				body.texture = loading_laundry
			animation_player.play("Waiting")
		_:
			body.texture = og_waiting
			if(GameManager.isAIAssetActive):
				body.texture = waiting
			animation_player.play("Waiting")

func moveCharacter(position: Vector2, timeAnimation: int) -> void:
	finalPosition = position
	var tween := create_tween()
	tween.tween_property(self, "position", position, timeAnimation)
	await tween.finished
	

func flipAsset():
	body.flip_h = !body.flip_h
	
func _setSkinOnAIAssetChange() -> void:
	change_state(currentState)
