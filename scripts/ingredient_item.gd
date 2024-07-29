extends Resource
class_name IngredientItem

@export var name: String = ""
@export var display_name: String = ""
@export var texture: Texture2D

@export var mortar_sprite: Texture2D
@export var crushed_sprite: Texture2D
@export var powder_sprite: Texture2D

@export var raw_scene_path: String = ""
@export var crushed_scene_path: String = ""
@export var potion_scene_path: String = ""

enum State { RAW, CRUSHED, CAULDRON, DONE }
var state = State.RAW
