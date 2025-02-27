-- Copyright (c) <2015> <Miguel Angel Sagreras>                                    --
--                                                                                 --
-- Permission is hereby granted, free of charge, to any person obtaining a copy of --
-- this software and associated documentation files (the "Software"), to deal in   --
-- the Software without restriction, including without limitation the rights to    --
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies   --
-- of the Software, and to permit persons to whom the Software is furnished to do  --
-- so, subject to the following conditions:                                        --
--                                                                                 --
-- The above copyright notice and this permission notice shall be included in all  --
-- copies or substantial portions of the Software.                                 --
--                                                                                 --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR i    --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,        --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE     --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER          --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,   --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE   --
-- SOFTWARE.                                                                       --
--                                                                                 --

library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;
use hdl4fpga.base.all;

package usbpkg is
	constant tk_out    : std_logic_vector := x"1";
	constant tk_sof    : std_logic_vector := x"5";
	constant tk_in     : std_logic_vector := x"9";
	constant tk_setup  : std_logic_vector := x"d";

	constant data0     : std_logic_vector := x"3";
	constant data1     : std_logic_vector := x"b";

	constant hs_ack    : std_logic_vector := x"2";
	constant hs_nack   : std_logic_vector := x"a";
	constant hs_stall  : std_logic_vector := x"e";

	type requests is (
    	-- get_status,
    	-- clear_status,
    	-- set_feature,
    	set_address,
    	get_descriptor,
    	-- set_descriptor,
    	-- get_configuration,
    	set_configuration);
    	-- get_interface,
    	-- set_interface,
    	-- synch_frame);

	type bit_requests is array(requests) of bit;
	type requestid_vector is array(requests) of std_logic_vector(4-1 downto 0);
	constant request_ids : requestid_vector := (
	    -- get_status        => x"0",
	    -- clear_status      => x"1",
	    -- set_feature       => x"3",
	    set_address       => x"5",
	    get_descriptor    => x"6",
	    -- set_descriptor    => x"7",
	    -- get_configuration => x"8",
	    set_configuration => x"9");
	    -- get_interface     => x"a",
	    -- set_interface     => x"b",
	    -- synch_frame       => x"c");

	type decriptor_types is (
		device, 
		config, 
		string, 
		interface, 
		endpoint);
	type decriptortypes_vector is array(decriptor_types) of std_logic_vector(8-1 downto 0);
	constant decriptortypes_ids : decriptortypes_vector := (
    	device    => x"01",
    	config    => x"02",
    	string    => x"03",
    	interface => x"04",
    	endpoint  => x"05");
	
