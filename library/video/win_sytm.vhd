--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2010-2013                                                    --
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

entity win_sytm is
--	generic (
--		rowid_size  : natural := 2;
--		rowpag_size : natural := 5;
--		rowoff_size : natural := 7;
--		colid_size  : natural := 2;
--		colpag_size : natural := 4;
--		coloff_size : natural := 15);
	port(
		win_clk : in std_logic;
		win_frm : in std_logic;
		win_don : in std_logic;
--		win_rowid  : out std_logic_vector(rowid_size-1  downto 0);
--		win_rowpag : out std_logic_vector(rowpag_size-1 downto 0);
--		win_rowoff : out std_logic_vector(rowoff_size-2 downto 0);
--		win_colid  : out std_logic_vector(colid_size-1  downto 0);
--		win_colpag : out std_logic_vector(colpag_size-1 downto 0);
--		win_coloff : out std_logic_vector(coloff_size-2 downto 0));
		win_rowid  : out std_logic_vector;
		win_rowpag : out std_logic_vector;
		win_rowoff : out std_logic_vector;
		win_colid  : out std_logic_vector;
		win_colpag : out std_logic_vector;
		win_coloff : out std_logic_vector);

	constant rowid_size  : natural := win_rowid'length;
	constant rowpag_size : natural := win_rowpag'length;
	constant rowoff_size : natural := win_rowoff'length;
	constant colid_size  : natural := win_colid'length;
	constant colpag_size : natural := win_colpag'length;
	constant coloff_size : natural := win_coloff'length;
end;

library hdl4fpga;
use hdl4fpga.std.all;

library ieee;
use ieee.numeric_std.all;

architecture def of win_sytm is

	subtype rowside_sz is unsigned(0 to rowoff_size-1);
	subtype rowside_id is unsigned(rowoff_size to rowoff_size+rowid_size-1);
	subtype rowside is unsigned(0 to rowoff_size+rowid_size-1);

	type rowside_vector is array (natural range <>) of rowside;

	constant rowcnt_data : rowside_vector(0 to 2**rowpag_size-1) := (
		18 => (to_unsigned( 4-2, rowoff_size) & "00"),
		17 => (to_unsigned(48-2, rowoff_size) & "10"),
		16 => (to_unsigned(65-2, rowoff_size) & "11"),
		15 => (to_unsigned(64-2, rowoff_size) & "11"),
		14 => (to_unsigned(64-2, rowoff_size) & "11"),
		13 => (to_unsigned(64-2, rowoff_size) & "11"),
		12 => (to_unsigned(64-2, rowoff_size) & "11"),
		11 => (to_unsigned(64-2, rowoff_size) & "11"),
		10 => (to_unsigned(64-2, rowoff_size) & "11"),
		 9 => (to_unsigned(64-2, rowoff_size) & "11"),
		 8 => (to_unsigned(64-2, rowoff_size) & "11"),
		 7 => (to_unsigned(64-2, rowoff_size) & "11"),
		 6 => (to_unsigned(64-2, rowoff_size) & "11"),
		 5 => (to_unsigned(64-2, rowoff_size) & "11"),
		 4 => (to_unsigned(64-2, rowoff_size) & "11"),
		 3 => (to_unsigned(64-2, rowoff_size) & "11"),
		 2 => (to_unsigned(64-2, rowoff_size) & "11"),
		 1 => (to_unsigned(64-2, rowoff_size) & "11"),
		 0 => (to_unsigned( 3-2, rowoff_size) & "00"),
		 others => (others => '0'));

	signal row_pag : std_logic_vector(0 to rowpag_size) := (others => '0');
	signal row_cnt : std_logic_vector(0 to rowoff_size-1) := (others => '0');
	signal rowpag_ena : std_logic;
	signal rowpag_load : std_logic;
	signal rdata : rowside := (others => '0');
	signal wrowpag_ena : std_logic;

	subtype	colside_sz is unsigned(0 to coloff_size-1);
	subtype colside_id is unsigned(coloff_size to coloff_size+colid_size-1);
	subtype colside is unsigned(0 to coloff_size+colid_size-1);
	type colside_vector is array (natural range <>) of colside;

	signal col_pag : std_logic_vector(0 to colpag_size) := (others => '0');
	signal col_cnt : std_logic_vector(0 to coloff_size-1) := (others => '0');
	signal colpag_ena : std_logic;
	signal colpag_load : std_logic;
	signal cdata : colside := (others => '0');
	signal wcolpag_ena : std_logic;

	constant colcnt_data : colside_vector(0 to 2**colpag_size-1) := (
		2 => (to_unsigned( 256-2, coloff_size) & "01"),
		1 => (to_unsigned( 128-2, coloff_size) & "10"),
		0 => (to_unsigned(1537-2, coloff_size) & "11"),
		others => (others => '0'));


begin

	rowid_e : entity hdl4fpga.align
	generic map (
		n => rowid_size,
		d => (0 to rowid_size-1 => 1))
	port map (
		clk => win_clk,
		ena => wrowpag_ena,
		di  => std_logic_vector(rdata(rowside_id'range)),
		do  => win_rowid);

	wrowpag_ena <= rowpag_ena or (row_cnt(0) and colpag_load);
	rowpag_e : entity hdl4fpga.align
	generic map (
		n => rowpag_size,
		d => (0 to rowpag_size-1 => 2))
	port map (
		clk => win_clk,
		ena => wrowpag_ena,
		di  => row_pag(1 to rowpag_size),
		do  => win_rowpag);

	process (win_clk)
		variable ena : std_logic_vector(3 downto 0);
		variable wfrm_edge : std_logic;
	begin
		if rising_edge(win_clk) then
			rowpag_load <= '0';
			if win_frm='0' then
				if wfrm_edge='1' then
					rowpag_load <= '1';
					ena := (others => '1');
				end if;
			end if;
			rowpag_ena <= ena(3);

			ena := ena sll 1;
			wfrm_edge := win_frm;
		end if;
	end process;

	process (win_clk)
	begin
		if rising_edge(win_clk) then
			row_pag <= dec (
				cntr => row_pag,
				ena  => wrowpag_ena,
				load => rowpag_load,
				data => 18);
		end if;
	end process;

	process (win_clk)
		variable rowcnt_addr : unsigned(0 to rowpag_size-1);
	begin
		if rising_edge(win_clk) then
			if wrowpag_ena='1' then
				rdata <= rowcnt_data(to_integer(rowcnt_addr));
				rowcnt_addr := unsigned(row_pag(1 to rowpag_size));
			end if;
		end if;
	end process;

	colid_e : entity hdl4fpga.align
	generic map (
		n => colid_size,
		d => (0 to colid_size-1 => 1))
	port map (
		clk => win_clk,
		ena => wcolpag_ena ,
		di  => std_logic_vector(cdata(colside_id'range)),
		do  => win_colid);

	wcolpag_ena <= colpag_ena or col_cnt(0);
	colpag_e : entity hdl4fpga.align
	generic map (
		n => colpag_size,
		d => (0 to colpag_size-1 => 2))
	port map (
		clk => win_clk,
		ena => wcolpag_ena,
		di  => col_pag(1 to colpag_size),
		do  => win_colpag);

	process (win_clk)
		variable ena : std_logic_vector(3 downto 0);
		variable wdon_edge : std_logic;
	begin
		if rising_edge(win_clk) then
			colpag_load <= '0';
			if win_don='0' then
				if wdon_edge='1' then
					colpag_load <= '1';
					ena := (others => '1');
				end if;
			end if;
			colpag_ena <= ena(3);

			ena := ena sll 1;
			wdon_edge := win_don;
		end if;
	end process;

	process (win_clk)
	begin
		if rising_edge(win_clk) then
			col_pag <= dec (
				cntr => col_pag,
				ena  => wcolpag_ena,
				load => colpag_load,
				data => 2);
		end if;
	end process;

	process (win_clk)
		variable colcnt_addr : unsigned(0 to colpag_size-1);
	begin
		if rising_edge(win_clk) then
			if wcolpag_ena='1' then
				cdata <= colcnt_data(to_integer(colcnt_addr));
				colcnt_addr := unsigned(col_pag(1 to colpag_size));
			end if;
		end if;
	end process;

	-- Region --
	------------

	process (win_clk)
	begin
		if rising_edge(win_clk) then
			row_cnt <= dec (
				cntr => row_cnt,
				ena  => rowpag_ena or colpag_load,
				load => rowpag_ena or row_cnt(0),
				data => std_logic_vector(rdata(rowside_sz'range)));
		end if;
	end process;

	process (win_clk)
	begin
		if rising_edge(win_clk) then
			col_cnt <= dec (
				cntr => col_cnt,
				ena  => colpag_ena or win_don,
				load => colpag_ena or col_cnt(0),
				data => std_logic_vector(cdata(colside_sz'range)));

		end if;
	end process;

	win_rowoff <= row_cnt;
	win_coloff <= col_cnt;
end;
