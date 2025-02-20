extends Control

func _ready() -> void:
	for scenario in [ "scenario1", "scenario2", "scenario4", "scenario5"]:
		get_node( scenario ).connect( "pressed", func (): _on_press_button( scenario ) )

func _on_press_button( scene : String ) -> void:
	get_tree().change_scene_to_file( "res://" + scene + ".tscn" )
