extends CharacterBody2D

const START_SPEED = 450.0
const ACCEL = 35.0
const MAX_SPEED = START_SPEED * 2.5

var speed = START_SPEED
var dir = Vector2.ZERO

var player_score = 0
var cpu_score = 0

const SCREEN_WIDTH = 1152.0
const SCREEN_HEIGHT = 648.0

func _ready():
	reset_ball()

func reset_ball():
	# อ่านตำแหน่งของ ColorRect ด้านใน (533, 105) และขนาดบอล (20x20)
	var rect_offset = Vector2.ZERO
	if has_node("ColorRect"):
		rect_offset = $ColorRect.position
	
	# คำนวณให้ "จุดศูนย์กลางของภาพลูกบอล" ไปลงตรงกลางหน้าจอพอดี (576, 324)
	# โดยหักลบทั้ง ColorRect Offset และ Parent Node Position (35, 18) ออก
	var center_screen = Vector2(SCREEN_WIDTH / 2.0, SCREEN_HEIGHT / 2.0)
	var ball_center_offset = Vector2(10.0, 10.0) # ครึ่งหนึ่งของขนาดบอล 20x20
	
	global_position = center_screen - rect_offset - ball_center_offset - get_parent().position
	
	speed = START_SPEED
	dir.x = [1, -1].pick_random()
	dir.y = randf_range(-0.7, 0.7)
	dir = dir.normalized()

func _physics_process(delta):
	var collision = move_and_collide(dir * speed * delta)
	
	if collision:
		var normal = collision.get_normal()
		if abs(normal.y) > abs(normal.x):
			dir.y = -dir.y
		else:
			dir.x = -dir.x
			dir.y = randf_range(-0.8, 0.8)

		dir = dir.normalized()
		speed = min(speed + ACCEL, MAX_SPEED)

	# คำนวณพิกัดมุมบนซ้ายของภาพบอลบนหน้าจอจริง
	var current_ball_pos = global_position + get_parent().position
	if has_node("ColorRect"):
		current_ball_pos += $ColorRect.position

	# --- เช็คขอบหน้าจอบน-ล่าง ---
	if current_ball_pos.y <= 0.0:
		dir.y = abs(dir.y)
	elif current_ball_pos.y >= SCREEN_HEIGHT - 20.0:
		dir.y = -abs(dir.y)

	# --- เช็คออกขอบซ้าย/ขวา ---
	if current_ball_pos.x < 0.0:
		cpu_score += 1
		#print("CPU Score: ", cpu_score, " | Player Score: ", player_score)
		reset_ball()
		
	elif current_ball_pos.x > SCREEN_WIDTH:
		player_score += 1
		#print("Player Score: ", player_score, " | CPU Score: ", cpu_score)
		reset_ball()
