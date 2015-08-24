--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                    --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

use hdl4fpga.std.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sa_timing is
	port (
		sys_rst : in  std_logic;
		sys_clk : in  std_logic;
		sys_req : in  std_logic;
		sys_rdy : buffer std_logic;
		sys_rw  : in  std_logic;
		sys_oe  : out std_logic;
		sa_e    : out std_logic);
end;

architecture def of sa_timing is
	signal oe : std_logic;
	signal e  : std_logic;
begin
	process (sys_rst, sys_clk)
		variable start : std_logic;
		variable step : unsigned(0 to 1) := (others => '0');
	begin
		if sys_rst='1' then
			e  <= '0';
			oe <= '0';
			sys_rdy <= '0';
			step := (others => '0');
		elsif rising_edge(sys_clk) then
			e  <= setif(step="00" or step="01");
			oe <= setif(step="01" or step="11");

			if step="11" then
				if sys_rdy='1' then
					if sys_req='0' then
						sys_rdy <= '0';
					end if;
				elsif sys_req='1' then
					step := (others => '0');
				end if;
			else
				if step="11" then
					sys_rdy <= sys_req;
				end if;
				step := inc(gray(step));
			end if;
		end if;
	end process;

	sys_oe <= oe and not sys_rw;
	sa_e   <= e;
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sa_init is
	port (
		sys_clk : in  std_logic;
		sys_req : in  std_logic;
		sys_rdy : out std_logic;
		
		sa_rs : out std_logic;
		sa_rw : out std_logic;
		sa_do : out std_logic_vector(8-1 downto 0));
end;

architecture mix of sa_init is
	subtype byte is std_logic_vector(8-1 downto 0);
	type byte_vector is array (natural range <>) of byte;
	constant sa0069_cmmd : byte_vector(0 to 8-1) := (
		3 => "001111--",
		4 => "00001111",
		5 => "00000001",
		6 => "00000111",
		7 => "10010100",
		others => (others => '-'));

	signal step : unsigned(0 to 3) := (others => '0');
begin
	sys_rdy <= step(0);

	process (
		sys_clk,
		sys_req)
		variable rdy : std_logic;
	begin
		if sys_req='0' then
			step <= to_unsigned(3, step'length);
		elsif falling_edge(sys_clk) then
			if step(0)='0' then
				if sys_req='1' or rdy='1' then
					step <= step + 1;
				end if;
			end if;
		end if;
	end process;

	sa_do <= sa0069_cmmd(to_integer(step(1 to step'right)));
	sa_rs <= '0';
	sa_rw <= '0';
end;

use hdl4fpga.std.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sa_ctlr is
	port (
		sys_clk : in  std_logic;
		sys_rst : in  std_logic;
		sys_ini : buffer std_logic;
		sys_req : in  std_logic;
		sys_rs  : in  std_logic;
		sys_rdy : out std_logic;
		sys_rw  : in  std_logic;
		sys_di  : in std_logic_vector(8-1 downto 0);

		sa_e  : out std_logic;
		sa_rs : out std_logic;
		sa_rw : out std_logic;
		sa_db : out std_logic_vector(0 to 7));
end;

architecture mix of sa_ctlr is
	signal sys_tmng_rdy : std_logic;
	signal sys_tmng_req : std_logic;
	signal sys_tmng_oe : std_logic;
	signal sa_tmng_e : std_logic;
	signal sys_init_rdy : std_logic;
	signal sys_init_req : std_logic := '1';
	signal sa_init_rs : std_logic;
	signal sa_init_rw : std_logic;
	signal sa_init_do : std_logic_vector(sa_db'range);
	signal	sa_do :  std_logic_vector(8-1 downto 0);
begin
	process (sys_clk)
		variable ini : std_logic;
	begin
		if sys_rst='1' then
			ini     := '0';
			sys_ini <= '0';
		elsif rising_edge(sys_clk) then
			sys_ini <= ini;
			if sys_ini='0' then
				if sys_init_rdy='1' then
					if sys_tmng_rdy='1' then
						ini := '1';
					end if;
				end if;
			end if;
		end if;
	end process;

	sa_timing_e : entity hdl4fpga.sa_timing
	port map (
		sys_clk => sys_clk,
		sys_rst => sys_rst,
		sys_req => sys_tmng_req,
		sys_rdy => sys_tmng_rdy,
		sys_rw  => sys_rw,
		sys_oe  => sys_tmng_oe,
		sa_e    => sa_tmng_e);
	
	sys_init_req <= not sys_rst;
	sa_init_e : entity hdl4fpga.sa_init
	port map (
		sys_clk => sa_tmng_e,
		sys_req => sys_init_req,
		sys_rdy => sys_init_rdy,
		
		sa_rs => sa_init_rs,
		sa_rw => sa_init_rw,
		sa_do => sa_init_do);
		
	sys_rdy <= setif(sys_ini='1' and sys_tmng_rdy='1');
	sys_tmng_req <=
		not sys_tmng_rdy when sys_init_rdy='0' else
		sys_req;

	process (sa_tmng_e)
	begin
		if rising_edge(sa_tmng_e) then
			if sys_init_rdy='0' then 
				sa_do <= sa_init_do;
			else
				sa_do <= sys_di;
			end if;
		end if;
	end process;

	sa_e  <= sa_tmng_e;
	sa_rw <= sa_init_rw when sys_init_rdy='0' else sys_rw;
	sa_rs <= sa_init_rs when sys_init_rdy='0' else sys_rs;
	sa_db <= sa_do when sys_tmng_oe='1' else (others => 'Z');
end;

use hdl4fpga.std.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sa_drv is
	port (
		sys_clk : in std_logic;
		sys_rst : in std_logic;
		sys_ini : buffer std_logic;
		sys_sft : in std_logic;
		sys_dir : in std_logic;
		sys_req : in std_logic;
		sys_rs  : in std_logic;
		sys_rdy : buffer std_logic;
		sys_rw  : in  std_logic;
		sys_di  : in std_logic_vector(8-1 downto 0);

		sa_e  : out std_logic;
		sa_rs : out std_logic;
		sa_rw : out std_logic;
		sa_db : out std_logic_vector(0 to 7));
end;

architecture arch of sa_drv is 
	signal cntr1 : unsigned(0 to 5);
begin
	process (sys_clk)
	begin
		if rising_edge(sys_clk) then
			if sys_req='0' then
				if sys_rdy='1' then
					if cntr1 < 20-1 then
						cntr1 <= (others => '0');
					else
						cntr1 <= cntr1 + 1;
					end if;
				end if;
			end if;
		end if;
	end process;

	process (sys_clk)
	begin
		if rising_edge(sys_clk) then
			if sys_req='1' then
			elsif sys_rdy='1' then
				sys_rdy <= '0';
			end if;
		end if;
	end process;
end;
