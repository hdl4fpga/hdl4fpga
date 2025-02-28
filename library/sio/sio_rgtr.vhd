-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity sio_rgtr is
	generic (
		rid       : std_logic_vector(8-1 downto 0);
		rgtr      : boolean := true);
	port (
		rgtr_clk  : in  std_logic;
		rgtr_dv   : in  std_logic;
		rgtr_id   : in  std_logic_vector;
		rgtr_data : in  std_logic_vector;

		ena       : buffer std_logic;
		dv        : out std_logic;
		data      : out std_logic_vector);

end;

architecture def of sio_rgtr is

begin

	assert rgtr_id'length=rid'length
	report "Length of rgtr_id must be " & natural'image(rid'length) & " long"
	severity FAILURE;

	ena <=
	  setif(rgtr_id=reverse(rid), rgtr_dv) when rgtr_id'ascending else
	  setif(rgtr_id=rid, rgtr_dv);

	dv_p : process (rgtr_clk)
	begin
		if rising_edge(rgtr_clk) then
			dv <= ena;
		end if;
	end process;

	process (rgtr_clk, rgtr_data)

		function xxx (
			constant data : std_logic_vector;
			constant size : natural)
			return std_logic_vector is
		begin
			if data'ascending then
				return std_logic_vector(resize(unsigned(data), size));
			end if;
			return std_logic_vector(resize(rotate_left(unsigned(data), size), size));
		end;

	begin
		if rising_edge(rgtr_clk) then
			if ena='1' then
				data <= xxx(rgtr_data, data'length);
			end if;
		end if;
		if rgtr=false then
			data <= xxx(rgtr_data, data'length);
		end if;
	end process;

end;





