extends Control

func _ready() -> void:
	get_node( "scenario1" ).connect( "pressed", func (): _on_press_button( "scenario1" ) )
	get_node( "scenario2" ).connect( "pressed", func (): _on_press_button( "scenario2" ) )

func _on_press_button( scene : String ) -> void:
	get_tree().change_scene_to_file( "res://" + scene + ".tscn" )
