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
use ieee.numeric_std.all;

entity bram is
	generic (
		data  : std_logic_vector := (0 to 0 => '-'));
	port (
		clka  : in  std_logic;
		addra : in  std_logic_vector;
		enaa  : in  std_logic := '1';
		wea   : in  std_logic := '0';
		dia   : in  std_logic_vector;
		doa   : out std_logic_vector;

		clkb  : in  std_logic;
		addrb : in  std_logic_vector;
		enab  : in  std_logic := '1';
		web   : in  std_logic := '0';
		dib   : in  std_logic_vector;
		dob   : out std_logic_vector);
		
end;

--library hdl4fpga;
--
--architecture bram_true2p_2clk of bram is
--	signal rd_addr   : std_logic_vector(addra'range);
--	signal rd_data   : std_logic_vector(dia'range);
--begin
--
--	process (clkb)
--	begin 
--		if rising_edge(clkb) then
--			rd_addr <= addrb;
--		end if;
--	end process;
--
--	process (clkb)
--	begin 
--		if rising_edge(clkb) then
--			dob <= rd_data;
--		end if;
--	end process;
--
--	mem_e: entity hdl4fpga.bram_true2p_2clk
--	generic map
--	(
--	    pass_thru_a => true,			-- True or False doesn't change LUTs consumption on
--	    pass_thru_b => true,			-- Diamond 3.10.2.115, neither does this
--		data_width => dia'length,
--		addr_width => addra'length
--	)
--	port map
--	(
--		clk_a      => clka,
--		we_a       => wea,
--		addr_a     => addra,
--		data_in_a  => dia,
--
--		clk_b      => clkb,
--		we_b       => '0',
--		addr_b     => rd_addr,
--		data_out_b => rd_data
--	);
--
--
--end;

-- Less LUTs consuption on Lattisemi Diamond 3.10.2.115
-- Less tested than bram_true2p_2clk for portability

library hdl4fpga;
use hdl4fpga.std.all;

architecture inference of bram is
	subtype word is std_logic_vector(max(dia'length,dib'length)-1 downto 0);
	type word_vector is array (natural range <>) of word;
	constant addr_size : natural := hdl4fpga.std.min(addra'length,addrb'length);
	constant data_size : natural := (data'length+word'length-1)/word'length;

	function mem_init (
		constant arg : std_logic_vector)
		return word_vector is

		variable aux : std_logic_vector(0 to max(arg'length,word'length)-1) := (others => '-');
		variable val : word_vector(0 to 2**addr_size-1) := (others => (others => '-'));

	begin
		aux(0 to arg'length-1) := arg;
		for i in 0 to data_size-1 loop
			val(i) := aux(word'length*i to word'length*(i+1)-1);
		end loop;

		return val;
	end;
	shared variable ram : word_vector(0 to 2**addr_size-1); -- := mem_init(data);
begin
	process (clka)
		variable addr : std_logic_vector(addra'range);
	begin
		if rising_edge(clka) then
			if enaa='1' then
				doa <= ram(to_integer(unsigned(addr)));
				if wea='1' then
					ram(to_integer(unsigned(addra))) := dia;
				end if;
				addr := addra;
			end if;
		end if;
	end process;

	process (clkb)
		variable addr : std_logic_vector(addrb'range);
	begin
		if rising_edge(clkb) then
			if enab='1' then
				dob <= ram(to_integer(unsigned(addr)));
				if web='1' then
					ram(to_integer(unsigned(addrb))) := dib;
				end if;
				addr := addrb;
			end if;
		end if;
	end process;
end;
