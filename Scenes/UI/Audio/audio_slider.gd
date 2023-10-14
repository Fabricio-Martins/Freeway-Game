extends HSlider

@export
var bus_name: String

var bus_index: int

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name) # Pega o indíce do Bus pelo nome
	value_changed.connect(_on_value_changed) # Sinal atráves do código
	
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index)) # Permite utilizar em qualquer momento do jogo
	
func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))

