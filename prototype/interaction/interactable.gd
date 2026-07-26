## An object that can be clicked and worked on.
##
## Objects own their own BEHAVIOUR and their own FEEDBACK. They know nothing
## about the player, the camera or navigation. The player owns orchestration and
## drives this through begin/set_progress/complete/cancel. There is no manager.
##
## Expected children: `Visual` (Node3D of MeshInstance3Ds), `ProgressRing`,
## `RangeRing`. Disposable prototype code.

class_name Interactable
extends StaticBody3D

signal interaction_completed(interactable: Interactable)

enum VisualState { AVAILABLE, HOVERED, ACTIVE, COMPLETED, DEPLETED, LIT, REFUSED }

@export var profile: InteractionProfile

@onready var visual: Node3D = $Visual
@onready var progress_ring: MeshInstance3D = $ProgressRing
@onready var range_ring: MeshInstance3D = $RangeRing
## Optional, looked up by name. Hidden when a log source depletes.
@onready var _canopy: Node3D = get_node_or_null("Visual/Canopy")
## Optional, looked up by name. Shown when a campfire ignites.
@onready var _flame: Node3D = get_node_or_null("Visual/Flame")
@onready var _fire_light: OmniLight3D = get_node_or_null("FireLight")

var _state: VisualState = VisualState.AVAILABLE
var _meshes: Array[MeshInstance3D] = []
var _materials: Array[StandardMaterial3D] = []
var _base_colours: Array[Color] = []
var _visual_base_scale := Vector3.ONE
var _reset_timer := 0.0
var _pulse := 0.0
var _refuse_timer := 0.0
var _flicker := 0.0
## Causal state. Disposable prototype scaffolding, not a resource model.
var depleted := false
var lit := false


func _ready() -> void:
	if profile == null:
		profile = InteractionProfile.new()
	_visual_base_scale = visual.scale
	_collect_meshes(visual)
	progress_ring.visible = false
	range_ring.visible = false
	if _flame != null:
		_flame.visible = false
	if _fire_light != null:
		_fire_light.visible = false
	range_ring.scale = Vector3(profile.interaction_range, 1.0, profile.interaction_range)
	_apply_tint()


## Each mesh gets its own material copy so tinting one object never bleeds into
## another that happened to share a material resource.
func _collect_meshes(node: Node) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			var mesh_instance := child as MeshInstance3D
			var source := mesh_instance.get_active_material(0)
			if source is StandardMaterial3D:
				var copy := (source as StandardMaterial3D).duplicate() as StandardMaterial3D
				mesh_instance.set_surface_override_material(0, copy)
				_meshes.append(mesh_instance)
				_materials.append(copy)
				_base_colours.append(copy.albedo_color)
		_collect_meshes(child)


func _process(delta: float) -> void:
	if _refuse_timer > 0.0:
		_refuse_timer -= delta
		if _refuse_timer <= 0.0:
			_set_state(VisualState.DEPLETED if depleted
					else (VisualState.LIT if lit else VisualState.AVAILABLE))

	if lit and _fire_light != null:
		# Placeholder flicker: a sine on the light energy and the flame scale.
		# Readability, not atmosphere.
		_flicker += delta * 9.0
		_fire_light.light_energy = 3.2 + sin(_flicker) * 0.45 + sin(_flicker * 2.7) * 0.2
		if _flame != null:
			_flame.scale = Vector3.ONE * (1.0 + sin(_flicker * 1.6) * 0.09)

	if _state == VisualState.COMPLETED and profile.reset_seconds > 0.0:
		_reset_timer -= delta
		if _reset_timer <= 0.0:
			_set_state(VisualState.AVAILABLE)

	if _state == VisualState.ACTIVE and profile.pulse_speed > 0.0:
		_pulse += delta * profile.pulse_speed * TAU
		var factor := 1.0 + sin(_pulse) * profile.pulse_amount
		visual.scale = _visual_base_scale * factor
	elif visual.scale != _visual_base_scale:
		visual.scale = visual.scale.lerp(_visual_base_scale, 1.0 - exp(-12.0 * delta))


# ------------------------------------------------------------- player API ----

func is_available() -> bool:
	if depleted or lit:
		return false
	return _state != VisualState.COMPLETED


## The object's own rule about whether it will accept work right now. Takes the
## player's log state as a plain bool so the object never learns what a player
## is. Returns an empty string when the interaction is allowed, otherwise the
## debug-HUD reason it was refused.
func refusal_reason(player_has_log: bool) -> String:
	match profile.role:
		InteractionProfile.Role.LOG_SOURCE:
			if depleted:
				return "%s is bare" % profile.display_name
			if player_has_log:
				# One log at a time. Refusing rather than wasting the only tree
				# in the scene: see CONSEQUENCE_TEST.md.
				return "already carrying a log"
		InteractionProfile.Role.CAMPFIRE:
			if lit:
				return "%s is already lit" % profile.display_name
			if not player_has_log:
				return "no log to burn"
		_:
			if _state == VisualState.COMPLETED:
				return "%s is spent" % profile.display_name
	return ""


## Brief red flash. The whole "you cannot do that" feedback.
func refuse() -> void:
	_refuse_timer = profile.refuse_flash_seconds
	_set_state(VisualState.REFUSED)


func deplete() -> void:
	depleted = true
	if _canopy != null:
		_canopy.visible = false
	_set_state(VisualState.DEPLETED)


func ignite() -> void:
	lit = true
	if _flame != null:
		_flame.visible = true
	if _fire_light != null:
		_fire_light.visible = true
	_set_state(VisualState.LIT)


## Debug-only. Puts the object back to its opening condition.
func reset_scenario() -> void:
	depleted = false
	lit = false
	_refuse_timer = 0.0
	_reset_timer = 0.0
	progress_ring.visible = false
	if _canopy != null:
		_canopy.visible = true
	if _flame != null:
		_flame.visible = false
	if _fire_light != null:
		_fire_light.visible = false
		_fire_light.light_energy = 3.2
	visual.scale = _visual_base_scale
	_set_state(VisualState.AVAILABLE)


func interaction_range() -> float:
	return profile.interaction_range


## Where the character should stand: inside range, on the near side.
func approach_point_from(origin: Vector3) -> Vector3:
	var away := origin - global_position
	away.y = 0.0
	if away.length_squared() < 0.0001:
		away = Vector3.FORWARD
	var distance: float = profile.interaction_range * profile.approach_fraction
	return global_position + away.normalized() * distance


func set_hovered(hovered: bool) -> void:
	if _state == VisualState.AVAILABLE and hovered:
		_set_state(VisualState.HOVERED)
	elif _state == VisualState.HOVERED and not hovered:
		_set_state(VisualState.AVAILABLE)


func begin_interaction() -> void:
	_pulse = 0.0
	_set_state(VisualState.ACTIVE)
	progress_ring.visible = true
	set_progress(0.0)


func set_progress(t: float) -> void:
	var clamped := clampf(t, 0.0, 1.0)
	progress_ring.scale = Vector3(
			lerpf(0.15, 1.0, clamped), 1.0, lerpf(0.15, 1.0, clamped))


func cancel_interaction() -> void:
	progress_ring.visible = false
	if _state == VisualState.ACTIVE:
		_set_state(VisualState.AVAILABLE)


func complete_interaction() -> void:
	progress_ring.visible = false
	match profile.role:
		InteractionProfile.Role.LOG_SOURCE:
			deplete()
		InteractionProfile.Role.CAMPFIRE:
			ignite()
		_:
			_set_state(VisualState.COMPLETED)
			_reset_timer = profile.reset_seconds
	# The visible "something happened" beat. Deliberately just a pop and a
	# colour change: no felling, no resources, no inventory.
	var tween := create_tween()
	tween.tween_property(visual, "scale", _visual_base_scale * 1.18, 0.08)
	tween.tween_property(visual, "scale", _visual_base_scale, 0.22) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	interaction_completed.emit(self)


func show_range(shown: bool) -> void:
	range_ring.scale = Vector3(profile.interaction_range, 1.0, profile.interaction_range)
	range_ring.visible = shown


func state_name() -> String:
	match _state:
		VisualState.HOVERED: return "hovered"
		VisualState.ACTIVE: return "active"
		VisualState.COMPLETED: return "completed"
		VisualState.DEPLETED: return "depleted"
		VisualState.LIT: return "lit"
		VisualState.REFUSED: return "refused"
		_: return "available"


# ------------------------------------------------------------------ visual ---

func _set_state(new_state: VisualState) -> void:
	_state = new_state
	_apply_tint()


func _apply_tint() -> void:
	var tint := Color.WHITE
	var strength := 0.0
	match _state:
		VisualState.HOVERED:
			tint = profile.hover_tint
			strength = profile.tint_strength * 0.6
		VisualState.ACTIVE:
			tint = profile.active_tint
			strength = profile.tint_strength
		VisualState.COMPLETED:
			tint = profile.complete_tint
			strength = profile.tint_strength
		VisualState.DEPLETED:
			tint = profile.depleted_tint
			strength = profile.tint_strength
		VisualState.LIT:
			tint = profile.active_tint
			strength = profile.tint_strength * 0.5
		VisualState.REFUSED:
			tint = profile.refuse_tint
			strength = profile.tint_strength
	for i in _materials.size():
		_materials[i].albedo_color = _base_colours[i].lerp(tint, strength)
