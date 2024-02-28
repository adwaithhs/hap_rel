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
			var edit = node.get_node("LineEdit")
			edit.text = str(input.value)
			edits[input.key] = edit
			parent.add_child(node)
		node = ButtonScene.instantiate()
		node.get_node("Button").button_down.connect(on_ok.bind(action.key, edits))
		parent.add_child(node)

func on_ok(key, edits):
	var data = {}
	for k in edits:
		var edit = edits[k]
		var x = float(edit.text)
		edit.text = str(x)
		data[k] = x
	action_oked.emit(key, data)
