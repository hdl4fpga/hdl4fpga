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

entity iddr is
	generic (
		data_size : natural := 1;
		word_size : natural := 4);
	port (
		sclks : in std_logic_vector(0 to word_size/2-1);
		dclks : in std_logic_vector(0 to word_size/2) := (others => '-');
		d : in  std_logic_vector(data_size-1 downto 0);
		q : out std_logic_vector(data_size*word_size-1 downto 0));
end;

library ecp3;
use ecp3.components.all;

library hdl4fpga;

architecture ecp3 of iddr is
begin
	assert word_size = 1 or word_size = 2 or word_size = 4
	report "DATA_PHASES should be 1, 2, 4"
	severity FAILURE;

	g : for i in data_size-1 to 0 generate
		ff_g : if word_size = 1 generate
		begin
			ff_i : entity hdl4fpga.ff
			port map (
				clk => sclks(0),
				d => d(i),
				q => q(i));
		end generate;

		ddrx1_g : if word_size = 2 generate
			attribute iddrapps : string;
			attribute iddrapps of iddr_i : label is "DQS_ALIGNED";
		begin
			iddr_i : iddrxd1
			port map (
				sclk => sclks(0),
				d  => d(i),
				qa => q(data_size*0+i),
				qb => q(data_size*1+i));
		end generate;

		ddrx2_g : if word_size = 4 generate
			attribute iddrapps : string;
			attribute iddrapps of iddr_i : label is "DQS_ALIGNED";
		begin
			iddr_i : iddrx2d
			port map (
				sclk => sclks(0),
				eclk => sclks(1),
				eclkdqsr => dclks(0),
				ddrclkpol => dclks(1),
				ddrlat => dclks(2),
				d   => d(i),
				qa0 => q(data_size*0+i),
				qa1 => q(data_size*2+i),
				qb0 => q(data_size*1+i),
				qb1 => q(data_size*3+i));
		end generate;
	end generate;
end;

library ieee;
use ieee.std_logic_1164.all;

entity oddr is
	generic (
		data_size : natural := 1;
		word_size : natural := 4);
	port (
		sclk  : in std_logic;
		dclks : in std_logic_vector(0 to word_size/2-1) := (others => '-');
		d : in  std_logic_vector(data_size*word_size-1 downto 0);
		q : out std_logic_vector(data_size-1 downto 0));
end;

library ecp3;
use ecp3.components.all;

library hdl4fpga;

architecture ecp3 of oddr is
begin
	assert word_size = 1 or word_size = 2 or word_size = 4
	report "DATA_PHASES should be 1, 2, 4"
	severity FAILURE;

	g : for i in data_size-1 to 0 generate
		ff_g : if word_size = 1 generate
		begin
			ff_i : entity hdl4fpga.ff
			port map (
				clk => sclk,
				d => d(data_size*0+i),
				q => q(i));
		end generate;

		ddrx1_g : if word_size = 2 generate
			attribute oddrapps : string;
			attribute oddrapps of oddr_i : label is "DQS_ALIGNED";
		begin
			oddr_i : oddrxd1
			port map (
				sclk => sclk,
				da => d(data_size*0+i),
				db => d(data_size*1+i),
				q  => q(i));
		end generate;

		ddrx2_g : if word_size = 4 generate
			attribute oddrapps : string;
			attribute oddrapps of oddr_i : label is "DQS_ALIGNED";
		begin
			oddr_i : oddrx2d
			port map (
				sclk => sclk,
				dqclk0 => dclks(0),
				dqclk1 => dclks(1),
				da0 => d(data_size*0+i),
				da1 => d(data_size*2+i),
				db0 => d(data_size*1+i),
				db1 => d(data_size*3+i),
				q   => q(i));
		end generate;
	end generate;
end;

library ieee;
use ieee.std_logic_1164.all;

entity oddrt is
	generic (
		data_size : natural := 1;
		word_size : natural := 4);
	port (
		sclk  : in std_logic;
		dclks : in std_logic_vector(0 to word_size/2-1) := (others => '-');
		d : in  std_logic_vector(data_size-1 downto 0);
		q : out std_logic_vector(data_size-1 downto 0));
end;

library ecp3;
use ecp3.components.all;

library hdl4fpga;

architecture ecp3 of oddrt is
begin
	assert word_size = 1
	report "DATA_PHASES should be 1"
	severity FAILURE;

	g : for i in data_size-1 to 0 generate
		ff_g : if word_size = 2 generate
			oddrtdqa_i : oddrtdqa
			port map (
				sclk => sclk,
				dqclk0 => dclks(0),
				dqclk1 => dclks(1),
				ta => d(i),
				q  => q(i));
		end generate;
	end generate;
end;

library ieee;
use ieee.std_logic_1164.all;

entity oddrdqs is
	generic (
		word_size : natural := 2);
	port (
		sclk  : in std_logic;
		dclks : in std_logic_vector(0 to word_size) := (others => '-');
		tclk  : out std_logic;
		d  : in  std_logic_vector(word_size-1 downto 0);
		q  : out std_logic);
end;

library ecp3;
use ecp3.components.all;

library hdl4fpga;

architecture ecp3 of oddrdqs is
	attribute oddrapps : string;
	attribute oddrapps of oddrdqs_i : label is "DQS_CENTERED";
begin
	assert word_size = 2
	report "DATA_PHASES should be 2"
	severity FAILURE;

	oddrdqs_i : oddrx2dqsa
	port map (
		sclk => sclk,
		db0 => d(0),
		db1 => d(1),
		dqsw => dclks(word_size/2),
		dqclk0 => dclks(0),
		dqclk1 => dclks(1),
		dqstclk => tclk,
		q => q);
end;

library ieee;
use ieee.std_logic_1164.all;

entity oddrdqst is
	generic (
		word_size : natural := 2);
	port (
		sclk : in std_logic;
		dclk : in std_logic;
		tclk : in std_logic;
		d : in  std_logic_vector(word_size-1 downto 0);
		q : out std_logic);
end;

library ecp3;
use ecp3.components.all;

library hdl4fpga;

architecture ecp3 of oddrdqst is
begin
	assert word_size = 1
	report "DATA_PHASES should be 1"
	severity FAILURE;

	ff_g : if word_size = 2 generate
		oddrtdqa_i : oddrtdqsa
		port map (
			sclk => sclk,
			dqsw => dclk,
			dqstclk => tclk,
			ta => d(0),
			db => d(1),
			q  => q);
	end generate;
end;
