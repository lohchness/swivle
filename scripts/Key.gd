extends Node2D
class_name Key

@onready var letter = $Letter
@onready var score = $Score
@onready var area = $Area2D
@onready var collision = $Area2D/CollisionShape2D

signal select_signal(number : int)
signal deselect_signal(number : int)
signal is_removed(number : int)

const TOP = 0
const EDGE = 1
const SIDE = 2
const FONT = 3
var colors = [
	# top color,      edge color,      side color,      font color
	[Color("d9a066"), Color("ebc4af"), Color("8f563b"), Color("402b21")],
	[Color("ef5b5f"), Color("f69baf"), Color("ca3a59"), Color("ffdee5")],
	[Color("8fde5e"), Color("c6fe56"), Color("5bb84c"), Color("edecf2")],
	[Color("597dce"), Color("080912"), Color("30346d"), Color("6dc2ca")],
	[Color("f3792c"), Color("fabe54"), Color("b0362d"), Color("faebc8")],
	[Color("72a3a7"), Color("1e2a4a"), Color("405a73"), Color("1e2a4a")]
]
var shade_color = Color("000000", .5) # Grayscale with alpha value 133

var letter_points = {
	1 : ["E", "A", "I", "O", "N", "R", "T", "L", "S", "U"],
	2 : ["D", "G"],
	3 : ["B", "C", "M", "P"],
	4 : ["F", "H", "V", "W", "Y"],
	5 : ["K"],
	8 : ["J", "X"],
	10 : ["Q", "Z"]
}

var max_tilt : float = 0.15
var curr_tilt : float = 0

var number : int = 0
var selected = false
const SELECTED_PIXELS = 50 # amount of pixels to be raised when selected

var target_opacity : int
var base_position
var shade_base_position

var curr_scale
var base_scale
var zoom_in_scalar = 1.1

func _ready():
	base_position = position
	shade_base_position = $keySprites/Shade.position
	target_opacity = modulate.a8
	base_scale = scale
	curr_scale = base_scale
	
	# Choose a colour
	var color = colors.pick_random()
	$keySprites/Top.modulate = color[TOP]
	$keySprites/Edge.modulate = color[EDGE]
	$keySprites/Side.modulate = color[SIDE]
	$keySprites/Shade.modulate = shade_color
	letter.set("theme_override_colors/font_color", color[FONT])
	score.set("theme_override_colors/font_color", color[FONT])
	
	pass

func _physics_process(delta):
	if selected:
		position = lerp(position, base_position - Vector2(0, SELECTED_PIXELS), 25 * delta)
		# hacky fix, whatever
		$keySprites/Shade.position = lerp($keySprites/Shade.position, shade_base_position + Vector2(0, 20), 25 * delta) 
	else:
		position = lerp(position, base_position, 25 * delta)
		$keySprites/Shade.position = lerp($keySprites/Shade.position, shade_base_position, 25 * delta)

	# Hover on mouse wiggle
	for i : Sprite2D in $keySprites.get_children():
		i.rotation = curr_tilt
	$Letter.rotation = curr_tilt
	$Score.rotation = curr_tilt * 2
	curr_tilt /= 2
	
	# TODO : Scale from center
	#scale = lerp(scale, curr_scale, 50 * delta)
	
	# Disappear on submit
	modulate.a8 = lerp(modulate.a8, target_opacity, 25 * delta) 
	if (modulate.a8 == 0):
		queue_free()

func _on_area_2d_input_event(viewport, event, shape_idx):
	# Prevents from triggering twice in one frames
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		self.on_click()

func set_base_position(p : Vector2):
	base_position = p

func on_click():
	if !selected:
		select()
	else:
		deselect()

## GETTERS AND SETTERS ##

func get_letter() -> String:
	return letter.text

func set_letter(l : String) -> void:
	#assert(len(l) == 1)
	letter.text = l
	set_score()

func get_score():
	return int(score.text)

func set_score():
	for point in letter_points:
		if letter.text in letter_points[point]:
			score.text = str(point)

func select():
	select_signal.emit(number)
	selected = true

func deselect():
	deselect_signal.emit(number)
	selected = false

func set_number(i : int):
	number = i

func get_number():
	return number

func disappear():
	target_opacity = 0
	pass

func _on_area_2d_mouse_entered():
	wiggle()
	zoom_in()


func wiggle():
	curr_tilt = max_tilt


func zoom_in():
	curr_scale = base_scale * zoom_in_scalar

func zoom_out():
	curr_scale = base_scale

func _on_area_2d_mouse_exited():
	zoom_out()
