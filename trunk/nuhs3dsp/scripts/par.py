#! /usr/bin/python
import ddrpar

nuhs3dsp = [
	{
		'delayed_dqs' :  {
			'lut' :  [ 
				{ 'inst' : 'lutn', 'slice' : "X0Y82", 'bel' : "G" } ,
				{ 'inst' : 'lutp', 'slice' : "X0Y82", 'bel' : "F" } ] },
#			'taps' : [
#				[ "X0Y83", "F" ], [ "X2Y83", "F" ], [ "X0Y83", "G" ], [ "X2Y83", "G" ] ] } ,
		'read' : {
			'sys_cntr' : [ "X2Y80", "X2Y80", "X2Y81", "X2Y81" ],
			'ddr_cntr' : [
				[ "X0Y80", "X0Y80", "X0Y81", "X0Y81" ],
				[ "X3Y80", "X3Y80", "X3Y81", "X3Y81" ] ],
			'ram' : [
				[ "X2Y86", "X2Y87", "X2Y84", "X2Y85", "X2Y78", "X2Y77", "X2Y76", "X2Y75" ],
				[ "X0Y86", "X0Y87", "X0Y84", "X0Y85", "X0Y78", "X0Y77", "X0Y76", "X0Y75" ] ] },
		'write' :  {
			'sys_cntr' : [ "X7Y80", "X7Y80", "X7Y81", "X7Y81" ],
			'ddr_cntr' : [
				[ "X5Y80", "X5Y80", "X5Y81", "X5Y81" ],
				[ "X5Y82", "X5Y82", "X5Y83", "X5Y83" ] ],
			'ram' : [
				[ "X6Y86", "X6Y87", "X6Y84", "X6Y85", "X6Y78", "X6Y77", "X6Y76", "X6Y75" ],
				[ "X4Y86", "X4Y87", "X4Y84", "X4Y85", "X4Y78", "X4Y77", "X4Y76", "X4Y75" ] ] },
			},
	{
		'delayed_dqs' :  {
			'lut' :  [ 
				{ 'inst'  : 'lutn', 'slice' : "X0Y60", 'bel'   : "G" } ,
				{ 'inst'  : 'lutp', 'slice' : "X0Y60", 'bel'   : "F" } ] },
#			'taps' : [ 
#				[ "X0Y61", "F" ], [ "X2Y61", "F" ], [ "X0Y61", "G" ], [ "X2Y61", "G" ] ] },
		'read' : {
			'sys_cntr' : [ "X2Y64", "X2Y64", "X2Y65", "X2Y65" ],
			'ddr_cntr' : [
				[ "X0Y64", "X0Y64", "X0Y65", "X0Y65" ],
				[ "X3Y64", "X3Y64", "X3Y65", "X3Y65" ] ],
			'ram' : [
				[ "X2Y68", "X2Y71", "X2Y62", "X2Y67", "X2Y58", "X2Y59", "X2Y54", "X2Y55" ],
				[ "X0Y68", "X0Y71", "X0Y62", "X0Y67", "X0Y58", "X0Y59", "X0Y54", "X0Y55" ] ] },
		'write' :  {
			'sys_cntr' : [ "X7Y62", "X7Y62", "X7Y63", "X7Y63" ],
			'ddr_cntr' : [
				[ "X5Y64", "X5Y64", "X5Y65", "X5Y65" ],
				[ "X5Y62", "X5Y62", "X5Y63", "X5Y63" ] ],
			'ram' : [
				[ "X6Y68", "X6Y71", "X6Y62", "X6Y67", "X6Y58", "X6Y59", "X6Y54", "X6Y55" ],
				[ "X4Y68", "X4Y71", "X4Y62", "X4Y67", "X4Y58", "X4Y59", "X4Y54", "X4Y55" ] ] },
			}
	]


nuhs3dsp.reverse()
nuhs3dsp[0]['read']['ram'][0].reverse()
nuhs3dsp[0]['read']['ram'][1].reverse()
nuhs3dsp[0]['write']['ram'][0].reverse()
nuhs3dsp[0]['write']['ram'][1].reverse()
nuhs3dsp[1]['read']['ram'][0].reverse()
nuhs3dsp[1]['read']['ram'][1].reverse()
nuhs3dsp[1]['write']['ram'][0].reverse()
nuhs3dsp[1]['write']['ram'][1].reverse()

ddrpar.chip(nuhs3dsp)
