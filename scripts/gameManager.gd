extends Node

@onready var button = $"Monitor Button"
@onready var clicksCounter = $"Click Counter"
@onready var statsText = $Stats
@onready var timer = $Timer
@onready var shop = $Shop
@onready var shopItems = $Shop/Items.get_children()
@export var itemCosts: Array[int] = []
var buttonSize = 64
var counterPosition = 0
var shopPosition = 160

var time = 0.0
var clicks = 0
@export var clickIncrement = 1.0
@export var autoClicksPerSecond = 0.0
var shopOpen = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.timeout.connect(add_clicks)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	button.rotation = sin(time) / 10
	time += delta


# Animations for every animated node
func _physics_process(delta: float) -> void:
	button.size = Vector2(buttonSize, buttonSize)
	button.position = Vector2(100-buttonSize/2.0, 100-buttonSize/2.0)
	if buttonSize > 64.1: buttonSize -= delta*10*(buttonSize-64)
	else: buttonSize = 64
	
	clicksCounter.position.y = counterPosition
	if counterPosition > 0.1: counterPosition -= delta*5*counterPosition
	else: counterPosition = 0
	
	shop.position.y = shopPosition
	clicksCounter.position.x = (160-shopPosition)*-0.25
	if shopOpen and shopPosition > 0.1: shopPosition -= delta*15*shopPosition
	elif shopOpen: shopPosition = 0
	if !shopOpen and shopPosition < 159.9: shopPosition += delta*15*(160-shopPosition)
	elif !shopOpen: shopPosition = 160
	
	for item in shopItems:
		var icon = item.get_node("Icon")
		var iconSize = icon.size.x
		if iconSize > 32.1: iconSize -= delta*10*(iconSize-32)
		else: iconSize = 32
		icon.size = Vector2(iconSize, iconSize)
		icon.position = Vector2(15-(iconSize-32)/2, 8-(iconSize-32)/2)
		var iconRotation = icon.rotation
		if iconRotation > 0.01:
			icon.rotation -= delta*5*iconRotation
		else: iconRotation = 0


func shortenNumber(num):
	if round(num) == num:
		num = roundi(num)
	if num >= 1000000000:
		return str(floorf(num/100000000)/10) + "b"
	elif num >= 1000000:
		return str(floorf(num/100000)/10) + "m"
	elif num >= 1000:
		return str(floorf(num/100)/10) + "k"
	else:
		return str(num)


func _on_tv_clicked(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		add_clicks(clickIncrement)
		buttonSize = 72

func add_clicks(amount = autoClicksPerSecond):
	clicks += amount
	if round(clicks) == clicks:
		clicks = roundi(clicks)
	
	var clickDisplay = shortenNumber(clicks)
	
	if amount != 0:
		clicksCounter.text = clickDisplay
		counterPosition = 4


func _shop_button_pressed(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if shopOpen: shopOpen = false
		else: shopOpen = true


func _click_item_bought(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if itemCosts[0] <= clicks:
			clickIncrement += 1
			shopItems[0].get_node("Icon").size = Vector2(44, 44)
			add_clicks(itemCosts[0]*-1)
			@warning_ignore("narrowing_conversion")
			itemCosts[0] = itemCosts[0] * 1.05
			update_stats_and_costs()
		else:
			shopItems[0].get_node("Icon").rotation = 0.2


func _cps_item_bought(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if itemCosts[1] <= clicks:
			autoClicksPerSecond += 1
			shopItems[1].get_node("Icon").size = Vector2(44, 44)
			add_clicks(itemCosts[1]*-1)
			@warning_ignore("narrowing_conversion")
			itemCosts[1] = itemCosts[1] * 1.02
			update_stats_and_costs()
		else:
			shopItems[1].get_node("Icon").rotation = 0.2


func _mult_item_bought(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if itemCosts[2] <= clicks:
			clickIncrement = clickIncrement * 2
			shopItems[2].get_node("Icon").size = Vector2(44, 44)
			add_clicks(itemCosts[2]*-1)
			@warning_ignore("narrowing_conversion")
			itemCosts[2] = itemCosts[2] * 3
			update_stats_and_costs()
		else:
			shopItems[2].get_node("Icon").rotation = 0.2

func update_stats_and_costs():
	for item in shopItems:
		item.get_node("Cost").text = "c" + shortenNumber(itemCosts[item.get_index()])
	statsText.text = "CPC: " + shortenNumber(clickIncrement) + "|CPS: " + shortenNumber(autoClicksPerSecond)
