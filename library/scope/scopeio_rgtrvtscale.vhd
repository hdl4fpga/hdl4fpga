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

entity scopeio_rgtrvtscale is
	generic (
		rgtr       : boolean := true);
	port (
		rgtr_clk   : in  std_logic;
		rgtr_dv    : in  std_logic;
		rgtr_id    : in  std_logic_vector(8-1 downto 0);
		rgtr_data  : in  std_logic_vector;

		vtscale_ena : out std_logic;
		vtscale_dv  : out std_logic;
		vtchan_id  : out std_logic_vector;
		vtscale_id  : out std_logic_vector);

end;

architecture def of scopeio_rgtrvtscale is

	signal ena     : std_logic;
	signal chanid : std_logic_vector(maxinputs_bits-1 downto 0);
	signal gainid : std_logic_vector(vtscale_id'range);

begin

	ena    <= setif(rgtr_id=rid_gain, rgtr_dv);
	chanid <= bitfield(rgtr_data, gainchanid_id, gain_bf);
	gainid <= bitfield(rgtr_data, gainid_id,     gain_bf);

	dv_p : process (rgtr_clk)
	begin
		if rising_edge(rgtr_clk) then
			vtscale_dv <= ena;
		end if;
	end process;
	vtscale_ena <= ena;

	rgtr_e : if rgtr generate
		process (rgtr_clk)
		begin
			if rising_edge(rgtr_clk) then
				if ena='1' then
					vtchan_id <= std_logic_vector(resize(unsigned(chanid), vtchan_id'length));
					vtscale_id <= std_logic_vector(resize(unsigned(gainid), vtscale_id'length));
				end if;
			end if;
		end process;
	end generate;

	norgtr_e : if not rgtr generate
		vtchan_id <= std_logic_vector(resize(unsigned(chanid), vtchan_id'length));
		vtscale_id <= std_logic_vector(resize(unsigned(gainid), vtscale_id'length));
	end generate;

end;
