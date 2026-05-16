extends Node3D

@onready var ball: RigidBody3D = $ball
@onready var vehículo: Node3D = $vehículo
@onready var ray_cast_3d: RayCast3D = $vehículo/RayCast3D
@onready var pivote: Marker3D = $Pivote

var speed_input = 0
var turn_input = 0
var acceleration = 30.0
var steering_angle = 20.0
var turn_speed = 3.0

var sphere_offset = Vector3(0, -1, 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ray_cast_3d.add_exception(ball)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	speed_input = (
		Input.get_action_strength("up") -
		Input.get_action_strength("down")
	) * acceleration
	
	turn_input = (
		Input.get_action_strength("left") -
		Input.get_action_strength("right")
	) * deg_to_rad(steering_angle)
	
func _physics_process(delta: float) -> void:
	vehículo.global_position = ball.global_position + sphere_offset
	pivote.global_position = ball.global_position
	pivote.rotation.y = vehículo.rotation.y	
	
	if not ray_cast_3d.is_colliding():
		return
		
	if speed_input > 1.0 or speed_input < 1.0:
		var current_basis = vehículo.global_transform.basis
		var rotated_basis = current_basis.rotated(current_basis.y, turn_input)
		var smoothed_basis = current_basis.slerp(rotated_basis, delta * turn_speed)
		vehículo.global_basis = smoothed_basis.orthonormalized()
		
	var direction = -vehículo.global_transform.basis.z
	ball.apply_central_force(direction * speed_input)
