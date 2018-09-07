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

architecture scopeio_fill of testbench is
	signal rst     : std_logic := '1';
	signal clk     : std_logic := '0';

	signal fill_req : std_logic;
	signal fill_rdy : std_logic;
	signal point    : std_logic_vector(0 to 3-1) := "111";

	signal bin_dv   : std_logic;
	signal bin_val  : std_logic_vector(4*4-1 downto 0);
	signal bcd_dv   : std_logic;
	signal bcd_val  : std_logic_vector(0 to 4*8-1);

	signal wr_addr : std_logic_vector(0 to 6-1);
	signal rd_addr : std_logic_vector(wr_addr'range);
	signal rd_data : std_logic_vector(bcd_val'range);

	signal vt_we : std_logic;
	signal vt_req : std_logic := '0';
	signal vt_rdy : std_logic;
	signal vt_gnt : std_logic;

	signal hz_we : std_logic;
	signal hz_req : std_logic := '0';
	signal hz_rdy : std_logic;
	signal hz_gnt : std_logic;
begin

	clk <= not clk  after  5 ns;
	rst <= '0', '1' after 20 ns, '0' after 30 ns ;

	process (clk, hz_rdy)
		variable req : std_logic := '0';
	begin
		if rising_edge(clk) then
			if rst='1' then
				req := '1';
			elsif hz_rdy='1' then
				req := '0';
			end if;
		end if;
		hz_req <= req and not hz_rdy;
	end process;

	process (clk, vt_rdy)
		variable req : std_logic := '0';
	begin
		if rising_edge(clk) then
			if rst='1' then
				req := '1';
			elsif vt_rdy='1' then
				req := '0';
			end if;
		end if;
		vt_req <= req and not vt_rdy;
	end process;

	process(clk)
		variable cntr : unsigned(bin_val'range);
	begin
		if rising_edge(clk) then
			if fill_req='0' then
				cntr := (others => '0');
			elsif fill_rdy='0' then
				if bin_dv='1' then
					if hz_req='1' then
						cntr := cntr + 40;
					else
						cntr := cntr + 50;
					end if;
				end if;
			end if;
			bin_val <= std_logic_vector(cntr);
		end if;
	end process;

	grnt_p : block
		port (
			clk      : in  std_logic;
			fill_rdy : in std_logic;
			fill_req : out std_logic;
			dev_req  : in  std_logic_vector(1 to 2);
			dev_gnt  : out std_logic_vector(1 to 2);
			dev_rdy  : out std_logic_vector(1 to 2));

		port map (
			clk        => clk,
			fill_rdy   => fill_rdy,
			fill_req   => fill_req,
			dev_req(1) => hz_req,
			dev_req(2) => vt_req,
			dev_gnt(1) => hz_gnt,
			dev_gnt(2) => vt_gnt,
			dev_rdy(1) => hz_rdy,
			dev_rdy(2) => vt_rdy);

		signal gnt : std_logic_vector(0 to unsigned_num_bits(dev_req'length)-1);

	begin

		process(clk)
		begin
			if rising_edge(clk) then
				for i in dev_req'range loop
					if fill_rdy='1' then
						gnt <= (others => '0');
					elsif not gnt/=(gnt'range => '0') then
						if dev_req(i)='1' then
							gnt <= std_logic_vector(to_unsigned(i, gnt'length));
							exit;
						end if;
					end if;
				end loop;
			end if;
		end process;

		fill_req <= word2byte("0" & dev_req, gnt, 1)(0) and not fill_rdy;
		dev_gnt  <= demux(gnt)(1 to dev_rdy'length);
		dev_rdy  <= demux(gnt, fill_rdy)(1 to dev_rdy'length);
	end block;

	du: entity hdl4fpga.scopeio_fill
	port map (
		clk        => clk,
		fill_req   => fill_req,
		fill_rdy   => fill_rdy,
		point      => point,
		length     => b"0010",
		element    => wr_addr,
		bin_dv     => bin_dv,
		bin_val    => bin_val,
		bcd_dv     => bcd_dv,
		bcd_val    => bcd_val);

	hz_we <= bcd_dv and hz_gnt;
	hz_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => clk,
		wr_ena  => hz_we,
		wr_addr => wr_addr,
		wr_data => bcd_val,
		rd_addr => rd_addr,
		rd_data => rd_data);

	vt_we <= bcd_dv and vt_gnt;
	vt_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => clk,
		wr_ena  => vt_we,
		wr_addr => wr_addr,
		wr_data => bcd_val,
		rd_addr => rd_addr,
		rd_data => rd_data);
end;
