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
use hdl4fpga.hdo.all;
use hdl4fpga.base.all;
use hdl4fpga.ipoepkg.all;

entity tb_eth is
	generic (
		data        : string;
		default_tha : string := "x00_27_0e_0f_f5_95";
		default_sda : string := "192.168.0.2";
		default_pda : string := "192.168.0.14");
	port (
		req  : in  std_logic :='0';
		rdy  : buffer std_logic :='0';
		txc  : in  std_logic;
		txen : buffer std_logic;
		txd  : out std_logic_vector);
end;

architecture beh of tb_eth is
	
	constant bitrom : std_logic_vector := to_stdlogicvector(tha) & to_stdlogicvector(pyl);
	function proto (
		constant arg : string)
		return arg is 
	begin
		if arg="arp" then
			return "{type:0x806}";
		elsif arg="udp" then
			return "{type:0x800,proto:0x11}";
		elsif arg="icmp" then
			return "{type:0x800,proto:0x01}";
		end if;
	end;

	function init_rom (
		constant data : string)
		return string is
		constant tha : string := hdo(data)*".tha=" & default_tha;
		constant typ : string := proto(hdo(data)*".proto");
	begin
		
	end;

	signal addr     : unsigned(0 to unsigned_num_bits(bitrom'length/txd'length-1)-1);

	signal pyl_frm  : std_logic;
	signal pyl_irdy : std_logic;
	signal pyl_trdy : std_logic;
	signal pyl_data : std_logic_vector(txd'range);

begin

	process (txc)
	begin
		if rising_edge(txc) then
			if (rdy xor req)='1' then
				if addr < (bitrom'length/txd'length-1) then
					if pyl_trdy='1' then
						addr <= addr + 1;
					end if;
				elsif (pyl_irdy and pyl_trdy)='1' then
					rdy <= req;
				end if;
			else
				addr <= (others => '0');
			end if;
		end if;
	end process;

	pyl_frm  <= 
		'0' when rdy=req else
		'1' when addr < (bitrom'length/txd'length-1) else
		'0';

	pyl_irdy <= '1' when rdy /= req else '0';
	rom_e : entity hdl4fpga.rom
	generic map (
		bitdata => reverse(bitrom,8))
	port map (
		addr => std_logic_vector(addr),
		data => pyl_data);

	eth_e : entity hdl4fpga.eth_tx
   	generic map (
   		sha => sha)
   	port map (
   		mii_clk  => txc,
   		mii_frm  => txen,
   		mii_data => txd,

   		pyl_frm  => pyl_frm,
   		pyl_irdy => pyl_irdy,
   		pyl_trdy => pyl_trdy,
   		pyl_data => pyl_data);

end;
