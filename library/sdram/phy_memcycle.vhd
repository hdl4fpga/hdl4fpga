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
use hdl4fpga.sdrampkg.all;

entity phy_memcycle is
	port (
		clk        : in  std_logic;
		write_req  : in  std_logic;
		write_rdy  : buffer std_logic;
		read_req   : in  std_logic;
		read_rdy   : buffer std_logic;
		burst      : in  std_logic;

		phy_frm    : buffer std_logic;
		phy_trdy   : in  std_logic;
		phy_rw     : out std_logic;
		phy_cmd    : in  std_logic_vector(0 to 3-1));

end;

architecture def of phy_memcycle is
	signal sdram_act  : std_logic;
	signal sdram_idle : std_logic;
begin

	process (phy_trdy, clk)
		variable s_pre : std_logic;
	begin
		if rising_edge(clk) then
			if phy_trdy='1' then
				sdram_idle <= s_pre;
				case phy_cmd is
				when mpu_pre =>
					sdram_act <= '0';
					s_pre := '1';
				when mpu_act =>
					sdram_act <= '1';
					s_pre := '0';
				when others =>
					sdram_act <= '0';
					s_pre := '0';
				end case;
			end if;
		end if;
	end process;

	process (clk)
		type states is (s_idle, s_start, s_run);
		variable state : states;
	begin
		if rising_edge(clk) then
			case state is
			when s_start =>
				phy_frm  <= '1';
				if sdram_act='1' then
					if burst='0' then
						phy_frm <= '0';
					end if;
					state   := s_run;
				end if;
			when s_run =>
				if sdram_idle='1' then
					read_rdy  <= read_req;
					write_rdy <= write_req;
					state    := s_idle;
				end if;
				if burst='0' then
					phy_frm <= '0';
				end if;
			when s_idle =>
				phy_frm  <= '0';
				if (read_req xor read_rdy)='1' then
					phy_frm  <= '1';
					phy_rw   <= '1';
					state    := s_start;
				elsif (write_req xor write_rdy)='1' then
					phy_frm  <= '1';
					phy_rw   <= '0';
					state    := s_start;
				end if;
			end case;
		end if;
	end process;

end;

