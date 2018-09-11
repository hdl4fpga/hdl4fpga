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
		clk     : in  std_logic;

		hz_len  : in  std_logic_vector := b"110";
		hz_step : in  std_logic_vector;
		hz_from : in  std_logic_vector;
		hz_req  : in  std_logic;
		hz_rdy  : out std_logic;
		hz_pnt  : in  std_logic_vector;
		hz_dv   : out std_logic;

		vt_len  : in  std_logic_vector := b"100";
		vt_step : in  std_logic_vector;
		vt_from : in  std_logic_vector;
		vt_req  : in  std_logic;
		vt_rdy  : out std_logic;
		vt_pnt  : in  std_logic_vector;
		vt_dv   : out std_logic;

		tick    : out std_logic_vector;
		value   : out std_logic_vector);
end;

architecture def of scopeio_axisticks is

	signal wrt_req : std_logic;
	signal wrt_rdy : std_logic;
	signal wrt_len : std_logic_vector(0 to 3-1);
	signal wrt_pnt : std_logic_vector(0 to 3-1);

	signal bin_dv  : std_logic;
	signal bin_val : std_logic_vector(4*4-1 downto 0);
	signal bcd_dv  : std_logic;

	signal vt_gnt  : std_logic;
	signal hz_gnt  : std_logic;

	signal dev_req : std_logic_vector(0 to 1);
	signal dev_rdy : std_logic_vector(0 to 1);
	signal dev_gnt : std_logic_vector(0 to 1);
begin

	process(clk)
		variable cntr : unsigned(bin_val'range);
	begin
		if rising_edge(clk) then
			if wrt_req='0' then
				if hz_gnt='1' then
					cntr := unsigned(hz_from);
				else
					cntr := unsigned(vt_from);
				end if;
			elsif wrt_rdy='0' then
				if bin_dv='1' then
					if hz_gnt='1' then
						cntr := cntr + unsigned(hz_step);
					else
						cntr := cntr + unsigned(vt_step);
					end if;
				end if;
			end if;
			bin_val <= std_logic_vector(cntr);
		end if;
	end process;

	dev_req <= (1 => hz_req, 2 => vt_req);
	(1 => hz_rdy, 2 => vt_rdy) <= dev_rdy;
	(1 => hz_gnt, 2 => vt_gnt) <= dev_gnt;

	scopeio_grant_e : entity hdl4fpga.scopeio_grant
	port map (
		clk      => clk,
		dev_req  => dev_req,
		dev_gnt  => dev_gnt,
		dev_rdy  => dev_rdy,
		unit_req => wrt_req,
		unit_rdy => wrt_rdy);

	wrt_len <= word2byte((wrt_len'range => '-') & hz_len & vt_len, dev_gnt, wrt_len'length); 
	wrt_pnt <= word2byte((wrt_pnt'range => '-') & hz_pnt & vt_pnt, dev_gnt, wrt_pnt'length); 
	scopeio_write_e : entity hdl4fpga.scopeio_writeticks
	port map (
		clk        => clk,
		write_req  => wrt_req,
		write_rdy  => wrt_rdy,
		point      => wrt_pnt,
		length     => wrt_len,
		element    => tick,
		bin_dv     => bin_dv,
		bin_val    => bin_val,
		bcd_dv     => bcd_dv,
		bcd_val    => value);

	hz_dv <= bcd_dv and hz_gnt;
	vt_dv <= bcd_dv and vt_gnt;

end;
