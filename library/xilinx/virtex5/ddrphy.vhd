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

entity ddrphy is
	generic (
		cmd_phases : natural := 1;
		data_gear : natural := 2;
		bank_size : natural := 2;
		addr_size : natural := 13;
		word_size : natural := 16;
		byte_size : natural := 8;
		clkinv : std_logic := '0');
	port (
		sys_rst  : in std_logic;
		sys_clk0  : in std_logic;
		sys_clk90 : in std_logic;
		phy_rst : in std_logic;

		phy_ini : out std_logic;
		phy_cmd_rdy : in  std_logic;
		phy_cmd_req : out std_logic;
		phy_rw : out std_logic;

		sys_cs   : in  std_logic_vector(cmd_phases-1 downto 0) := (others => '0');
		sys_cke  : in  std_logic_vector(cmd_phases-1 downto 0);
		sys_ras  : in  std_logic_vector(cmd_phases-1 downto 0);
		sys_cas  : in  std_logic_vector(cmd_phases-1 downto 0);
		sys_we   : in  std_logic_vector(cmd_phases-1 downto 0);
		sys_b    : in  std_logic_vector(cmd_phases*bank_size-1 downto 0);
		sys_a    : in  std_logic_vector(cmd_phases*addr_size-1 downto 0);
		sys_odt  : in  std_logic_vector(cmd_phases-1 downto 0);

		sys_dmt  : in  std_logic_vector(0 to data_gear*word_size/byte_size-1);
		sys_dmi  : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		sys_dmo  : out std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		sys_dqt  : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		sys_dqo  : in  std_logic_vector(data_gear*word_size-1 downto 0);
		sys_dqi  : out std_logic_vector(data_gear*word_size-1 downto 0);

		sys_dqso : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		sys_dqst : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		sys_sti  : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0) := (others => '-');
		sys_sto  : out std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		sys_tp :  out std_logic_vector(word_size-1 downto 0);

		sys_wlreq : in std_logic;
		sys_wlrdy : out std_logic;
		sys_wlcal : out std_logic;
		sysiod_clk : in  std_logic;

		ddr_cs  : out std_logic := '0';
		ddr_cke : out std_logic := '1';
		ddr_clk : out std_logic_vector;
		ddr_odt : out std_logic;
		ddr_ras : out std_logic;
		ddr_cas : out std_logic;
		ddr_we  : out std_logic;
		ddr_b   : out std_logic_vector(bank_size-1 downto 0);
		ddr_a   : out std_logic_vector(addr_size-1 downto 0);

		ddr_dm  : inout  std_logic_vector(word_size/byte_size-1 downto 0);
		ddr_dqt  : out std_logic_vector(word_size-1 downto 0);
		ddr_dqi  : in  std_logic_vector(word_size-1 downto 0);
		ddr_dqo  : out std_logic_vector(word_size-1 downto 0);
		ddr_dqst : out std_logic_vector(word_size/byte_size-1 downto 0);
		ddr_dqsi : in std_logic_vector(word_size/byte_size-1 downto 0);
		ddr_dqso : out std_logic_vector(word_size/byte_size-1 downto 0));

end;

library hdl4fpga;
use hdl4fpga.std.all;

library unisim;
use unisim.vcomponents.all;

architecture virtex of ddrphy is
	subtype tapsw is std_logic_vector(6-1 downto 0);
	type tapsw_vector is array (natural range <>) of tapsw;

	function to_stdlogicvector (
		constant arg : tapsw_vector)
		return std_logic_vector is
		variable dat : tapsw_vector(arg'length-1 downto 0);
		variable val : std_logic_vector(arg'length*arg(arg'left)'length-1 downto 0);
	begin
		dat := arg;
		for i in dat'range loop
			val := std_logic_vector(unsigned(val) sll arg(arg'left)'length);
			val(arg(arg'left)'range) := dat(i);
		end loop;
		return val;
	end;

	subtype byte is std_logic_vector(byte_size-1 downto 0);
	type byte_vector is array (natural range <>) of byte;

	subtype dline_word is std_logic_vector(data_gear*byte_size-1 downto 0);
	type dline_vector is array (natural range <>) of dline_word;

	subtype bline_word is std_logic_vector(data_gear-1 downto 0);
	type bline_vector is array (natural range <>) of bline_word;

	function to_bytevector (
		constant arg : std_logic_vector) 
		return byte_vector is
		variable dat : unsigned(arg'length-1 downto 0);
		variable val : byte_vector(arg'length/byte'length-1 downto 0);
	begin	
		dat := unsigned(arg);
		for i in val'reverse_range loop
			val(i) := std_logic_vector(dat(byte'range));
			dat := dat srl val(val'left)'length;
		end loop;
		return val;
	end;

	function to_blinevector (
		constant arg : std_logic_vector) 
		return bline_vector is
		variable dat : unsigned(arg'length-1 downto 0);
		variable val : bline_vector(arg'length/bline_word'length-1 downto 0);
	begin	
		dat := unsigned(arg);
		for i in val'reverse_range loop
			val(i) := std_logic_vector(dat(val(val'left)'length-1 downto 0));
			dat := dat srl val(val'left)'length;
		end loop;
		return val;
	end;

	function to_dlinevector (
		constant arg : std_logic_vector) 
		return dline_vector is
		variable dat : unsigned(arg'length-1 downto 0);
		variable val : dline_vector(arg'length/dline_word'length-1 downto 0);
	begin	
		dat := unsigned(arg);
		for i in val'reverse_range loop
			val(i) := std_logic_vector(dat(val(val'left)'length-1 downto 0));
			dat := dat srl val(val'left)'length;
		end loop;
		return val;
	end;

	function to_stdlogicvector (
		constant arg : byte_vector)
		return std_logic_vector is
		variable dat : byte_vector(arg'length-1 downto 0);
		variable val : std_logic_vector(arg'length*arg(arg'left)'length-1 downto 0);
	begin
		dat := arg;
		for i in dat'range loop
			val := std_logic_vector(unsigned(val) sll arg(arg'left)'length);
			val(arg(arg'left)'range) := dat(i);
		end loop;
		return val;
	end;

	function to_stdlogicvector (
		constant arg : dline_vector)
		return std_logic_vector is
		variable dat : dline_vector(arg'length-1 downto 0);
		variable val : std_logic_vector(arg'length*arg(arg'left)'length-1 downto 0);
	begin
		dat := arg;
		for i in dat'range loop
			val := std_logic_vector(unsigned(val) sll arg(arg'left)'length);
			val(arg(arg'left)'range) := dat(i);
		end loop;
		return val;
	end;

	function to_stdlogicvector (
		constant arg : bline_vector)
		return std_logic_vector is
		variable dat : bline_vector(arg'length-1 downto 0);
		variable val : std_logic_vector(arg'length*arg(arg'left)'length-1 downto 0);
	begin
		dat := arg;
		for i in dat'range loop
			val := std_logic_vector(unsigned(val) sll arg(arg'left)'length);
			val(arg(arg'left)'range) := dat(i);
		end loop;
		return val;
	end;

	function shuffle_stdlogicvector (
		constant arg : std_logic_vector) 
		return std_logic_vector is
		variable dat : std_logic_vector(0 to arg'length-1);
		variable val : std_logic_vector(dat'range);
	begin	
		dat := arg;
		for i in word_size/byte_size-1 downto 0 loop
			for j in data_gear-1 downto 0 loop
				val(i*data_gear+j) := dat(j*word_size/byte_size+i);
			end loop;
		end loop;
		return val;
	end;

	function shuffle_dlinevector (
		constant arg : std_logic_vector) 
		return dline_vector is
		variable dat : byte_vector(0 to arg'length/byte'length-1);
		variable val : byte_vector(dat'range);
	begin	
		dat := to_bytevector(arg);
		for i in word_size/byte_size-1 downto 0 loop
			for j in data_gear-1 downto 0 loop
				val(i*data_gear+j) := dat(j*word_size/byte_size+i);
			end loop;
		end loop;
		return to_dlinevector(to_stdlogicvector(val));
	end;

	function unshuffle(
		constant arg : dline_vector) 
		return byte_vector is
		variable val : byte_vector(sys_dqi'length/byte_size-1 downto 0);
		variable aux : byte_vector(0 to data_gear-1);
	begin	
		for i in arg'range loop
			aux := to_bytevector(arg(i));
			for j in aux'range loop
				val(j*arg'length+i) := aux(j);
			end loop;
		end loop;
		return val;
	end;

	signal dqsdel : std_logic;
	signal sdmt : bline_vector(word_size/byte_size-1 downto 0);
	signal sdmi : bline_vector(word_size/byte_size-1 downto 0);
	signal ssti : bline_vector(word_size/byte_size-1 downto 0);

	signal sdqt : bline_vector(word_size/byte_size-1 downto 0);
	signal sdqi : dline_vector(word_size/byte_size-1 downto 0);
	signal sdqo : dline_vector(word_size/byte_size-1 downto 0);

	signal sdqsi : bline_vector(word_size/byte_size-1 downto 0);
	signal sdqst : bline_vector(word_size/byte_size-1 downto 0);

	signal ddmo : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddmt : std_logic_vector(word_size/byte_size-1 downto 0);
	signal dsto : std_logic_vector(word_size/byte_size-1 downto 0);

	signal ddqi : byte_vector(word_size/byte_size-1 downto 0);
	signal ddqt : byte_vector(word_size/byte_size-1 downto 0);
	signal ddqo : byte_vector(word_size/byte_size-1 downto 0);
	signal dqiod_ce  : byte_vector(word_size/byte_size-1 downto 0);
	signal dqiod_inc : byte_vector(word_size/byte_size-1 downto 0);
	signal byte_wlrdy : std_logic_vector(ddr_dqsi'range);
	signal byte_wlcal : std_logic_vector(ddr_dqsi'range);

	signal dqrst : std_logic;
	signal ph : std_logic_vector(0 to 6-1);
	
	signal phy_ba : std_logic_vector(sys_b'range);
	signal phy_a  : std_logic_vector(sys_a'range);

	signal ini : std_logic;
	signal rw  : std_logic;
	signal cmd_req : std_logic;
	signal cmd_rdy : std_logic;
	signal wlrdy : std_logic;
	signal lvl : std_logic;

begin
	ddr_clk_g : for i in ddr_clk'range generate
		ck_i : entity hdl4fpga.ddro
		port map (
			clk => sys_clk0,
			dr => '0' xor clkinv,
			df => '1' xor clkinv,
			q  => ddr_clk(i));
	end generate;

	process (sys_clk0)
	begin
		if rising_edge(sys_clk0) then
			phy_ini <= ini;
			phy_rw  <= rw;
			sys_wlrdy <= wlrdy;
			phy_cmd_req <= cmd_req;
			cmd_rdy <= phy_cmd_rdy;
		end if;
	end process;

	phy_ba  <= sys_b when lvl='0' else (others => '0');
	phy_a   <= sys_a when lvl='0' else (others => '0');
	
	process (sysiod_clk)
	begin
		if rising_edge(sysiod_clk) then
			if phy_rst='1' then
				ini <= '0';
				rw  <= '0';
				cmd_req <= '0';
				lvl  <= '0';
			elsif ini='0' then
				if sys_wlreq='1' then
					if cmd_req='1' then
						if cmd_rdy='0' then
							if rw='0' then 
								cmd_req <= '0';
							elsif wlrdy='1' then
								cmd_req <= '0';
							end if;
						end if;
					elsif cmd_rdy='1' then
						if rw='0' then 
							cmd_req <= '1';
						else
							ini <= '1';
						end if;
						rw <= '1';
					end if;
					lvl <= '1';
				elsif cmd_rdy='1' then
					cmd_req <= '1';
					lvl <= '0';
				else
					cmd_req <= '0';
					lvl <= '0';
				end if;
			else
				cmd_req <= '0';
				lvl <= '0';
			end if;
		end if;

	end process;

	ddrbaphy_i : entity hdl4fpga.ddrbaphy
	generic map (
		cmd_phases => cmd_phases,
		bank_size => bank_size,
		addr_size => addr_size)
	port map (
		sys_clk => sys_clk0,
          
		sys_cs  => sys_cs,
		sys_cke => sys_cke,
		sys_b   => phy_ba,
		sys_a   => phy_a,
		sys_ras => sys_ras,
		sys_cas => sys_cas,
		sys_we  => sys_we,
		sys_odt => sys_odt,
        
		ddr_cke => ddr_cke,
		ddr_odt => ddr_odt,
		ddr_cs  => ddr_cs,
		ddr_ras => ddr_ras,
		ddr_cas => ddr_cas,
		ddr_we  => ddr_we,
		ddr_b   => ddr_b,
		ddr_a   => ddr_a);

	sdmi  <= to_blinevector(shuffle_stdlogicvector(sys_dmi));
	ssti  <= to_blinevector(sys_sti);
	sdmt  <= to_blinevector(not sys_dmt);
	sdqt  <= to_blinevector(not sys_dqt);
	sdqi  <= shuffle_dlinevector(sys_dqo);
	ddqi  <= to_bytevector(ddr_dqi);
	sdqsi <= to_blinevector(sys_dqso);
	sdqst <= to_blinevector(sys_dqst);

	process (sysiod_clk)
		variable aux : std_logic;
	begin
		aux := '1';
		if rising_edge(sysiod_clk) then
			for i in byte_wlcal'range loop
				aux := aux and byte_wlcal(i);
			end loop;
			sys_wlcal <= aux and not wlrdy;
		end if;
	end process;

	process (sysiod_clk)
		variable aux : std_logic;
	begin
		aux := '1';
		if rising_edge(sysiod_clk) then
			for i in byte_wlrdy'range loop
				aux := aux and byte_wlrdy(i);
			end loop;
			wlrdy <= aux;
		end if;
	end process;

	byte_g : for i in ddr_dqsi'range generate
		signal dqsi : std_logic_vector(0 to 1);
	begin

		ddrdqphy_i : entity hdl4fpga.ddrdqphy
		generic map (
			gear => data_gear,
			byte_size => byte_size)
		port map (
			sys_rst => sys_rst,
			sys_clk0  => sys_clk0,
			sys_clk90 => sys_clk90,
			sys_wlreq  => sys_wlreq,
			sys_wlrdy  => byte_wlrdy(i),
			sys_wlcal  => byte_wlcal(i),

			sys_sti => ssti(i),
			sys_dmt => sdmt(i),
			sys_dmi => sdmi(i),

			sys_dqo  => sdqi(i),
			sys_dqt  => sdqt(i),
			sys_dqi  => sdqo(i),

			sys_dqso => sdqsi(i),
			sys_dqst => sdqst(i),

			sysiod_clk => sysiod_clk,
			sys_tp => sys_tp((i+1)*byte_size-1 downto i*byte_size),
			sys_sto => sys_sto((i+1)*data_gear-1 downto i*data_gear),

			ddr_dqsi => ddr_dqsi(i),
			ddr_dqi  => ddqi(i),
			ddr_dqt  => ddqt(i),
			ddr_dqo  => ddqo(i),

			ddr_dmt  => ddmt(i),
			ddr_dmo  => ddmo(i),

			ddr_dqst => ddr_dqst(i),
			ddr_dqso => ddr_dqso(i));

	end generate;

	ddr_dqt <= to_stdlogicvector(ddqt);
	ddr_dqo <= to_stdlogicvector(ddqo);

	process (ddmo, ddmt)
	begin
		for i in ddmo'range loop
			if ddmt(i)='1' then
				ddr_dm(i) <= 'Z';
			else
				ddr_dm(i) <= ddmo(i);
			end if;
		end loop;
	end process;

	sys_dqi <= to_stdlogicvector(sdqo);
end;
