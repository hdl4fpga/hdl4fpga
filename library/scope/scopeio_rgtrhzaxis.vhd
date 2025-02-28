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
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_rgtrhzaxis is
	generic (
		rgtr      : boolean := true);
	port (
		rgtr_clk  : in  std_logic;
		rgtr_dv   : in  std_logic;
		rgtr_id   : in  std_logic_vector(8-1 downto 0);
		rgtr_data : in  std_logic_vector;

		hz_ena    : out std_logic;
		hz_dv     : out std_logic;
		hz_scale  : out std_logic_vector;
		hz_offset : out std_logic_vector);

end;

architecture def of scopeio_rgtrhzaxis is

	signal ena    : std_logic;
	signal offset : std_logic_vector(hz_offset'range);
	signal scale  : std_logic_vector(hz_scale'range);

begin

	ena     <= setif(rgtr_id=rid_hzaxis, rgtr_dv);
	offset <= std_logic_vector(resize(signed(bitfield(rgtr_data, hzoffset_id, hzoffset_bf)), hz_offset'length));
	scale  <= bitfield(rgtr_data, hzscale_id,  hzoffset_bf);

	dv_p : process (rgtr_clk)
	begin
		if rising_edge(rgtr_clk) then
			hz_dv <= ena;
		end if;
	end process;
	hz_ena <= ena;

	rgtr_e : if rgtr generate
		process (rgtr_clk)
		begin
			if rising_edge(rgtr_clk) then
				if ena='1' then
					hz_offset <= offset;
					hz_scale  <= scale;
				end if;
			end if;
		end process;
	end generate;

	norgtr_e : if not rgtr generate
		hz_offset <= offset;
		hz_scale  <= scale;
	end generate;

end;

