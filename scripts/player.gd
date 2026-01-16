extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 400.0
const JUMP_VELOCITY = -800.0

# DASH SETTINGS
const DASH_SPEED = 800.0
const DASH_TIME = 0.35         # сколько длится рывок
const DASH_COOLDOWN = 1.5      # кулдаун между dash

var is_dashing := false
var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var dash_direction := 0


func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("left", "right")

	# ===== DASH COOLDOWN TIMER =====
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	# ===== DASH START =====
	if Input.is_action_just_pressed("dash") \
	and not is_dashing \
	and dash_cooldown_timer <= 0 \
	and direction != 0 \
	and is_on_floor():
		is_dashing = true
		dash_timer = DASH_TIME
		dash_direction = direction
		dash_cooldown_timer = DASH_COOLDOWN
		velocity.y = 0

	# ===== DASH PROCESS =====
	if is_dashing:
		dash_timer -= delta
		velocity.x = dash_direction * DASH_SPEED

		if dash_timer <= 0:
			is_dashing = false
	else:
		# Gravity
		if not is_on_floor():
			velocity += get_gravity() * delta

		# Jump
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			animated_sprite_2d.animation = "jump"

		# Horizontal movement
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# ===== FLIP =====
	if direction > 0:
		animated_sprite_2d.flip_h = false
	elif direction < 0:
		animated_sprite_2d.flip_h = true

	# ===== ANIMATIONS =====
	if is_dashing:
		animated_sprite_2d.animation = "dash"
	elif not is_on_floor():
		animated_sprite_2d.animation = "jump"
	elif velocity.x > 1 or velocity.x < -1:
		animated_sprite_2d.animation = "walk"
	else:
		animated_sprite_2d.animation = "idle"
