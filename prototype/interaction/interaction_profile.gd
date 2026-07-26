## One interaction, as data.
##
## The whole tuning surface for "click a thing and watch the character deal with
## it" lives here so it can be changed in the Inspector while the game is
## running. Disposable, like the rest of the prototype: this is not a production
## interaction system and it knows nothing about resources, inventory or skills.

class_name InteractionProfile
extends Resource

## What this object does when an interaction completes. Three cases, hard-coded,
## because there are three objects. This is NOT an effect system.
enum Role {
	PLACEHOLDER,  ## completes and resets; produces nothing
	LOG_SOURCE,   ## grants one log, then depletes permanently
	CAMPFIRE,     ## consumes one log and ignites, then stays lit
}

## Shown on the debug HUD.
@export var display_name := "Object"
@export var role: Role = Role.PLACEHOLDER

@export_group("Approach")
## The character stops and works once it is this close to the object.
@export_range(0.5, 8.0, 0.1) var interaction_range := 2.5
## Where the character aims for, as a fraction of interaction_range. Below 1.0
## so it walks comfortably INSIDE range rather than stopping exactly on the edge
## and re-triggering the approach every time it drifts.
@export_range(0.3, 1.0, 0.05) var approach_fraction := 0.7
## Progress does not start until the character is facing within this angle.
@export_range(1.0, 90.0, 1.0) var facing_tolerance_degrees := 20.0

@export_group("Interaction")
## Seconds of continuous work before the interaction completes.
@export_range(0.1, 10.0, 0.1) var duration := 1.6
## How long the completed state is held before the object becomes available
## again. Exists so repeated interactions can be tested, not as a respawn rule.
@export_range(0.0, 30.0, 0.5) var reset_seconds := 3.0

@export_group("Feedback")
@export var hover_tint := Color(1.0, 0.95, 0.7, 1.0)
@export var active_tint := Color(1.0, 0.75, 0.35, 1.0)
@export var complete_tint := Color(0.55, 0.85, 0.55, 1.0)
## Used for the depleted stump and any other spent state.
@export var depleted_tint := Color(0.32, 0.28, 0.24, 1.0)
## Flashed when the object refuses an interaction.
@export var refuse_tint := Color(0.9, 0.3, 0.25, 1.0)
@export_range(0.1, 3.0, 0.05) var refuse_flash_seconds := 0.5
## How strongly hover/active tints replace the object's own colour.
@export_range(0.0, 1.0, 0.05) var tint_strength := 0.55
## Pulses per second while interacting.
@export_range(0.0, 6.0, 0.1) var pulse_speed := 2.4
@export_range(0.0, 0.3, 0.01) var pulse_amount := 0.06
