library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xdr_rdsch is
	generic (
		data_phases : natural;
		data_edges  : natural := 2;
		data_bytes  : natural;
		cl_size : natural;
		byte_size : natural;
		word_size : natural);
	port (
		sys_cl   : in  std_logic_vector;
		sys_clks : in  std_logic_vector(0 to data_phases/data_edges-1);
		sys_rea  : in  std_logic;
		xdr_dqw  : out std_logic := '0';
		xdr_stw  : out std_logic_vector(0 to data_phases-1));

	constant data_rate : natural := data_phases/data_edges;
	constant delay_size : natural := 16;

end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture def of xdr_rdsch is
	subtype word is std_logic_vector(data_phases-1 downto 0);
	type word_vector is array (natural range <>) of word;
	signal ph_rea : std_logic_vector (0 to delay_size-1);
	constant cycle : natural := data_phases*word_size/byte_size;
	subtype clword is std_logic_vector(0 to cl_size-1);
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

	constant cl_sel : clword_vector(sys_cl'length/cl_size-1 downto 0) := (others => (others => '-'));
	signal ph_din : std_logic_vector(0 to word_size/byte_size-1) := (others => '-');

begin
	
	ph_din <= (0 to word_size/byte_size-1 => sys_rea);
	xdr_ph_read : entity hdl4fpga.xdr_ph
	generic map (
		data_phases => data_phases,
		data_edges  => data_edges,
		byte_size => byte_size,
		word_size => word_size,
		delay_size => delay_size,
		delay_phase => 2)
	port map (
		sys_clks => sys_clks,
		sys_di => ph_din,
		ph_qo => ph_rea);

	stw_p : process (ph_rea, sys_cl)
		variable stw : word_vector(0 to 2**sys_cl'length-1) := (others => (others => '-'));
	begin
		setup_l : for i in 0 to cl_size-1 loop
			stw(i)(0) := not (ph_rea(0+i) and ph_rea(data_phases+i));
			for j in 1 to data_phases-1 loop
				stw(i)(j) := not ph_rea(data_phases*i+j);
			end loop;
		end loop;

		for j in 0 to data_phases-1 loop
			xdr_stw(j) <= stw(to_integer(unsigned(sys_cl)))(j);
		end loop;
	end process;

	dqw_p : process (ph_rea, sys_cl)
		variable dtw : word_vector(0 to 2**sys_cl'length-1) := (others => (others => '-'));
	begin
		setup_l : for i in 0 to cl_size-1 loop
			for j in 0 to data_phases-1 loop
				dtw(i)(j) := not ph_rea(2*data_phases+i);
			end loop;
		end loop;

		for j in 0 to data_phases-1 loop
			xdr_dqw <= dtw(to_integer(unsigned(sys_cl)))(j);
		end loop;
	end process;

end;
