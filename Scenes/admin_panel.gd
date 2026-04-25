extends Panel
class_name AdminPanel

@export var inspector_image: HBoxContainer
@export var level_container: HBoxContainer
@export var machine_stats_container: VBoxContainer
@export var upgrade_card: PanelContainer

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
var current_washer: WashingMachine

func _ready() -> void:
	GameManager.on_washer_selected.connect(_on_washing_machine_on_washer_selected)
	GameManager.on_level_up.connect(_on_level_up)
	total_machines_quantity_label.text = str(GameManager.my_washers)
	level_1_machines_quantity.text = str(GameManager.level_1_machines_quantity)
	level_2_machines_quantity.text = str(GameManager.level_2_machines_quantity)
	level_3_machines_quantity.text = str(GameManager.level_3_machines_quantity)
	level_4_machines_quantity.text = str(GameManager.level_4_machines_quantity)
	level_5_machines_quantity.text = str(GameManager.level_5_machines_quantity)
	level_6_machines_quantity.text = str(GameManager.level_6_machines_quantity)

func _on_washing_machine_on_washer_selected(washer: WashingMachine) -> void:
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
	coin_quantity.text = str(washer.coin_quantity)
	time_quantity.text = str(washer.time_quantity)
	wash_machine_asset.texture = washer.get_wash_texture_when_level_up()
	var arrayCoinTime = washer.get_coin_time_when_level_up()
	upgrade_coin_quantity.text = str(arrayCoinTime[0])
	upgrade_time_quantity.text = str(arrayCoinTime[1])
	button.text = GameManager.format_coins(GameManager.get_upgrade_cost(washer.wash_level))

func _on_level_up() -> void:
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
		current_washer.level_up()
