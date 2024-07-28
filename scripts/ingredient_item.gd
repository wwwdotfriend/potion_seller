extends Resource
class_name IngredientItem

@export var name: String = ""
@export var texture: Texture2D
@export var mortar_sprite: Texture2D
@export var crushed_sprite: Texture2D
@export var powder_sprite: Texture2D
@export var scene_path: String = ""
enum ingredient_states { RAW, CRUSHED }
