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

entity xcs3_ddrphy is
	generic (
		loopback    : boolean;
		iddron      : boolean   := false;
		rgtr_dout : boolean   := true;
		gate_delay  : natural   := 1;
		CMMD_GEAR   : natural   := 1;
		data_gear   : natural   := 2;
		bank_size   : natural   := 2;
		addr_size   : natural   := 13;
		word_size   : natural   := 16;
		byte_size   : natural   := 8;
		clkinv      : std_logic := '0');
	port (
		sys_clks : in std_logic_vector(0 to 2-1);
		sys_rst  : in std_logic;
		
		phy_rst  : in  std_logic_vector(CMMD_GEAR-1 downto 0) := (others => '1');
		phy_cs   : in  std_logic_vector(CMMD_GEAR-1 downto 0) := (others => '0');
		phy_cke  : in  std_logic_vector(CMMD_GEAR-1 downto 0);
		phy_ras  : in  std_logic_vector(CMMD_GEAR-1 downto 0);
		phy_cas  : in  std_logic_vector(CMMD_GEAR-1 downto 0);
		phy_we   : in  std_logic_vector(CMMD_GEAR-1 downto 0);
		phy_b    : in  std_logic_vector(CMMD_GEAR*bank_size-1 downto 0);
		phy_a    : in  std_logic_vector(CMMD_GEAR*addr_size-1 downto 0);
		phy_odt  : in  std_logic_vector(CMMD_GEAR-1 downto 0);

		phy_dmt  : in  std_logic_vector(0 to data_gear*word_size/byte_size-1);
		phy_dmi  : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		phy_dmo  : out std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		phy_dqt  : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		phy_dqi  : in  std_logic_vector(data_gear*word_size-1 downto 0);
		phy_dqo  : out std_logic_vector(data_gear*word_size-1 downto 0);

		phy_dqsi : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		phy_dqst : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		phy_dqso : out std_logic_vector(data_gear*word_size/byte_size-1 downto 0) := (others => '-');
		phy_sti  : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0) := (others => '-');
		phy_sto  : out std_logic_vector(data_gear*word_size/byte_size-1 downto 0);

		ddr_cs  : out std_logic := '0';
		ddr_cke : out std_logic := '1';
		ddr_clk : out std_logic_vector;
		ddr_odt : out std_logic;
		ddr_ras : out std_logic;
		ddr_cas : out std_logic;
		ddr_we  : out std_logic;
		ddr_b   : out std_logic_vector(bank_size-1 downto 0);
		ddr_a   : out std_logic_vector(addr_size-1 downto 0);

		ddr_sti  : in  std_logic_vector(word_size/byte_size-1 downto 0) := (others => '-');
		ddr_sto  : out std_logic_vector(word_size/byte_size-1 downto 0);

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

architecture xnlx of xcs3_ddrphy is
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
		variable val : byte_vector(phy_dqi'length/byte_size-1 downto 0);
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

	signal dqrst : std_logic;
	signal ph : std_logic_vector(0 to 6-1);

begin

	ddr_clk_g : for i in ddr_clk'range generate
		ck_i : entity hdl4fpga.ddro
		port map (
			clk => sys_clks(0),
			dr => '0' xor clkinv,
			df => '1' xor clkinv,
			q  => ddr_clk(i));
	end generate;

	ddrbaphy_i : entity hdl4fpga.xcs3_ddrbaphy
	generic map (
		GEAR      => CMMD_GEAR,
		bank_size => bank_size,
		addr_size => addr_size)
	port map (
		sys_clks => sys_clks,
          
		sys_rst => sys_rst,
		phy_rst => phy_rst,
		phy_cs  => phy_cs,
		phy_cke => phy_cke,
		phy_b   => phy_b,
		phy_a   => phy_a,
		phy_ras => phy_ras,
		phy_cas => phy_cas,
		phy_we  => phy_we,
		phy_odt => phy_odt,
        
		ddr_cke => ddr_cke,
		ddr_odt => ddr_odt,
		ddr_cs  => ddr_cs,
		ddr_ras => ddr_ras,
		ddr_cas => ddr_cas,
		ddr_we  => ddr_we,
		ddr_b   => ddr_b,
		ddr_a   => ddr_a);

	sdmi  <= to_blinevector(shuffle_stdlogicvector(phy_dmi));
	ssti  <= to_blinevector(phy_sti);
	sdmt  <= to_blinevector(not phy_dmt);
	sdqt  <= to_blinevector(not phy_dqt);
	sdqi  <= shuffle_dlinevector(phy_dqi);
	ddqi  <= to_bytevector(ddr_dqi);
	sdqsi <= to_blinevector(phy_dqsi);
	sdqst <= to_blinevector(phy_dqst);

	byte_g : for i in word_size/byte_size-1 downto 0 generate
		signal dqso : std_logic_vector(0 to 1);
	begin

		ddrdqphy_i : entity hdl4fpga.xcs3_ddrdqphy
		generic map (
			rgtr_dout => rgtr_dout,
			loopback => loopback,
			gear => data_gear,
			byte_size => byte_size)
		port map (
			sys_clks => sys_clks,

			phy_sti => ssti(i),
			phy_dmt => sdmt(i),
			phy_dmi => sdmi(i),

			phy_dqi  => sdqi(i),
			phy_dqt  => sdqt(i),
			phy_dqo  => sdqo(i),

			phy_dqsi => sdqsi(i),
			phy_dqst => sdqst(i),

			ddr_dqi  => ddqi(i),
			ddr_dqt  => ddqt(i),
			ddr_dqo  => ddqo(i),
			ddr_sto  => ddr_sto(i),

			ddr_dmt  => ddmt(i),
			ddr_dmo  => ddmo(i),

			ddr_dqst => ddr_dqst(i),
			ddr_dqso => ddr_dqso(i));


		dqs_delayed_e : entity hdl4fpga.pgm_delay
		generic map(
			n => gate_delay)
		port map (
			xi  => ddr_dqsi(i),
			x_p => dqso(0),
			x_n => dqso(1));
		phy_dqso(data_gear*i+0) <= dqso(0) after 1 ns;
		phy_dqso(data_gear*i+1) <= dqso(1) after 1 ns;

	end generate;

	process(ddr_dm, ddr_sti)
	begin
		for i in 0 to word_size/byte_size-1 loop
			for j in 0 to data_gear-1 loop
				if loopback then
					phy_sto(data_gear*i+j) <= ddr_sti(i);
				else
					phy_sto(data_gear*i+j) <= ddr_dm(i);
				end if;
			end loop;
		end loop;
	end process;

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

	phy_dqo <= to_stdlogicvector(sdqo);
end;
