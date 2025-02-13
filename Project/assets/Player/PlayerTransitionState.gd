extends Node

var transitioned = 0 #helps with transition algorithm
var last_transition_vector = Vector2.ZERO
var initial = Vector2(388,174) #Starting position
var default_initial = initial

func reset():
	var last_transition_vector = Vector2.ZERO
	var initial = default_initial

