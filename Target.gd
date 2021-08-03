extends StaticBody

const TARGET_HEALTH = 40 # Amount of damage needed to break the target when at full health.
var current_health = 40 # Amount of health the target currently has.

var broken_target_holder

# The collision shape for the target.
# NOTE: this is for the whole target, not the pieces of the target.
var target_collision_shape

const TARGET_RESPAWN_TIME = 14 # Time taken (in seconds) for the target to respawn after being destroyed.
var target_respawn_timer = 0

export (PackedScene) var destroyed_target

func _ready():
	broken_target_holder = get_parent().get_node("Broken_Target_Holder")
	target_collision_shape = $Collision_Shape


func _physics_process(delta):
	if target_respawn_timer > 0:
		target_respawn_timer -= delta

		if target_respawn_timer <= 0:

			for child in broken_target_holder.get_children():
				child.queue_free()

			target_collision_shape.disabled = false
			visible = true
			current_health = TARGET_HEALTH


func bullet_hit(damage, bullet_transform):
	current_health -= damage

	if current_health <= 0:
		var clone = destroyed_target.instance()
		broken_target_holder.add_child(clone)

		for rigid in clone.get_children():
			if rigid is RigidBody:
				var center_in_rigid_space = broken_target_holder.global_transform.origin - rigid.global_transform.origin
				var direction = (rigid.transform.origin - center_in_rigid_space).normalized()
				# Apply the impulse with some additional force (I find 12 works nicely).
				rigid.apply_impulse(center_in_rigid_space, direction * 12 * damage)

		target_respawn_timer = TARGET_RESPAWN_TIME

		target_collision_shape.disabled = true
		visible = false
