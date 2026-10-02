extends Panel
class_name AdminPanel

@export var current_coins_label: Label
@export var inspector_image: HBoxContainer
@export var level_container: HBoxContainer
@export var machine_stats_container: VBoxContainer
@export var upgrade_card: PanelContainer
@export var skin_unlocked: Panel
@export var washer_unlocked: TextureRect

@export var current_wash_machine_texture: TextureRect
@export var level_label: Label
@export var coin_quantity: Label
@export var time_quantity: Label
@export var wash_machine_asset: TextureRect
@export var upgrade_coin_quantity: Label
@export var upgrade_time_quantity: Label
@export var button: Button
@export var total_machines_quantity_label: Label
@export var level_1_machines_quantity: Label
@export var level_2_machines_quantity: Label
@export var level_3_machines_quantity: Label
@export var level_4_machines_quantity: Label
@export var level_5_machines_quantity: Label
@export var level_6_machines_quantity: Label
@export var machine_spaces_quantity_label: Label
@export var customers_waiting_quantity_label: Label
@export var select_skin_left_button: TextureButton
@export var select_skin_right_button: TextureButton
@export var finish_game: Panel
@onready var config_panel: Panel = %ConfigPanel
@export var washOG_0: CompressedTexture2D
@export var wash_0: CompressedTexture2D
@onready var background: Node2D = %Background
@onready var background_2: Node2D = %Background2


var current_washer: WashingMachine
var last_washer: WashingMachine

func _ready() -> void:
	GameManager.on_washer_selected.connect(_on_washing_machine_on_washer_selected)
	GameManager.on_level_up.connect(_on_level_up)
	GameManager.on_skin_unlocked.connect(_on_skin_unlocked)
	GameManager.on_AIAssetChange.connect(_on_AIAssetChange)
	total_machines_quantity_label.text = str(GameManager.my_washers)
	level_1_machines_quantity.text = str(GameManager.level_1_machines_quantity)
	level_2_machines_quantity.text = str(GameManager.level_2_machines_quantity)
	level_3_machines_quantity.text = str(GameManager.level_3_machines_quantity)
	level_4_machines_quantity.text = str(GameManager.level_4_machines_quantity)
	level_5_machines_quantity.text = str(GameManager.level_5_machines_quantity)
	level_6_machines_quantity.text = str(GameManager.level_6_machines_quantity)
	if(GameManager.isAIAssetActive):
		current_wash_machine_texture.texture = wash_0
	else:
		current_wash_machine_texture.texture = washOG_0

func _process(_delta: float) -> void:
	current_coins_label.text = GameManager.format_coins(GameManager.current_coins)

func _on_washing_machine_on_washer_selected(washer: WashingMachine) -> void:
	SoundManager.play_washer_selected()
	if !last_washer:
		last_washer = washer
	if last_washer != washer:
		glow_off(last_washer)
		last_washer = washer
	glow_on(washer)
	current_washer = washer
	inspector_image.show()
	level_container.show()
	machine_stats_container.show()
	if washer.wash_level < 6:
		upgrade_card.show()
	else:
		upgrade_card.hide()
	
	current_wash_machine_texture.texture = washer.body.texture
	level_label.text = 'LEVEL %s' % str(washer.wash_level)
	coin_quantity.text = GameManager.format_coins(washer.coin_quantity)
	time_quantity.text = str(washer.time_quantity)
	wash_machine_asset.texture = washer.get_wash_texture_when_level_up()
	var arrayCoinTime = washer.get_coin_time_when_level_up()
	upgrade_coin_quantity.text = GameManager.format_coins(arrayCoinTime[0])
	upgrade_time_quantity.text = str(arrayCoinTime[1])
	button.text = GameManager.format_coins(GameManager.get_upgrade_cost(washer.wash_level))
	
func _on_AIAssetChange() -> void:
	if(GameManager.isAIAssetActive):
		background.visible = true
		background_2.visible = false
	else:
		background.visible = false
		background_2.visible = true
	if(not current_washer):
		if(GameManager.isAIAssetActive):
			current_wash_machine_texture.texture = wash_0
		else:
			current_wash_machine_texture.texture = washOG_0
		return
	if(current_washer.wash_level == 0):
		if(GameManager.isAIAssetActive):
			current_wash_machine_texture.texture = wash_0
		else:
			current_wash_machine_texture.texture = washOG_0
		return
		
	current_wash_machine_texture.texture = current_washer.body.texture

func _on_level_up(washer: WashingMachine) -> void:
	total_machines_quantity_label.text = str(GameManager.my_washers)
	level_1_machines_quantity.text = str(GameManager.level_1_machines_quantity)
	level_2_machines_quantity.text = str(GameManager.level_2_machines_quantity)
	level_3_machines_quantity.text = str(GameManager.level_3_machines_quantity)
	level_4_machines_quantity.text = str(GameManager.level_4_machines_quantity)
	level_5_machines_quantity.text = str(GameManager.level_5_machines_quantity)
	level_6_machines_quantity.text = str(GameManager.level_6_machines_quantity)

func _on_customer_manager_on_customer_spawn(customersWaiting: Array[Customer]) -> void:
	customers_waiting_quantity_label.text = str(customersWaiting.size())


func _on_button_pressed() -> void:
	if GameManager.current_coins >= GameManager.get_upgrade_cost(current_washer.wash_level):
		SoundManager.play_washer_bought()
		GameManager.current_coins -= GameManager.get_upgrade_cost(current_washer.wash_level)
		current_washer.level_up()

func glow_on(washingMachine: WashingMachine):
	# Increase raw values for glow
	washingMachine.body.self_modulate = Color(1.5, 1.5, 1.5, 1.25)

func glow_off(washingMachine: WashingMachine):
	# Return to normal
	washingMachine.body.self_modulate = Color(1, 1, 1, 1)

func _on_skin_unlocked(washingMachineSkinUnlocked: CompressedTexture2D) -> void:
	SoundManager.play_skin_unlocked()
	skin_unlocked.show()
	select_skin_left_button.show()
	select_skin_right_button.show()
	washer_unlocked.texture = washingMachineSkinUnlocked

func _on_button_thanks_pressed() -> void:
	skin_unlocked.hide()


func _on_select_skin_left_button_pressed() -> void:
	current_wash_machine_texture.texture = current_washer.previous_skin()


func _on_select_skin_right_button_pressed() -> void:
	current_wash_machine_texture.texture = current_washer.next_skin()


func _on_config_button_pressed() -> void:
	if config_panel.visible:
		config_panel.visible = false
	else:
		config_panel.visible = true


func _on_music_slider_value_changed(value: float) -> void:
	var sfx_index = AudioServer.get_bus_index("MusicBus")
	AudioServer.set_bus_volume_db(sfx_index, linear_to_db(value))


func _on_sfx_slider_value_changed(value: float) -> void:
	var sfx_index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(sfx_index, linear_to_db(value))


func _on_close_credits_button_pressed() -> void:
	finish_game.hide()


func _on_show_credits_button_pressed() -> void:
	if finish_game.visible:
		finish_game.visible = false
	else:
		finish_game.visible = true


func _on_close_config_button_pressed() -> void:
	config_panel.hide()


func _on_check_button_pressed() -> void:
	GameManager.toogleAIAsset()
