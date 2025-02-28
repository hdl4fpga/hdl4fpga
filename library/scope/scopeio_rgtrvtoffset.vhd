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

entity scopeio_rgtrvtoffset is
	generic (
		rgtr      : boolean := true);
	port (
		rgtr_clk    : in  std_logic;
		rgtr_dv    : in  std_logic;
		rgtr_id    : in  std_logic_vector(8-1 downto 0);
		rgtr_data  : in  std_logic_vector;

		vt_ena     : out std_logic;
		vt_dv      : out std_logic;
		vt_chanid  : out std_logic_vector;
		vt_offset  : out std_logic_vector);

end;

architecture def of scopeio_rgtrvtoffset is

	signal ena    : std_logic;
	signal chanid : std_logic_vector(vt_chanid'range);
	signal offset : std_logic_vector(vt_offset'range);

begin

	ena    <= setif(rgtr_id=rid_vtaxis, rgtr_dv);
	chanid <= std_logic_vector(resize(unsigned(bitfield(rgtr_data, vtchanid_id, vtoffset_bf)), chanid'length));
	offset <= std_logic_vector(resize(  signed(bitfield(rgtr_data, vtoffset_id, vtoffset_bf)), offset'length));

	dv_p : process (rgtr_clk)
	begin
		if rising_edge(rgtr_clk) then
			vt_dv <= ena;
		end if;
	end process;
	vt_ena <= ena;

	rgtr_e : if rgtr generate
		process (rgtr_clk)
		begin
			if rising_edge(rgtr_clk) then
				if ena='1' then
					vt_offset <= offset;
					vt_chanid <= chanid;
				end if;
			end if;
		end process;
	end generate;

	norgtr_e : if not rgtr generate
		vt_offset <= offset;
		vt_chanid <= chanid;
	end generate;

end;

