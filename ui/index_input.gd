extends Control

@onready
var line_edit = $MarginContainer/HBoxContainer/LineEdit

var pool: Pool

signal i_changed

func _ready():
	pass # Replace with function body.


func refresh():
	if pool == null: return
	line_edit.text = str(pool.i)

func _on_line_edit_text_submitted(new_text):
	if pool == null: return
	var i = clamp(int(new_text), 1, len(pool.chromosomes))
	line_edit.text = str(pool.i)
	if pool == null:
		return
	pool.i = i
	i_changed.emit()


func _on_ll_button_down():
	if pool == null: return
	pool.i = 1
	line_edit.text = str(pool.i)
	i_changed.emit()


func _on_l_button_down():
	if pool == null: return
	pool.i = clamp(pool.i - 1, 1, len(pool.chromosomes))
	line_edit.text = str(pool.i)
	i_changed.emit()


func _on_r_button_down():
	if pool == null: return
	pool.i = clamp(pool.i + 1, 1, len(pool.chromosomes))
	line_edit.text = str(pool.i)
	i_changed.emit()


func _on_rr_button_down():
	if pool == null: return
	pool.i = len(pool.chromosomes)
	line_edit.text = str(pool.i)
	i_changed.emit()
