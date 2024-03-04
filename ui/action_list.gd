extends Control

const ACTIONS = [{
	"key": "random",
	"inputs": [{
		"key": "n",
		"value": 100
	}, {
		"key": "m",
		"value": 25
	}],
}, {
	"key": "mutate",
	"inputs": [{
		"key": "n",
		"value": 100
	}, {
		"key": "p",
		"value": 0.3
	}, {
		"key": "q",
		"value": 0.3
	}, {
		"key": "dx",
		"value": 0.1
	}, {
		"key": "dw",
		"value": 0.1
	}],
}, {
	"key": "cross",
	"inputs": [{
		"key": "n",
		"value": 100
	}],
}, {
	"key": "discard",
	"inputs": [{
		"key": "n",
		"value": 100
	}],
}, {
	"key": "hex_init",
	"inputs": [{
		"key": "n",
		"value": 100
	}],
}, {
	"key": "test",
	"inputs": [],
#}, {
	#"key": "rescore",
	#"inputs": [{
		#"key": "mult_d",
		#"value": 1.0
	#}, {
		#"key": "mult_g",
		#"value": 0.01
	#}],
}]

signal action_oked(key:String)

const TitleScene = preload("res://ui/title.tscn")
const InputScene = preload("res://ui/input.tscn")
const ButtonScene = preload("res://ui/button.tscn")

func _ready():
	var parent = $MarginContainer/VBoxContainer
	for child in parent.get_children():
		child.free()
	for action in ACTIONS:
		var node
		node = TitleScene.instantiate()
		node.get_node("PanelContainer/Label").text = action.key
		parent.add_child(node)
		var edits = {}
		for input in action.inputs:
			node = InputScene.instantiate()
			node.get_node("MarginContainer/Label").text = input.key
			var edit: LineEdit= node.get_node("LineEdit")
			edit.text = str(input.value)
			edits[input.key] = edit
			edit.text_submitted.connect(on_text_submitted.bind(action.key, edits))
			parent.add_child(node)
		node = ButtonScene.instantiate()
		node.get_node("Button").button_down.connect(on_ok.bind(action.key, edits))
		parent.add_child(node)

func on_text_submitted(text, key, edits):
	on_ok(key, edits)

func on_ok(key, edits, text=null):
	var data = {}
	for k in edits:
		var edit = edits[k]
		var x = float(edit.text)
		edit.text = str(x)
		data[k] = x
	action_oked.emit(key, data)
