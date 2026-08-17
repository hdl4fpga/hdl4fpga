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

library hdl4fpga;
use hdl4fpga.hdo.all;
use hdl4fpga.base.all;
use hdl4fpga.ipoepkg.all;

entity tb_ethtx is
	generic (
		sha  : string;
		data : string);
	port (
		req  : in  std_logic :='0';
		rdy  : buffer std_logic :='0';
		txc  : in  std_logic;
		txen : buffer std_logic;
		txd  : out std_logic_vector);
end;

architecture beh of tb_ethtx is

	function init_rom (
		constant data : string)
		return std_logic_vector is
		constant bcast  : string := "0xff_ff_ff_ff_ff_ff";
		constant spa    : string := hdo(data)**".spa";
		constant ethtyp : string := "0x0806";
		constant htype  : string := "0x0001";
		constant ptype  : string := "0x0800";
		constant hsize  : string := "0x06";
		constant psize  : string := "0x04";
		constant requst : string := "0x0001";
		constant tmac   : string := "0x00_00_00_00_00_00";
		constant tpa    : string := hdo(data)**".tpa";
	begin
		return 
			to_stdlogicvector(
				bcast & sha   & ethtyp & 
				htype & htype & ptype  & hsize & psize & requst & sha) & 
			aton(spa) & 
			to_stdlogicvector(tmac) & 
			aton(tpa);
	end;

	constant bitdata : std_logic_vector := reverse(init_rom(data));

	signal pyl_frm  : std_logic;
	signal pyl_irdy : std_logic;
	signal pyl_trdy : std_logic;
	signal pyl_data : std_logic_vector(txd'range);

begin

	process (txc)
		variable addr : natural range 0 to bitdata'length/txd'length;
	begin
		if rising_edge(txc) then
			pyl_data <= bitdata(addr*txd'length to (addr+1)*txd'length-1);
			pyl_frm  <= (rdy xor req);
			pyl_irdy <= (rdy xor req);
			if (rdy xor req)='1' then
				if pyl_trdy='1' then
					if addr > 0 then
						addr := addr - 1;
					else
						rdy <= req;
					end if;
				end if;
			else
				addr := bitdata'length/txd'length-1;
			end if;
		end if;
	end process;

	eth_e : entity hdl4fpga.eth_tx
	generic map (
		sha => to_stdlogicvector(sha))
	port map (
		mii_clk  => txc,
		mii_frm  => txen,
		mii_data => txd,
	
		pyl_frm  => pyl_frm,
		pyl_irdy => pyl_irdy,
		pyl_trdy => pyl_trdy,
		pyl_data => pyl_data);

end;
