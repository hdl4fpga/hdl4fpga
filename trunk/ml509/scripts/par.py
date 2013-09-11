#!/usr/bin/env python

# = [
#	[ "L24",  "Y139" ],
#	[ "L25",  "Y138" ],
#	[ "M25",  "Y136" ],
#	[ "J27",  "Y135" ],
#	[ "L26",  "Y138" ],
#	[ "J24",  "Y137" ],
#	[ "M26",  "Y136" ],
#	[ "G25",  "Y134" ],
#
#	[ "G26",  "Y134" ],
#	[ "H24",  "Y133" ],
#	[ "K28",  "Y126" ],
#	[ "K27",  "Y125" ],
#	[ "H25",  "Y133" ],
#	[ "F25",  "Y132" ],
#	[ "L28",  "Y126" ],
#	[ "M28",  "Y124" ],
#
#	[ "N28",  "Y124" ],
#	[ "P27",  "Y123" ],
#	[ "N25",  "Y121" ],
#	[ "T24",  "Y120" ],
#	[ "P26",  "Y123" ],
#	[ "N24",  "Y122" ],
#	[ "P25",  "Y121" ],
#	[ "R24",  "Y120" ],
#
#	[ "V24",  "Y59" ],
#	[ "W26",  "Y58" ],
#	[ "W25",  "Y57" ],
#	[ "V28",  "Y54" ],
#	[ "W24",  "Y59" ],
#	[ "Y26",  "Y58" ],
#	[ "Y27",  "Y56" ],
#	[ "V29",  "Y52" ],
#
#	[ "W27",  "Y56" ],
#	[ "V27",  "Y54" ],
#	[ "W29",  "Y52" ],
#	[ "AC30", "Y49" ],
#	[ "V30",  "Y55" ],
#	[ "W31",  "Y53" ],
#	[ "AB30", "Y49" ],
#	[ "AC29", "Y46" ],
#
#	[ "AA25", "Y39" ],
#	[ "AB27", "Y38" ],
#	[ "AA24", "Y37" ],
#	[ "AB26", "Y36" ],
#	[ "AA26", "Y39" ],
#	[ "AC27", "Y38" ],
#	[ "AB25", "Y36" ],
#	[ "AC28", "Y35" ],

import ddrpar

ml509 = [
	{
		'delayed_dqs' :  {
			'lut' :  [ 
				{ 'inst'  : 'lutn', 'slice' : "X2Y48" } ,
				{ 'inst'  : 'lutp', 'slice' : "X2Y48" } ] },
#			'taps' : [
#				[ "X2Y29" ], [ "X2Y29" ], [ "X2Y29" ], [ "X2Y29" ] ],
#		'pads' : [ "AF30", "AK31",  "AF31",  "AD30",  "AJ30",  "AF29",  "AD29",  "AE29" ],
		'read' : {
			'sys_cntr' : [ "X2Y46", "X2Y46", "X2Y46", "X2Y46" ],
			'ddr_cntr' : [
				[ "X2Y43", "X2Y43", "X2Y43", "X2Y43" ],
				[ "X2Y47", "X2Y47", "X2Y47", "X2Y47" ] ],
			'ram' : [
				[ "X0Y41", "X0Y41", "X0Y46", "X0Y46", "X0Y41", "X0Y41", "X0Y46", "X0Y46" ],
				[ "X0Y44", "X0Y44", "X0Y48", "X0Y48", "X0Y44", "X0Y44", "X0Y48", "X0Y48" ] ] },
		'write' :  {
			'sys_cntr' : [ "X2Y44", "X2Y44", "X2Y44", "X2Y44" ],
			'ddr_cntr' : [
				[ "X2Y42", "X2Y42", "X2Y42", "X2Y42" ],
				[ "X2Y45", "X2Y45", "X2Y45", "X2Y45" ] ],
			'dm' : [ [ "X0Y43", "X1Y43" ],  [ "X0Y43", "X1Y44" ] ],
			'ram' : [
				[ [ "X0Y40", "X1Y40" ], [ "X0Y40", "X1Y40" ], [ "X0Y45", "X1Y45" ], [ "X0Y45", "X1Y45" ],
				  [ "X0Y40", "X1Y40" ], [ "X0Y40", "X1Y40" ], [ "X0Y45", "X1Y45" ], [ "X0Y45", "X1Y45" ] ],
				[ [ "X0Y42", "X1Y42" ], [ "X0Y42", "X1Y42" ], [ "X0Y47", "X1Y47" ], [ "X0Y47", "X1Y47" ],
				  [ "X0Y42", "X1Y42" ], [ "X0Y42", "X1Y42" ], [ "X0Y47", "X1Y47" ], [ "X0Y47", "X1Y47" ] ] ] },
			},
	{
		'delayed_dqs' :  {
			'lut' :  [ 
				{ 'inst' : 'lutn', 'slice' : "X2Y28" } ,
				{ 'inst' : 'lutp', 'slice' : "X2Y28" } ] },
#			'taps' : [ 
#				[ "X2Y47" ], [ "X2Y47" ], [ "X2Y47" ], [ "X2Y47" ] ],
#		'pads' : [ "AH27", "AF28",  "AH28",  "AA28",  "AG25",  "AJ26",  "AG28",  "AB28" ]
		'read' : {
			'sys_cntr' : [ "X2Y31", "X2Y31", "X2Y31", "X2Y31" ],
			'ddr_cntr' : [
				[ "X2Y32", "X2Y32", "X2Y32", "X2Y32" ],
				[ "X2Y34", "X2Y34", "X2Y34", "X2Y34" ] ],
			'ram' : [
				[ "X0Y28", "X0Y28", "X0Y33", "X0Y33", "X0Y28", "X0Y28", "X0Y33", "X0Y33" ],
				[ "X0Y30", "X0Y30", "X0Y35", "X0Y35", "X0Y30", "X0Y30", "X0Y35", "X0Y35" ] ] },
		'write' :  {
			'sys_cntr' : [ "X2Y41", "X2Y41", "X2Y41", "X2Y41" ],
			'ddr_cntr' : [
				[ "X2Y29", "X2Y29", "X2Y29", "X2Y29" ],
				[ "X2Y30", "X2Y30", "X2Y30", "X2Y30" ] ],
			'dm'  : [ [ "X0Y32", "X1Y33" ], [ "X0Y32", "X1Y32" ] ],
			'ram' : [
				[ [ "X0Y27", "X1Y27" ], [ "X0Y27", "X1Y27" ], [ "X0Y31", "X1Y31" ], [ "X0Y31", "X1Y31" ], 
				  [ "X0Y27", "X1Y27" ], [ "X0Y27", "X1Y27" ], [ "X0Y31", "X1Y31" ], [ "X0Y31", "X1Y31" ]  ],
				[ [ "X0Y29", "X1Y29" ], [ "X0Y29", "X1Y29" ], [ "X0Y34", "X1Y34" ], [ "X0Y34", "X1Y34" ],
				  [ "X0Y29", "X1Y29" ], [ "X0Y29", "X1Y29" ], [ "X0Y34", "X1Y34" ], [ "X0Y34", "X1Y34" ]  ] ] },
			},
	]

ddrpar.chip(ml509)
