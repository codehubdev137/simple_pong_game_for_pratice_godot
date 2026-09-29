extends CharacterBody2D

const SPEED = 400.0

# --- ตั้งค่าโหมด ---
# true  (หรือ 1) = บอทเล่น
# false (หรือ 0) = คนเล่น (กด Up / Down)
@export var is_bot: bool = true

# กำหนดปุ่มควบคุมสำหรับโหมดคนเล่น (ใช้ปุ่มลูกศร)
@export var action_up: String = "ui_up"
@export var action_down: String = "ui_down"

var ball: CharacterBody2D
var lock_x_position: float

# ค่าคงที่สำหรับคำนวณตำแหน่งหน้าจอ
const SCREEN_WIDTH = 1152.0
const SCREEN_HEIGHT = 648.0

# ค่า Offset ของวัตถุใน Scene
const BALL_OFFSET_X = 572.0
const BALL_OFFSET_Y = 101.0
const PADDLE_OFFSET_Y = 41.5

func _ready():
	# จำพิกัด X ฝั่งขวาไว้ล็อคตำแหน่งไม่ให้โดนบอลดันเบี้ยว
	lock_x_position = position.x
	
	# รีเซ็ตตำแหน่งเริ่มต้นให้อยู่ตรงกลางจอแนวตั้ง
	_reset_to_center()
	
	# ค้นหา Node "Ball" อัตโนมัติเมื่อเริ่มเกม
	if get_parent().has_node("Ball"):
		ball = get_parent().get_node("Ball")

func _physics_process(delta):
	if is_bot:
		_control_bot()
	else:
		_control_player()

	move_and_slide()
	
	# ล็อคพิกัด X ฝั่งขวาแน่นๆ และจำกัดขอบบน-ล่าง
	position.x = lock_x_position
	position.y = clamp(position.y, -5 , SCREEN_HEIGHT - 105)


# สั่งย้ายตำแหน่ง Y ให้อยู่ตรงกลางจอ
func _reset_to_center():
	position.y = (SCREEN_HEIGHT / 2.0) - PADDLE_OFFSET_Y

# --- โหมดคนเล่นฝั่งขวา ---
func _control_player():
	var direction = Input.get_axis(action_up, action_down)
	if direction != 0:
		velocity.y = direction * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)

# --- โหมดบอทฝั่งขวา ---
func _control_bot():
	if ball == null:
		_move_to_center()
		return

	# คำนวณตำแหน่งจริงของลูกบอลบนหน้าจอ
	var real_ball_x = ball.position.x + BALL_OFFSET_X
	var real_ball_y = ball.position.y + BALL_OFFSET_Y
	var center_x = SCREEN_WIDTH / 2.0

	# เช็คว่าบอลอยู่ฝั่งขวาของหน้าจอหรือไม่
	if real_ball_x >= center_x:
		# บอลอยู่ฝั่งขวา -> ขยับไม้ตีตามบอล
		var real_paddle_y = position.y + PADDLE_OFFSET_Y
		if abs(real_ball_y - real_paddle_y) > 10:
			if real_ball_y > real_paddle_y:
				velocity.y = SPEED
			else:
				velocity.y = -SPEED
		else:
			velocity.y = 0
	else:
		# บอลข้ามไปฝั่งซ้าย -> ค่อยๆ สไลด์กลับมารอตรงกลางจอ
		_move_to_center()

# ฟังก์ชันถอยกลับมารอตรงกลางจอ
func _move_to_center():
	var target_y = (SCREEN_HEIGHT / 2.0) - PADDLE_OFFSET_Y
	if abs(position.y - target_y) > 5:
		if position.y < target_y:
			velocity.y = SPEED * 0.7
		else:
			velocity.y = -SPEED * 0.7
	else:
		velocity.y = 0
