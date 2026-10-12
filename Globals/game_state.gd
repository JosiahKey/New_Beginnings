extends Node

###created as a work around for pausing. player inputs check to see 
#if state != 'Combat'
#	behave normally
### REVIEW LATER: would love to see a gamecontroller node that handles all inputs for this reason

var state = ""
var biome = "Plains"
var quest1_blachsmith_flag = false

func game_over_reset_flags():
	quest1_blachsmith_flag = false
