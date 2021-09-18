extends Spatial

const DAMAGE = 25 # Damage dealt with each pistol shot.

const IDLE_ANIM_NAME = "Pistol_idle"
const FIRE_ANIM_NAME = "Pistol_fire"

var is_weapon_enabled = false

var bullet_scene = preload("Bullet_Scene.tscn")

var player_node = null

var ammo_in_weapon = 10
var spare_ammo = 20
const AMMO_IN_MAG = 10

const CAN_RELOAD = true # Whether or not the weapon is able to reload.
const CAN_REFILL = true

const RELOADING_ANIM_NAME = "Pistol_reload" # Name of the reloading animation.

func _ready():
	pass

func fire_weapon():
	var clone = bullet_scene.instance()
	var scene_root = get_tree().root.get_children()[0]
	scene_root.add_child(clone)

	clone.global_transform = self.global_transform
	clone.scale = Vector3(4, 4, 4)
	clone.BULLET_DAMAGE = DAMAGE
	ammo_in_weapon -= 1

	player_node.create_sound("pistol_shot", self.global_transform.origin)

func equip_weapon():
	if player_node.animation_manager.current_state == IDLE_ANIM_NAME:
		is_weapon_enabled = true
		return true

	if player_node.animation_manager.current_state == "Idle_unarmed":
		player_node.animation_manager.set_animation("Pistol_equip")

	return false

func unequip_weapon():
	if player_node.animation_manager.current_state == IDLE_ANIM_NAME:
		if player_node.animation_manager.current_state != "Pistol_unequip":
			player_node.animation_manager.set_animation("Pistol_unequip")

	if player_node.animation_manager.current_state == "Idle_unarmed":
		is_weapon_enabled = false
		return true
	else:
		return false

func reload_weapon():
	var can_reload = false

	if player_node.animation_manager.current_state == IDLE_ANIM_NAME:
		can_reload = true

	if spare_ammo <= 0 or ammo_in_weapon == AMMO_IN_MAG: # Checks to see if the player has ammo to reload.
		can_reload = false                               # The player cannot reload if they don't have ammo.

	if can_reload == true:                               # If they do have enough ammo to be able to reload.
		var ammo_needed = AMMO_IN_MAG - ammo_in_weapon   # Take ammo from weapon (spare) and set ammo in mag to full.

		if spare_ammo >= ammo_needed:
			spare_ammo -= ammo_needed
			ammo_in_weapon = AMMO_IN_MAG
		else:
			ammo_in_weapon += spare_ammo
			spare_ammo = 0

		player_node.animation_manager.set_animation(RELOADING_ANIM_NAME)
		player_node.create_sound("gun_cock", player_node.camera.global_transform.origin)

		return true

	return false

func reset_weapon():
	ammo_in_weapon = 10
	spare_ammo = 20
