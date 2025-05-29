library ieee;
use ieee.std_logic_1164.all;

entity acyiib is
	generic (
		debug : boolean := false);
	port (
		bank1 : inout std_logic_vector(1 to 36);
		bank2 : inout std_logic_vector(1 to 36);
		bank3 : inout std_logic_vector(1 to 36);
		bank4 : inout std_logic_vector(1 to 36));

	attribute chip_pin : string;
	attribute chip_pin of bank1 : signal is
		" 1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18" &
		"19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31 ,32, 33, 34, 35, 36";
	attribute chip_pin of bank4 : signal is
		"37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54" &
		"55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72";
	attribute chip_pin of bank2 : signal is
		" 73,  74,  75,  76,  77,  78,  79,  80,  81,  82,  83,  84,  85,  86,  87,  88,  89,  90" &
		" 91,  92,  93,  94,  95,  96,  97,  98,  99, 100, 101, 102, 103, 104, 105, 106, 107, 108";
	attribute chip_pin of bank3 : signal is
		"109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121 ,122, 123, 124, 125, 126" &
		"127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144";

	alias osc_50mhz is bank1(17);
	constant osc50mhz_freq : real := 50.0e6;

end;
