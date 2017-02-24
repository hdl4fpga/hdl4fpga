--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
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

library ieee;
use ieee.std_logic_1164.all;

entity dmamii is
	generic (
		BRAM_SIZE  : natural := 9;
		DATA_SIZE  : natural := 32);
	port (
		dmamii_clk    : in  std_logic;
		dmamii_gnt    : in  std_logic;
		dmamii_rdy    : out std_logic;
		dmamii_di_req : in  std_logic;
		dmamii_di     : out std_logic;

		mii_clk       : in  std_logic;
		mii_req       : in  std_logic;
		mii_rdy       : out std_logic;
		mii_ena       : in  std_logic;
		miirx_ena     : in  std_logic;
		miirx_dat     : in  std_logic);
		miitx_dat     : out std_logic);
end;

library hdl4fpga;
use hdl4fpga.std.all;

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

architecture def of dmaii is
	constant bram_num : natural := (unsigned_num_bits(ddrs_di'length-1)+bram_size)-(unsigned_num_bits(1024/2**0*8-1));

	signal dma_addr : unsigned(0 to bram_size-1);
	signal mii_addr : unsigned(0 to bram_size-1);

begin

	process (dmamii_clk)
		variable addr : unsigned(addri'range);
		variable msb  : std_logic;
	begin
		if rising_edge(ddrs_clk) then
			if dmamii_gnt='0' then
				addr := (others => '0');
				dmamii_rdy <= '0';
			elsif dmamii_di_rdy='1' then
				if addr(0)='0' then
					addr := addr + 1;
				end if;
				dmamii_rdy <= addr(0);
			end if;
			dma_addr <= addr;
		end if;
	end process; 

	process (mii_clk)
		variable addr : unsigned(addri'range);
		variable msb  : std_logic;
	begin
		if rising_edge(mii_clk) then
			if mii_req='0' then
				addr := (others => '0');
				bsel <= (others => '0');
			elsif bsel(0)='1' then
				bsel <= (others => '0');
				if addr(0)='0' then
					addr := addr + 1;
				end if;
			else
				bsel <= bsel + 1;
			end if;
			mii_rdy  <= addr(0);
			mii_addr <= addr;
		end if;
	end process;

	bram_e : entity hdl4fpga.bram
	port map (
		clka  => dmamii_clk,
		wea   => wr_ena,
		addra => dmamii_addr, 
		dia   => wr_data,
		doa   => dummy,

		clkb  => mii_clk,
		web   => '0',
		addrb => mii_addr
		dib   => miirx_dat, 
		dob   => miitx_dat);

	txd <= word2byte (
		word => reverse(std_logic_vector(unsigned(tx_data) rol (miitx_dat'length))),
		addr => bsel);
	miitx_dat <= txd;
end;
