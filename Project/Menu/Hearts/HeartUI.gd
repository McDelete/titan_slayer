extends Control



onready var heartUIFull = $HeartUIFull
onready var heartUIThreeQ = $HeartUIThreeQ
onready var heartUITwoQ = $HeartUITwoQ
onready var heartUIOneQ = $HeartUIOneQ
onready var heartUIEmpty = $HeartUIEmpty
export var statOwner = 0

var max_hearts = 0 setget set_max_hearts
var hearts = 0  setget set_hearts

func _ready():
	if(statOwner == 0):
		self.max_hearts = PlayerStats.max_health

		self.hearts = PlayerStats.health

		PlayerStats.connect("health_changed", self, "set_hearts")
		PlayerStats.connect("max_health_changed", self, "set_max_hearts")
	elif(statOwner == 1):
		self.max_hearts = BossStats.max_health

		self.hearts = BossStats.health

		BossStats.connect("health_changed", self, "set_hearts")
		BossStats.connect("max_health_changed", self, "set_max_hearts")
	
func set_hearts(value):
	
	hearts = clamp(value / 4, 0 , max_hearts)
	if (value % 4 == 3):
		heartUIFull.rect_size.x = hearts *17
	elif(value % 4 ==2):
		heartUIFull.rect_size.x = hearts *17
		heartUIThreeQ.rect_size.x = hearts *17
	elif (value % 4 ==1):
		heartUIFull.rect_size.x = hearts *17
		heartUIThreeQ.rect_size.x = hearts *17
		heartUITwoQ.rect_size.x = hearts *17
	elif(value % 4 <= 0):
		heartUIFull.rect_size.x = hearts *17
		heartUIThreeQ.rect_size.x = hearts *17
		heartUITwoQ.rect_size.x = hearts *17
		heartUIOneQ.rect_size.x = hearts *17
	

func set_max_hearts(value):
	#Instantiating hearts
	heartUIFull.rect_size.x = (hearts+1) *17
	heartUIThreeQ.rect_size.x = (hearts+1) *17
	heartUITwoQ.rect_size.x = (hearts+1) *17
	heartUIOneQ.rect_size.x = (hearts+1) *17
	
	max_hearts = max(value / 4, 1)
	heartUIEmpty.rect_size.x = max_hearts *17
