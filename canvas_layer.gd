extends CanvasLayer

# อ้างอิง Node ลูกบอล และ Label แสดงคะแนน
var ball: CharacterBody2D
@onready var player_score_label: Label = $PlayerScore
@onready var cpu_score_label: Label = $CPUScore

func _ready():
	# ค้นหา Node Ball ใน Scene หลัก
	if get_parent().has_node("Ball"):
		ball = get_parent().get_node("Ball")
# กำหนดขนาดฟอนต์เป็น 64 ผ่านโค้ด
	player_score_label.add_theme_font_size_override("font_size", 64)
	cpu_score_label.add_theme_font_size_override("font_size", 64)
	
func _process(_delta):
	# คอยดึงค่าตัวแปรคะแนนจาก Ball มาอัปเดตลง Label ทุกเฟรม
	if ball != null:
		if player_score_label != null:
			player_score_label.text = str(ball.player_score)
		if cpu_score_label != null:
			cpu_score_label.text = str(ball.cpu_score)
