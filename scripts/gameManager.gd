extends Node

@onready var button = $"Monitor Button"
@onready var clicksCounter = $"Click Counter"
@onready var timer = $Timer
var buttonSize = 64
var counterPosition = 0
var time = 0.0
var clicks = 0
@export var clickIncrement = 1.0
@export var autoClicksPerSecond = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.timeout.connect(add_clicks)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	button.rotation = sin(time) / 10
	time += delta
	
	button.size = Vector2(buttonSize, buttonSize)
	button.position = Vector2(100-buttonSize/2, 100-buttonSize/2)
	if buttonSize > 64:
		buttonSize -= delta*10*(buttonSize-64)
	clicksCounter.position.y = counterPosition
	if counterPosition > 0:
		counterPosition -= delta*5*counterPosition


func _on_tv_clicked(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		add_clicks(clickIncrement)
		buttonSize = 72

func add_clicks(amount = autoClicksPerSecond):
	clicks += amount
	if round(clicks) == clicks:
		clicks = roundi(clicks)
	
	var clickDisplay = ""
	if clicks >= 1000000000:
		clickDisplay = str(floorf(clicks/100000000)/10) + "b"
	elif clicks >= 1000000:
		clickDisplay = str(floorf(clicks/100000)/10) + "m"
	elif clicks >= 1000:
		clickDisplay = str(floorf(clicks/100)/10) + "k"
	else:
		clickDisplay = str(clicks)
	
	if clicksCounter.text != clickDisplay:
		clicksCounter.text = clickDisplay
		counterPosition = 4
