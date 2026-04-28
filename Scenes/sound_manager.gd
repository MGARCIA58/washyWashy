extends Node
const CORPORATE_MUSIC_ZONE_HORIZONS_LOOP = preload("uid://caukexboevxt7")
const SKIN_UNLOCKED = preload("uid://cnlrhg5v1qbtt")
const WASHER_SELECTED = preload("uid://d2pgjkde4egus")
const COINS = preload("uid://csfj6364vhgp6")
const WASHER_BOUGHT = preload("uid://bcr17cxdr3hic")

@export var music_player: AudioStreamPlayer
@export var stream_players: Array[AudioStreamPlayer]

func play_audio(clip: AudioStream, volume: float) -> void:
	var free_player: AudioStreamPlayer = get_free_audio_player()
	if free_player:
		free_player.stream = clip
		free_player.volume_db = volume
		free_player.play()
		
func play_music() -> void:
		music_player.stream = CORPORATE_MUSIC_ZONE_HORIZONS_LOOP
		music_player.volume_db = 4
		music_player.play()	

func get_free_audio_player() -> AudioStreamPlayer:
	for audio: AudioStreamPlayer in stream_players:
		if not audio.playing:
				return audio
	return null

func play_coins() -> void:
	play_audio(COINS, 20)
	
func play_washer_selected() -> void:
	play_audio(WASHER_SELECTED, -16)
	
func play_skin_unlocked() -> void:
	play_audio(SKIN_UNLOCKED, -2)

func play_washer_bought() -> void:
	play_audio(WASHER_BOUGHT, -12)

func _on_music_player_finished() -> void:
	play_music()
