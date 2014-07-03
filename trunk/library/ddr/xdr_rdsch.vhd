library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xdr_rdsch is
	generic (
		data_phases : natural;
		data_edges  : natural := 2;
		data_bytes  : natural;
		cl_phase : natural;
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

end;

library hdl4fpga;

architecture def of xdr_rdsch is
	subtype word is std_logic_vector(data_phases-1 downto 0);
	type word_vector is array (natural range <>) of word;
	signal ph_rea : std_logic_vector (0 to (delay_size+1)*(word_size/byte_size)-1);
	constant cycle : natural := data_phases*word_size/byte_size;
begin
	
	xdr_ph_read : entity hdl4fpga.xdr_ph
	generic map (
		data_phases => data_phases,
		data_edges  => data_edges,
		byte_size => byte_size,
		word_size => word_size,
		delay_size => 16,
		delay_phase => 2)
	port map (
		sys_clks => sys_clks,
		sys_di => sys_rea,
		ph_qo => ph_rea);

	stw_p : process (ph_rea, sys_cl)
		variable stw : word_vector(0 to 2**sys_cl'length-1) := (others => '-');
	begin
		setup_l : for i in 0 to cl_size-1 loop
			stw(i)(0) := not (ph_rea(0+i) and ph_rea(data_phases+i));
			for j in 1 to data_phases-1 loop
				stw(i)(j) := not ph_rea(data_phases*i+j);
			end loop
		end loop;

		for j in 0 to data_phases-1 loop
			xdr_stw(i) <= stw(to_unsigned(unsigned(sys_cl)))(j);
		end loop;
	end process;

	dqw_p : process (ph_rea, sys_cl)
		variable dtw : word_vector(0 to 2**sys_cl'length-1) := (others => '-');
	begin
		setup_l : for i in 0 to cl_size-1 loop
			for j in 0 to data_phases-1 loop
				dtw(i)(j) := not ph_rea(2*data_phases+i);
			end loop;
		end loop;

		for j in 0 to data_phases-1 loop
			xdr_dqw <= dtw(to_unsigned(unsigned(sys_cl)))(j);
		end loop;
	end process;

end;
