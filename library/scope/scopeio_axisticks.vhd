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

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_axisticks is
	port (
		clk         : in  std_logic;

		axis_req    : in  std_logic;
		axis_rdy    : out std_logic;
		axis_unit   : in  std_logic_vector;
		axis_point  : in  std_logic_vector;
		axis_base   : in  std_logic_vector;
		axis_length : in  std_logic_vector;
		axis_sel    : in  std_logic;

		tick        : out std_logic_vector;
		dv          : out std_logic;
		value       : out std_logic_vector);
end;

architecture def of scopeio_axisticks is

	signal wrt_rdy : std_logic;
	signal wrt_length : std_logic_vector(0 to 3-1);

	signal bin_dv  : std_logic;
	signal bin_val : std_logic_vector(4*4-1 downto 0);
	signal bcd_dv  : std_logic;


	signal dev_req : std_logic_vector(1 to 2);
	signal dev_rdy : std_logic_vector(1 to 2);
	signal dev_gnt : std_logic_vector(1 to 2);

	signal base    : std_logic_vector(axis_base'length+axis_unit'length+3-1 downto 0);

	signal bcd_left : std_logic;
	signal bcd_sign : std_logic;
begin

	mult_b : block
		signal ini : std_logic; 
	begin
		ini <= '1';
		mult_e : entity hdl4fpga.mult
		port map (
			clk     => clk,
			ini     => ini,
			multand => axis_base,
			multier => axis_unit,
			product => base(base'left downto 3));
		base(3-1 downto 0) <= b"000";
	end block;


	bcd_left <= not axis_sel;
	bcd_sign <= axis_sel;
	scopeio_write_e : entity hdl4fpga.scopeio_writeticks
	port map (
		clk        => clk,
		write_req  => axis_req,
		write_rdy  => wrt_rdy,
		point      => axis_point,
		length     => axis_length,
		element    => tick,
		bin_dv     => bin_dv,
		bin_val    => bin_val,
		bcd_sign   => bcd_sign,
		bcd_left   => bcd_left,
		bcd_dv     => dv,
		bcd_val    => value);
	axis_rdy <= wrt_rdy;


end;
