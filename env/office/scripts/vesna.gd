extends CharacterBody3D


const SPEED = 10.0
const ACCELERATION = 8.0
const JUMP_VELOCITY = 4.5

@export var PORT : int
var tcp_server := TCPServer.new()
var ws := WebSocketPeer.new()

var regions_dict : Dictionary = {}
var current_region = ""

var end_communication = true

var target_movement : String = "empty"

@onready var navigator : NavigationAgent3D = $NavigationAgent3D
@onready var jump_anim = $Body/Jump
@onready var idle_anim = $Body/Idle
@onready var run_anim = $Body/Run

func _ready() -> void:
	if tcp_server.listen( PORT ) != OK:
		push_error( "Unable to start the srver" )
		set_process( false )
	for region in get_node( "/root/Root/NavigationRegion3D/Regions").get_children():
		region.connect( "body_entered", func( body) : _on_area_body_entered( region.name, body ) )
	for door in get_node("/root/Root/NavigationRegion3D/Doors").get_children():
		door.get_node("Area3D").connect( "body_entered", func( body) : _on_area_body_entered( door.name, body ) )
	play_idle()
	
func _process(delta: float) -> void:
	while tcp_server.is_connection_available():
		var conn : StreamPeerTCP = tcp_server.take_connection()
		assert( conn != null )
		ws.accept_stream( conn )
		
	ws.poll()
	
	if ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
		while ws.get_available_packet_count():
			var msg : String = ws.get_packet().get_string_from_ascii()
			print( "Received msg ", msg )
			var intention : Dictionary = JSON.parse_string( msg )
			manage( intention )

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if navigator.is_target_reached() or navigator.is_navigation_finished():
		play_idle()
		velocity.x = 0
		velocity.z = 0
		if not end_communication:
			signal_end_movement()
			
	elif not navigator.is_navigation_finished():
		play_run()
		var direction = ( navigator.get_next_path_position() - global_position ).normalized()
		rotation.y = atan2( -direction.z, direction.x )
		
		velocity = velocity.lerp( direction * SPEED, ACCELERATION * delta )
		
	#else:
		#velocity.x = 0
		#velocity.z = 0
		#play_idle()
#
	move_and_slide()
	
func _on_area_body_entered( region_name, body ):
	if ( body.name == self.name ):
		print( "Agent ", self.name, " entered region ", region_name )
		if ( region_name == target_movement ):
			signal_end_movement()
			navigator.set_target_position( global_position )
	
func _exit_tree() -> void:
	ws.close()
	tcp_server.stop()

func manage( intention : Dictionary ) -> void:
	var sender : String = intention[ 'sender' ]
	var receiver : String = intention[ 'receiver' ]
	var type : String = intention[ 'type' ]
	var data : Dictionary = intention[ 'data' ]
	if type == 'walk':
		var target : String = data[ 'target' ]
		var id : int = data[ 'id' ]
		walk( target, id )
	elif type == 'region':
		var new_region : String = data[ 'region' ]
		update_region( new_region )
	elif type == 'say':
		var performative : String = data[ 'performative' ]
		var recipient : String = data[ 'recipient' ]
		var msg : String = data[ 'msg' ]
		display_msg( performative, recipient, msg )

func walk( target, id ):
	var target_region = get_node("/root/Root/NavigationRegion3D/Markers/" + target )
	if target_region == null:
		target_region = get_node("/root/Root/NavigationRegion3D/Regions/" + target )
	if target_region == null:
		target_region = get_node("/root/Root/NavigationRegion3D/Doors/" + target )
	navigator.set_target_position( target_region.global_position )
	target_movement = target
	play_run()
	end_communication = false
	
func signal_end_movement( ) -> void:
	target_movement = "empty"
	var log : Dictionary = {}
	log[ 'sender' ] = 'body'
	log[ 'receiver' ] = 'vesna'
	log[ 'type' ] = 'signal'
	var msg : Dictionary = {}
	msg[ 'type' ] = 'movement'
	msg[ 'status' ] = 'completed'
	msg[ 'reason' ] = 'destination_reached'
	log[ 'data' ] = msg
	ws.send_text( JSON.stringify( log ) )
	end_communication = true

func update_region( new_region : String ) -> void:
	current_region = new_region
	if current_region not in regions_dict:
		regions_dict[ current_region ] = []
		
func play_idle() -> void:
	if run_anim and run_anim.is_playing():
		run_anim.stop()
	idle_anim.play( "Root|Idle" )

func play_run() -> void:
	if idle_anim.is_playing():
		idle_anim.stop()
	run_anim.play( "Root|Run" )

func display_msg( performative : String, recipient : String, msg : String ):
	var cloud : Sprite3D = get_node( "Sprite3D" )
	cloud.visible = true
	var tween = cloud.create_tween()
	tween.tween_property(cloud, "rotation_degrees:z", 10, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(cloud, "rotation_degrees:z", -10, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(cloud, "rotation_degrees:z", 0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.set_loops()
	await get_tree().create_timer(2.0).timeout
	cloud.visible = false
