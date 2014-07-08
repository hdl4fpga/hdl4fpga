library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.xdr_param.all;

entity xdr_rdsch is
	generic (
		data_phases : natural;
		data_edges  : natural := 2;
		byte_size   : natural;
		word_size   : natural;
		clword_size : natural;
		clword_data : std_logic_vector;
		clword_lat  : natural_vector);
	port (
		sys_cl   : in  std_logic_vector;
		sys_clks : in  std_logic_vector(0 to data_phases/data_edges-1);
		sys_rea  : in  std_logic;
		xdr_dqw  : out std_logic_vector(0 to (word_size/byte_size)*data_phases-1);
		xdr_stw  : out std_logic_vector(0 to (word_size/byte_size)*data_phases-1));

	constant data_rate : natural := data_phases/data_edges;
	constant delay_size : natural := 16;

end;

use std.textio.all;

architecture def of xdr_rdsch is
	subtype word is std_logic_vector(0 to word_size/byte_size*data_phases-1);
	type word_vector is array (natural range <>) of word;
	signal ph_rea : std_logic_vector (0 to delay_size);
	constant cycle : natural := data_phases*word_size/byte_size;
	subtype clword is std_logic_vector(0 to clword_size-1);
	type clword_vector is array (natural range <>) of clword;

	function to_clwordvector(
		constant arg : std_logic_vector)
		return clword_vector is
		variable aux : std_logic_vector(0 to arg'length-1) := arg;
		variable val : clword_vector(0 to arg'length/clword'length-1);
	begin
		for i in val'range loop
			val(i) := aux(clword'range);
			aux := aux sll clword'length;
		end loop;
		return val;
	end;

	constant cltab_size : natural := sys_cl'length/clword_size;
	constant cltab_data : clword_vector(0 to cltab_size-1) := to_clwordvector(clword_data);
	constant word_byte : natural := word_size/byte_size;


begin
	
	xdr_ph_read : entity hdl4fpga.xdr_ph
	generic map (
		data_phases => data_phases,
		data_edges  => data_edges,
		delay_size => delay_size,
		delay_phase => 1)
	port map (
		sys_clks => sys_clks,
		sys_di => sys_rea,
		ph_qo => ph_rea);

	stw_p : process (ph_rea, sys_cl)
		constant disp : natural := 2;
		variable stw : word_vector(0 to 2**clword_size-1);
		variable base : natural;
		variable msg :line;
	begin
		stw := (others => (others => '-'));
		setup_l : for i in 0 to cltab_size-1 loop
			base := (clword_lat(i)) mod (word_size/byte_size)+disp;
			stw(i)((base+0) mod word_byte) := ph_rea(0+clword_lat(i)) or ph_rea(data_phases+clword_lat(i));
			for j in 1 to word'right loop
				stw(i)((j/word_byte)*word_byte+(base+j) mod word_byte) := ph_rea(clword_lat(i)+(j/word_byte+data_phases*((base+j) / word_byte)));
				write(msg, (j/word_byte+data_phases*((base+j) / word_byte)));
				write(msg, ',');
				report msg.all;
			end loop;
		end loop;

		xdr_stw <= (others =>  '-');
		select_l : for i in 0 to cltab_size-1 loop
			if sys_cl = cltab_data(i) then
				for j in word'range loop
					xdr_stw(j) <= stw(i)(j);
				end loop;
			end if;
		end loop;
	end process;

	dqw_p : process (ph_rea, sys_cl)
		constant disp : natural := 2;
		variable dtw : word_vector(0 to 2**sys_cl'length-1);
		variable base : natural;
	begin
		dtw := (others => (others => '-'));
		setup_l : for i in 0 to cltab_size-1 loop
			base := (clword_lat(i)) mod (word_size/byte_size)+disp;
			for j in word'range loop
				dtw(i)(j) := ph_rea(clword_lat(i)+(j/(word_size/byte_size)));
				dtw(i)((j/word_byte)*word_byte+(base+j) mod word_byte) := ph_rea(clword_lat(i)+(j/word_byte+data_phases*((base+j) / word_byte)));
			end loop;
		end loop;

		xdr_dqw <= (others =>  '-');
		select_l : for i in 0 to cltab_size-1 loop
			if sys_cl = cltab_data(i) then
				for j in word'range loop
					xdr_dqw(j) <= dtw(i)(j);
				end loop;
			end if;
		end loop;
	end process;
end;
