extends Spatial

export (bool) var use_raycast = false

const TURRET_DAMAGE_BULLET = 20 # Amount of damage dealt from a single bullet scene.
const TURRET_DAMAGE_RAYCAST = 5 # Amount of damage dealt from a single bullet raycast.

const FLASH_TIME = 0.1 # How long (in seconds) the muzzle flash mesh is visible.
var flash_timer = 0

const FIRE_TIME = 0.8 # Amount of time (in seconds) needed to fire a bullet.
var fire_timer = 0

var node_turret_head = null
var node_raycast = null
var node_flash_one = null
var node_flash_two = null

var ammo_in_turret = 20
const AMMO_IN_FULL_TURRET = 20 # Amount of ammo in full turret.
const AMMO_RELOAD_TIME = 4 # Amount of time it takes the turret to reload.
var ammo_reload_timer = 0

var current_target = null # The turrets current target.

var is_active = false

const PLAYER_HEIGHT = 3 # Amount of height added to each shot so the turret doesn't shoot at an entity's feet.

var smoke_particles

var turret_health = 60
const MAX_TURRET_HEALTH = 60 # amount of health a fully healed turret has.

const DESTROYED_TIME = 20 # Amount of time it take for a destroyed turret to repair/respawn.
var destroyed_timer = 0

var bullet_scene = preload("Bullet_Scene.tscn")

func _ready():

	$Vision_Area.connect("body_entered", self, "body_entered_vision")
	$Vision_Area.connect("body_exited", self, "body_exited_vision")

	node_turret_head = $Head
	node_raycast = $Head/Ray_Cast
	node_flash_one = $Head/Flash
	node_flash_two = $Head/Flash_2

	node_raycast.add_exception(self)
	node_raycast.add_exception($Base/Static_Body)
	node_raycast.add_exception($Head/Static_Body)
	node_raycast.add_exception($Vision_Area)

	node_flash_one.visible = false
	node_flash_two.visible = false

	smoke_particles = $Smoke
	smoke_particles.emitting = false

	turret_health = MAX_TURRET_HEALTH


func _physics_process(delta):

	if is_active == true:

		if flash_timer > 0:
			flash_timer -= delta

			if flash_timer <= 0:
				node_flash_one.visible = false
				node_flash_two.visible = false

		if current_target != null:

			node_turret_head.look_at(current_target.global_transform.origin + Vector3(0, PLAYER_HEIGHT, 0), Vector3(0, 1, 0))

			if turret_health > 0:

				if ammo_in_turret > 0:
					if fire_timer > 0:
						fire_timer -= delta
					else:
						fire_bullet()
				else:
					if ammo_reload_timer > 0:
						ammo_reload_timer -= delta
					else:
						ammo_in_turret = AMMO_IN_FULL_TURRET

	if turret_health <= 0:
		if destroyed_timer > 0:
			destroyed_timer -= delta
		else:
			turret_health = MAX_TURRET_HEALTH
			smoke_particles.emitting = false


func fire_bullet():

	if use_raycast == true:
		node_raycast.look_at(current_target.global_transform.origin + Vector3(0, PLAYER_HEIGHT, 0), Vector3(0, 1, 0))

		node_raycast.force_raycast_update()

		if node_raycast.is_colliding():
			var body = node_raycast.get_collider()
			if body.has_method("bullet_hit"):
				body.bullet_hit(TURRET_DAMAGE_RAYCAST, node_raycast.get_collision_point())

		ammo_in_turret -= 1

	else:
		var clone = bullet_scene.instance()
		var scene_root = get_tree().root.get_children()[0]
		scene_root.add_child(clone)

		clone.global_transform = $Head/Barrel_End.global_transform
		clone.scale = Vector3(8, 8, 8)
		clone.BULLET_DAMAGE = TURRET_DAMAGE_BULLET
		clone.BULLET_SPEED = 60

		ammo_in_turret -= 1

	node_flash_one.visible = true
	node_flash_two.visible = true

	flash_timer = FLASH_TIME
	fire_timer = FIRE_TIME

	if ammo_in_turret <= 0:
		ammo_reload_timer = AMMO_RELOAD_TIME


func body_entered_vision(body):
	if current_target == null:
		if body is KinematicBody:
			current_target = body
			is_active = true


func body_exited_vision(body):
	if current_target != null:
		if body == current_target:
			current_target = null
			is_active = false

			flash_timer = 0
			fire_timer = 0
			node_flash_one.visible = false
			node_flash_two.visible = false


func bullet_hit(damage, bullet_hit_pos):
	turret_health -= damage

	if turret_health <= 0:
		smoke_particles.emitting = true
		destroyed_timer = DESTROYED_TIME
