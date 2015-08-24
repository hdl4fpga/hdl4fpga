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

entity datai is
	generic (
		fifo_size : natural := 5);
	port (
		input_clk : in std_logic;
		input_dat : in std_logic_vector;
		input_req : in std_logic;
		input_rdy : out std_logic;

		output_clk  : in std_logic;
		output_rdy  : out std_logic;
		output_req  : in std_logic;
		output_dat  : out std_logic_vector);
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture def of datai is
	constant n : natural := 1;
	constant data_size : natural := input_dat'length;

	subtype input_word  is std_logic_vector(data_size-1 downto 0);
	subtype output_word is std_logic_vector(2**n*data_size-1 downto 0);
	type input_vector is array (natural range <>) of input_word;


	signal addri : std_logic_vector(0 to fifo_size-1) := (others => '0');
	signal datao : input_vector(0 to 2**n-1);
	signal addro : std_logic_vector(0 to fifo_size-1) := (others => '0');

	signal wr_sel : std_logic_vector(0 to 0) := (others => '0');
	signal wr_ena : std_logic_vector(0 to 2**n-1);
	signal wr_address : std_logic_vector(0 to fifo_size-1);
	signal wr_data : input_word;

	signal rd_address  : std_logic_vector(0 to fifo_size-1);
	signal output_syrq : std_logic_vector(0 to 1);
	signal input_syrq  : std_logic_vector(0 to 1);

begin

	input_rdy <= input_syrq(0);

	process (input_clk,input_syrq(0))
	begin
		if input_syrq(0)='0' then
			wr_sel(0) <= '1';
			addri <= "11" & (3 to fifo_size => '0');
		elsif rising_edge(input_clk) then
			if wr_sel(0)='0' then
				addri <= inc(gray(addri));
			end if;
			wr_sel(0) <= not wr_sel(0);
		end if;
	end process;

	process (output_clk,output_syrq(0))
	begin
		if output_syrq(0)='0' then
			addro <= "01" & (3 to fifo_size => '0');
		elsif rising_edge(output_clk) then
			if output_req='1' then
				addro <= inc(gray(addro));
			end if;
		end if;
	end process;

	process (input_clk)
	begin
		if rising_edge(input_clk) then
			input_syrq <= not input_syrq(1) & not output_syrq(0);
			wr_address <= addri;
			wr_data <= input_dat;
		end if;
	end process;

	process(output_clk)
	begin
		if rising_edge(output_clk) then
			output_syrq <= not output_syrq(1) & not input_req;
			if output_req='1' then
				rd_address <= addro;
			end if;
		end if;
	end process;

	wr_dec_e: entity hdl4fpga.demux 
	generic map (
		n => n)
	port map (
		s => wr_sel,
		o => wr_ena);

	ram_g : for i in 0 to 2**n-1 generate
		fifo_e : entity hdl4fpga.dpram
		port map (
			wr_clk => input_clk,
			wr_addr => wr_address, 
			wr_data => wr_data,
			wr_ena => wr_ena(i),
			rd_clk => output_clk,
			rd_ena => output_req,
			rd_addr => rd_address,
			rd_data => datao(i));
	end generate;

	process (datao)
		variable data : output_word;
	begin
		data := (others => '-');
		for i in datao'range loop
			data := (data sll input_word'length);
			data(input_word'range) := datao(i);
		end loop;
		output_dat <= data;
	end process;

	output_rdy <= not (
		(addri(0) xnor addro(1)) and
		(addro(0) xor  addri(1)));

end;
