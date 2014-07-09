library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity xdr_sch is
	generic (
		data_phases : natural;
		data_edges  : natural := 2;
		byte_size   : natural;
		word_size   : natural;

		clword_size : natural;
		clword_data : std_logic_vector;
		clword_lat  : natural_vector;

		cwlword_size : natural;
		cwlword_data : std_logic_vector;
		cwlword_lat  : natural_vector);
	port (
		sys_cl   : in  std_logic_vector(clword_size-1 downto 0);
		sys_cwl  : in  std_logic_vector(cwlword_size-1 downto 0);
		sys_clks : in  std_logic_vector(0 to data_phases/data_edges-1);
		sys_wri  : in  std_logic;

		xdr_dqsz : out std_logic_vector(0 to (word_size/byte_size)*data_phases-1);
		xdr_dqs  : out std_logic_vector(0 to (word_size/byte_size)*data_phases-1);
		xdr_dqz  : out std_logic_vector(0 to (word_size/byte_size)*data_phases-1);
		xdr_stw  : out std_logic_vector(0 to (word_size/byte_size)*data_phases-1));

	constant data_rate : natural := data_phases/data_edges;
	constant delay_size : natural := 32;

end;

architecture def of xdr_sch is
	subtype word is std_logic_vector(0 to word_size/byte_size*data_phases-1);
	type word_vector is array (natural range <>) of word;
	signal ph_wri : std_logic_vector (0 to delay_size);
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
		delay_phase => 2)
	port map (
		sys_clks => sys_clks,
		sys_di => sys_wri,
		ph_qo => ph_wri);

	dqsz_p : process (ph_rea, sys_cwl)
		variable disp : natural;
		variable disp_mod : natural;
		variable disp_quo : natural;
		variable phase : natural;
		variable dqsz : word_vector(0 to 2**cwlword_size-1);
	begin
		dqsz := (others => (others => '-'));
		setup_l : for i in 0 to cwltab_size-1 loop
			disp := cwlword_lat(i);
			disp_mod := disp mod word'length;
			disp_quo := disp  /  word'length;
			dqsz(i)((disp+0) mod word'length) := 
				ph_wri(disp_quo*word'length+(disp_mod+0)/word_byte) or 
				ph_wri(disp_quo*word'length+(disp_mod+word'length)/word_byte);
			for j in 1 to word'right loop
				phase := (j+disp_mod)/word_byte;
				dqsz(i)((disp+j) mod word'length) := ph_wri(disp_quo*word'length + phase);
			end loop;
		end loop;

		xdr_dqsz <= (others =>  '-');
		select_l : for i in 0 to cltab_size-1 loop
			if sys_cwl = cltab_data(i) then
				for j in word'range loop
					xdr_dqsz(j) <= dqsz(i)(j);
				end loop;
			end if;
		end loop;
	end process;

	dqs_p : process (ph_rea, sys_cwl)
		variable disp : natural;
		variable disp_mod : natural;
		variable disp_quo : natural;
		variable phase : natural;
		variable dqs : word_vector(0 to 2**cwlword_size-1);
	begin
		dqs := (others => (others => '-'));
		setup_l : for i in 0 to cwltab_size-1 loop
			disp := cwlword_lat(i);
			disp_mod := disp mod word'length;
			disp_quo := disp  /  word'length;
			dqs(i)((disp+0) mod word'length) := 
				ph_wri(disp_quo*word'length+(disp_mod+0)/word_byte) or 
				ph_wri(disp_quo*word'length+(disp_mod+word'length)/word_byte);
			for j in 1 to word'right loop
				phase := (j+disp_mod)/word_byte;
				dqs(i)((disp+j) mod word'length) := ph_wri(disp_quo*word'length + phase);
			end loop;
		end loop;

		xdr_dqsz <= (others =>  '-');
		select_l : for i in 0 to cltab_size-1 loop
			if sys_cwl = cwltab_data(i) then
				for j in word'range loop
					xdr_dqs(j) <= dqs(i)(j);
				end loop;
			end if;
		end loop;
	end process;

	function setup_lat (
		constant window : natural;
		constant phases : std_logic_vector;
		constant latency_data : lword_vector)
		return word_vector is
		variable disp : natural;
		variable disp_mod : natural;
		variable disp_quo : natural;
		variable pha : natural;
		variable aux : std_logic;
		variable val : word_vector(lat_data'range);
	begin
		val := (others => (others => '-'));
		setup_l : for i in 0 to cltab_size-1 loop
			disp := clword_lat(i);
			disp_mod := disp mod word'length;
			disp_quo := disp / word'length;
			for j in word'range loop
				aux := '0';
				for l in 0 to (word'length-j+window)/word'length loop
					pha := (j+disp_mod+l*word'length)/word_byte;
					aux := aux or phases(disp_quo*word'length+pha);
				end loop;
				val(i)((disp+j) mod word'length) := aux;
			end loop;
		end loop;
		return val;
	end;

	dqs_p : process (ph_rea, sys_cwl)
		variable disp : natural;
		variable disp_mod : natural;
		variable disp_quo : natural;
		variable phase : natural;
		variable dtw : word_vector(0 to 2**sys_cwl'length-1);
	begin
		dtw := (others => (others => '-'));
		setup_l : for i in 0 to cltab_size-1 loop
			disp := clword_lat(i);
			disp_mod := disp mod word'length;
			disp_quo := disp / word'length;
			for j in word'range loop
				phase := (j+disp_mod)/word_byte;
				dtw(i)((disp+j) mod word'length) := ph_rea(disp_quo*word'length + phase);
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
