extends Node

func _ready():
  SilentWolf.configure({
	"api_key": "mrYW3dEN4i1QXSqYNq9U14zIAPGuCSCz4fT4wp4W",
	"game_id": "Freeway",
	"log_level": 1
  })

  SilentWolf.configure_scores({
	"open_scene_on_close": "res://scenes/MainPage.tscn"
  })


