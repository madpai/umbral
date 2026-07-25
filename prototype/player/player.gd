## UMBRAL Feel Prototype 01 — player controller.
##
## Phase 1 (movement and camera) plus the Phase 1.1 corrections and the
## click-to-move experiment. Disposable by design; see
## docs/technical/PROTOTYPE_ARCHITECTURE.md sections 9 and 12.
##
## Every feel value below is exported and re-read every frame, so it can be
## changed in the Inspector WHILE THE GAME IS RUNNING. That is the point of this
## build. Values edited on the running instance are not saved automatically —
## copy them back into player.tscn before quitting, and log them in TUNING.md.
##
## CONTROL MODEL: neither WASD nor click-to-move is established UMBRAL canon.
## WASD is a movement laboratory and debugging fallback. Click-to-move is the
## leading design direction under test. Both run on the same tuned physical
## movement layer below; only the source of the direction vector differs.
##
## PHASE SCOPE: the architecture document specifies four states. WORKING belongs
## to Phase 2 (interaction) and STAGGERED to Phase 3 (hazard). Neither is
## implemented here, and neither should be added before those phases.

class_name PrototypePlayer
extends CharacterBody3D

enum MoveState { GROUNDED, AIRBORNE }
enum ControlMode { DIRECT, CLICK_TO_MOVE }

## Emitted when the player asks to travel somewhere. Carries a SCREEN position;
## main.gd owns the world and does the raycast. Signals go up, nothing reaches
## down.
signal destination_requested(screen_position: Vector2)

@export_group("Control Mode")
## Defaults to the mode under test. F2 toggles at runtime.
@export var control_mode: ControlMode = ControlMode.CLICK_TO_MOVE
## Destination is cleared once the player is within this distance of it.
@export_range(0.05, 2.0, 0.05) var arrival_radius := 0.35

@export_group("Speed")
## Metres per second at full walk.
@export_range(0.5, 20.0, 0.1) var walk_speed := 4.5
## Metres per second while sprint is held.
@export_range(0.5, 30.0, 0.1) var sprint_speed := 7.6

@export_group("Acceleration")
## Metres per second squared. Time to full speed = speed / acceleration.
@export_range(1.0, 200.0, 0.5) var ground_acceleration := 32.0
## Applied when there is no movement input and the player is grounded.
@export_range(1.0, 200.0, 0.5) var ground_deceleration := 80.0
## Deliberately much lower than ground_acceleration: limited air control.
@export_range(0.0, 200.0, 0.5) var air_acceleration := 14.0
## Very low, so momentum is preserved through a jump.
@export_range(0.0, 200.0, 0.5) var air_deceleration := 3.0

@export_group("Turning")
## Higher is snappier. Frame-rate independent exponential smoothing.
@export_range(1.0, 40.0, 0.5) var turn_smoothing := 14.0

@export_group("Gravity and Jump")
## Metres per second squared. Much higher than real gravity on purpose.
@export_range(1.0, 80.0, 0.1) var gravity := 26.0
## Gravity is multiplied by this while falling, which shortens the float at apex.
@export_range(1.0, 4.0, 0.05) var fall_gravity_multiplier := 1.45
## Initial upward velocity. Apex height = jump_velocity^2 / (2 * gravity).
@export_range(1.0, 30.0, 0.1) var jump_velocity := 7.6
@export_range(1.0, 100.0, 0.5) var max_fall_speed := 45.0
## Seconds after leaving a ledge during which a jump still works.
@export_range(0.0, 0.5, 0.01) var coyote_time := 0.1
## Seconds before landing during which a jump press is remembered.
@export_range(0.0, 0.5, 0.01) var jump_buffer_time := 0.12

@export_group("Floor")
## Surfaces steeper than this are not walkable. The 50 degree test ramp is
## deliberately above the default so the threshold is visible in play.
@export_range(5.0, 89.0, 0.5) var floor_max_angle_degrees := 46.0
## Keeps the character stuck to downhill slopes instead of bouncing off them.
@export_range(0.0, 2.0, 0.05) var floor_snap_length_m := 0.4
## Tallest vertical lip the character will walk up. Set to 0 to disable.
## Anything taller is treated as a wall. See _try_step_up().
@export_range(0.0, 0.8, 0.01) var max_step_height := 0.25

@export_group("Camera Laboratory")
## The perspectives under test. Cycled with F3; see camera/camera_preset.gd.
## Framing, pitch, lens and response all live in these resources so that the
## camera can be changed without touching the controller.
@export var camera_presets: Array[CameraPreset] = []
@export var camera_preset_index := 0

@export_group("Camera Look")
@export_range(0.0005, 0.02, 0.0001) var mouse_sensitivity := 0.0032
## Radians per second at full right-stick deflection.
@export_range(0.5, 8.0, 0.1) var gamepad_look_speed := 3.0
@export var invert_pitch := false
## How fast the lens reaches its target FOV. A response rate rather than a
## perspective, so it stays here and is shared by every preset.
@export_range(0.5, 20.0, 0.5) var fov_lerp_speed := 6.0

@onready var body: Node3D = $Body
@onready var camera_rig: Node3D = $CameraRig
@onready var spring_arm: SpringArm3D = $CameraRig/SpringArm3D
@onready var camera: Camera3D = $CameraRig/SpringArm3D/Camera3D
@onready var ground_check: RayCast3D = $GroundCheck
@onready var collision: CollisionShape3D = $Collision

var state: MoveState = MoveState.GROUNDED

var _spawn_transform: Transform3D
var _yaw := 0.0
var _pitch := -0.25
var _coyote := 0.0
var _jump_buffer := 0.0
var _sprinting := false
var _slope_degrees := 0.0
var _mouse_captured := false
var _orbiting := false
var _destination := Vector3.ZERO
var _has_destination := false
var _stepped_this_frame := false
## Derived from the capsule radius in _ready(); see _try_step_up().
var _step_probe_distance := 0.45
var _fallback_preset: CameraPreset = null
## Normalised zoom. _zoom_t is the target the wheel sets; _zoom_t_smooth is what
## the camera actually uses, so zooming interpolates rather than snapping.
var _zoom_t := 0.0
var _zoom_t_smooth := 0.0
## Pitch is coupled to zoom via a moving baseline. Storing the last baseline lets
## zoom shift the pitch while PRESERVING any manual orbit the player has made,
## instead of overwriting it.
var _zoom_baseline_pitch := 0.0
## Where the cursor was when right-drag orbit began, so it can be put back.
var _orbit_cursor := Vector2.ZERO


func _ready() -> void:
	_spawn_transform = global_transform
	if collision.shape is CapsuleShape3D:
		_step_probe_distance = (collision.shape as CapsuleShape3D).radius + 0.05
	# Without this the spring arm collides with the player's own capsule and
	# jams the camera into the character.
	spring_arm.add_excluded_object(get_rid())
	# The rig is driven by hand every render frame, so the engine must not also
	# interpolate it. Leaving this ON makes the engine fight _update_camera().
	camera_rig.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	_apply_exports()
	_apply_camera_preset()
	_apply_mouse_mode()


# ---------------------------------------------------------------- input ------

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and (_mouse_captured or _orbiting):
		var motion := event as InputEventMouseMotion
		var pitch_sign := -1.0 if invert_pitch else 1.0
		_yaw -= motion.relative.x * mouse_sensitivity
		_pitch -= motion.relative.y * mouse_sensitivity * pitch_sign
		var preset := active_preset()
		_pitch = clampf(_pitch,
				deg_to_rad(preset.pitch_min_degrees), deg_to_rad(preset.pitch_max_degrees))
	elif event.is_action_pressed("cycle_camera"):
		cycle_camera_preset(1)
	elif event.is_action_pressed("toggle_control_mode"):
		set_control_mode(ControlMode.DIRECT if control_mode == ControlMode.CLICK_TO_MOVE \
				else ControlMode.CLICK_TO_MOVE)
	elif event.is_action_pressed("ui_cancel"):
		# Release the mouse so Inspector values can be edited while running.
		if control_mode == ControlMode.DIRECT:
			_mouse_captured = not _mouse_captured
			_apply_mouse_mode()
	elif event is InputEventMouseButton:
		_handle_mouse_button(event as InputEventMouseButton)
	elif event is InputEventScreenTouch:
		# Touch maps to the same destination request as a left click. There is
		# deliberately no mobile UI here.
		var touch := event as InputEventScreenTouch
		if touch.pressed and control_mode == ControlMode.CLICK_TO_MOVE:
			destination_requested.emit(touch.position)


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	# The wheel zooms in every control mode, and must never be mistaken for a
	# click that recaptures the cursor or issues a destination.
	if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		zoom_by(-1.0)
		return
	if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		zoom_by(1.0)
		return

	if control_mode == ControlMode.DIRECT:
		# Click to recapture after Esc released the cursor.
		if event.pressed and not _mouse_captured:
			_mouse_captured = true
			_apply_mouse_mode()
		return

	if event.button_index == MOUSE_BUTTON_RIGHT:
		# Hold right mouse to orbit. This only ever moves the camera: it never
		# issues, replaces or cancels a destination. Left click stays free.
		if event.pressed:
			_orbit_cursor = get_viewport().get_mouse_position()
		_orbiting = event.pressed
		_apply_mouse_mode()
		if not event.pressed:
			# Capturing recentres the cursor; put it back where the drag began
			# so a right-drag does not move the player's aim.
			Input.warp_mouse(_orbit_cursor)
	elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		destination_requested.emit(event.position)


# ------------------------------------------------------------- per-frame -----

func _process(delta: float) -> void:
	_update_zoom(delta)
	_apply_exports()
	_update_look(delta)
	_update_camera(delta)


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_reset"):
		_reset_to_spawn()
		return

	_sprinting = Input.is_action_pressed("sprint")

	var grounded := is_on_floor()
	state = MoveState.GROUNDED if grounded else MoveState.AIRBORNE

	if grounded:
		_coyote = coyote_time
	else:
		_coyote = maxf(_coyote - delta, 0.0)

	if Input.is_action_just_pressed("jump"):
		_jump_buffer = jump_buffer_time
	else:
		_jump_buffer = maxf(_jump_buffer - delta, 0.0)

	if not grounded:
		var g := gravity * (fall_gravity_multiplier if velocity.y < 0.0 else 1.0)
		velocity.y = maxf(velocity.y - g * delta, -max_fall_speed)
	elif velocity.y < 0.0:
		velocity.y = 0.0

	if _jump_buffer > 0.0 and _coyote > 0.0:
		velocity.y = jump_velocity
		_jump_buffer = 0.0
		_coyote = 0.0
		grounded = false

	var direction := _movement_direction()
	var moving := direction.length_squared() > 0.0
	var target_speed := sprint_speed if _sprinting else walk_speed

	var rate: float
	if grounded:
		rate = ground_acceleration if moving else ground_deceleration
	else:
		rate = air_acceleration if moving else air_deceleration

	var horizontal := Vector3(velocity.x, 0.0, velocity.z)
	horizontal = horizontal.move_toward(direction * target_speed, rate * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.z

	if moving:
		# Godot forward is -Z, hence the negated arguments.
		var wanted := atan2(-direction.x, -direction.z)
		var weight := 1.0 - exp(-turn_smoothing * delta)
		body.rotation.y = lerp_angle(body.rotation.y, wanted, weight)

	# Snapping while moving upward would drag the character back down.
	floor_snap_length = 0.0 if velocity.y > 0.0 else floor_snap_length_m

	_stepped_this_frame = false
	if grounded and velocity.y <= 0.0 and max_step_height > 0.0:
		_stepped_this_frame = _try_step_up(Vector3(velocity.x, 0.0, velocity.z) * delta)

	if _stepped_this_frame:
		# The step already performed this frame's horizontal movement. Run
		# move_and_slide with the horizontal component zeroed so it only settles
		# the character and refreshes is_on_floor(), then restore momentum.
		var keep := velocity
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		velocity.x = keep.x
		velocity.z = keep.z
	else:
		move_and_slide()

	_update_slope()


# ------------------------------------------------------------- movement ------

## Produces this frame's desired horizontal direction from whichever control
## model is active. Everything downstream — acceleration, slopes, turning,
## stepping — is identical for both, which is the point of the experiment.
func _movement_direction() -> Vector3:
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	if input.length_squared() > 0.0:
		# WASD always wins, in either mode. In CLICK_TO_MOVE this is the escape
		# hatch that stops the build ever being unrecoverable; it is not the
		# behaviour under test.
		_has_destination = false
		return _camera_relative(input)

	if control_mode == ControlMode.DIRECT:
		return Vector3.ZERO

	if not _has_destination:
		return Vector3.ZERO

	var to_target := _destination - global_position
	to_target.y = 0.0
	if to_target.length() <= arrival_radius:
		# Clear the destination and let normal deceleration bring the character
		# to rest. Nothing is teleported and nothing is snapped.
		_has_destination = false
		return Vector3.ZERO
	return to_target.normalized()


## Minimal step-up. Not a stair solver: three shape tests and a placement.
##
## Rejects walls (still blocked when raised) and unwalkable surfaces (landing
## normal steeper than floor_max_angle), so the 50 degree ramp stays rejected.
## Returns true if the character was placed on top of a step.
##
## The probe distance matters more than it looks. A capsule dropped only one
## frame of motion past a step's leading edge catches the CORNER, not the flat
## top: measured 42.8 degrees and a 0.094 m landing on a 0.20 m step, which then
## failed the walkable test. Probing forward by at least the capsule radius
## lands on the flat top instead (measured 0.0 degrees, 0.2002 m).
func _try_step_up(motion: Vector3) -> bool:
	if motion.length_squared() < 0.0000001:
		return false

	# 1. Are we actually blocked moving forward from here?
	if not test_move(global_transform, motion):
		return false

	# The probe is for MEASUREMENT ONLY; the character is never advanced by it.
	var probe := motion.normalized() * maxf(motion.length(), _step_probe_distance)

	# 2. Is the way clear from one step height up? If not, it is a wall.
	var raised := global_transform.translated(Vector3.UP * max_step_height)
	if test_move(raised, probe):
		return false

	# 3. Drop back down. If there is nothing to land on it was a gap, not a step.
	var landed := raised.translated(probe)
	var drop := Vector3.DOWN * (max_step_height + 0.02)
	var hit := KinematicCollision3D.new()
	if not test_move(landed, drop, hit):
		return false

	# 4. Only climb onto ground we would be allowed to stand on.
	if hit.get_normal().angle_to(Vector3.UP) > floor_max_angle:
		return false

	var top_y := landed.origin.y + hit.get_travel().y
	var rise := top_y - global_position.y
	if rise <= 0.001 or rise > max_step_height:
		return false

	# Rise to the measured step height, but advance only one frame of motion.
	global_position = Vector3(
		global_position.x + motion.x, top_y, global_position.z + motion.z)
	return true


func _camera_relative(input: Vector2) -> Vector3:
	if input.length_squared() <= 0.0:
		return Vector3.ZERO
	var basis := camera_rig.global_transform.basis
	var forward := -basis.z
	var right := basis.x
	forward.y = 0.0
	right.y = 0.0
	if forward.length_squared() < 0.0001 or right.length_squared() < 0.0001:
		return Vector3.ZERO
	return (right.normalized() * input.x - forward.normalized() * input.y).normalized()


func _update_slope() -> void:
	if is_on_floor():
		_slope_degrees = rad_to_deg(get_floor_normal().angle_to(Vector3.UP))
	elif ground_check.is_colliding():
		_slope_degrees = rad_to_deg(ground_check.get_collision_normal().angle_to(Vector3.UP))
	else:
		_slope_degrees = -1.0


# --------------------------------------------------------------- camera ------

## Re-read every frame so Inspector edits apply to the running game.
func _apply_exports() -> void:
	floor_max_angle = deg_to_rad(floor_max_angle_degrees)
	spring_arm.spring_length = current_distance()


## The active perspective. Falls back to a default-constructed preset so an
## empty array degrades to a working camera instead of a crash.
func active_preset() -> CameraPreset:
	if camera_presets.is_empty():
		if _fallback_preset == null:
			_fallback_preset = CameraPreset.new()
			_fallback_preset.preset_name = "fallback (no presets assigned)"
		return _fallback_preset
	return camera_presets[clampi(camera_preset_index, 0, camera_presets.size() - 1)]


## Instant. No scene reload, no second camera, no duplicated controller: only
## the numbers feeding the one rig change.
func cycle_camera_preset(step: int = 1) -> void:
	if camera_presets.size() > 1:
		camera_preset_index = wrapi(camera_preset_index + step, 0, camera_presets.size())
	_apply_camera_preset()


func _apply_camera_preset() -> void:
	var preset := active_preset()
	if preset.zoom_enabled:
		_zoom_t = preset.start_zoom_t()
		_zoom_t_smooth = _zoom_t
		_zoom_baseline_pitch = deg_to_rad(preset.pitch_at(_zoom_t))
		_pitch = _zoom_baseline_pitch
	else:
		_zoom_t = 0.0
		_zoom_t_smooth = 0.0
		_zoom_baseline_pitch = 0.0
		_pitch = deg_to_rad(preset.pitch_degrees)
	_pitch = clampf(_pitch,
			deg_to_rad(preset.pitch_min_degrees), deg_to_rad(preset.pitch_max_degrees))
	spring_arm.collision_mask = 1 if preset.avoid_obstructions else 0
	_snap_camera()


## Wheel notches move the zoom TARGET; _update_zoom eases the camera toward it.
func zoom_by(steps: float) -> void:
	var preset := active_preset()
	if not preset.zoom_enabled:
		return
	_zoom_t = clampf(_zoom_t + steps * preset.zoom_step, 0.0, 1.0)


func _update_zoom(delta: float) -> void:
	var preset := active_preset()
	if not preset.zoom_enabled:
		return
	_zoom_t_smooth = lerpf(_zoom_t_smooth, _zoom_t, 1.0 - exp(-preset.zoom_response * delta))
	# Shift pitch by however much the baseline moved, so a player who has orbited
	# keeps their relative adjustment instead of having it snapped away.
	var baseline := deg_to_rad(preset.pitch_at(_zoom_t_smooth))
	_pitch += baseline - _zoom_baseline_pitch
	_zoom_baseline_pitch = baseline


## Effective distance and lens, accounting for zoom when the preset has it.
func current_distance() -> float:
	var preset := active_preset()
	return preset.distance_at(_zoom_t_smooth) if preset.zoom_enabled else preset.distance


func current_fov() -> float:
	var preset := active_preset()
	return preset.fov_at(_zoom_t_smooth) if preset.zoom_enabled else preset.fov


func _update_look(delta: float) -> void:
	var preset := active_preset()
	var look := Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if look.length_squared() > 0.0:
		var pitch_sign := -1.0 if invert_pitch else 1.0
		_yaw -= look.x * gamepad_look_speed * delta
		_pitch -= look.y * gamepad_look_speed * delta * pitch_sign
	_pitch = clampf(_pitch,
			deg_to_rad(preset.pitch_min_degrees), deg_to_rad(preset.pitch_max_degrees))


func _update_camera(delta: float) -> void:
	var preset := active_preset()
	camera_rig.global_rotation = Vector3(0.0, _yaw, 0.0)
	spring_arm.rotation.x = _pitch
	spring_arm.position = Vector3(preset.shoulder_offset, 0.0, 0.0)

	var weight := 1.0 - exp(-preset.damping * delta)
	camera_rig.global_position = camera_rig.global_position.lerp(_camera_target(), weight)

	var wanted_fov := current_fov() + (preset.fov_sprint_add if _sprinting else 0.0)
	camera.fov = lerpf(camera.fov, wanted_fov, 1.0 - exp(-fov_lerp_speed * delta))


## Chases the INTERPOLATED (visual) player position, not the physics position.
## global_position only changes at 60 Hz; following it directly would reintroduce
## the stair-stepping that physics interpolation exists to remove.
func _camera_target() -> Vector3:
	return get_global_transform_interpolated().origin + Vector3.UP * active_preset().height


func _snap_camera() -> void:
	camera_rig.global_position = _camera_target()
	camera_rig.global_rotation = Vector3(0.0, _yaw, 0.0)
	spring_arm.rotation.x = _pitch
	camera.fov = current_fov()


# ----------------------------------------------------------------- state -----

func set_control_mode(mode: ControlMode) -> void:
	control_mode = mode
	_has_destination = false
	_orbiting = false
	_mouse_captured = mode == ControlMode.DIRECT
	_apply_mouse_mode()


func set_destination(point: Vector3) -> void:
	# A new request replaces the old one immediately; there is no queue.
	_destination = point
	_has_destination = true


func clear_destination() -> void:
	_has_destination = false


func _apply_mouse_mode() -> void:
	var capture := _mouse_captured or _orbiting
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if capture else Input.MOUSE_MODE_VISIBLE


func _reset_to_spawn() -> void:
	velocity = Vector3.ZERO
	global_transform = _spawn_transform
	# Otherwise the engine interpolates across the teleport and smears the
	# character over the whole map for a frame.
	reset_physics_interpolation()
	body.rotation = Vector3.ZERO
	_yaw = 0.0
	_coyote = 0.0
	_jump_buffer = 0.0
	_slope_degrees = 0.0
	_has_destination = false
	_apply_camera_preset()


# --- Read-only accessors for the debug readout in main.gd ---

func horizontal_speed() -> float:
	return Vector2(velocity.x, velocity.z).length()


func vertical_speed() -> float:
	return velocity.y


func state_name() -> String:
	return "GROUNDED" if state == MoveState.GROUNDED else "AIRBORNE"


func camera_zoom_normalised() -> float:
	return _zoom_t_smooth


func camera_is_zoomable() -> bool:
	return active_preset().zoom_enabled


func camera_pitch_degrees() -> float:
	return rad_to_deg(_pitch)


func camera_preset_label() -> String:
	var total := maxi(camera_presets.size(), 1)
	return "%s  (%d/%d)" % [active_preset().preset_name,
			clampi(camera_preset_index, 0, total - 1) + 1, total]


func control_mode_name() -> String:
	return "CLICK-TO-MOVE" if control_mode == ControlMode.CLICK_TO_MOVE else "DIRECT (WASD)"


## Returns -1.0 when nothing is below the player within the ground check range.
func slope_degrees() -> float:
	return _slope_degrees


func coyote_remaining() -> float:
	return _coyote


func is_sprinting() -> bool:
	return _sprinting


func is_mouse_captured() -> bool:
	return _mouse_captured or _orbiting


func has_destination() -> bool:
	return _has_destination


func destination() -> Vector3:
	return _destination


func distance_to_destination() -> float:
	if not _has_destination:
		return -1.0
	var to_target := _destination - global_position
	to_target.y = 0.0
	return to_target.length()


func stepped_this_frame() -> bool:
	return _stepped_this_frame
