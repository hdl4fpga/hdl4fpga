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
		xdr_dqw  : out std_logic := '0';
		xdr_stw  : out std_logic_vector(0 to data_phases-1));

	constant data_rate : natural := data_phases/data_edges;

end;

library hdl4fpga;

architecture def of xdr_rdsch is
	subtype word is std_logic_vector(data_phases-1 downto 0);
	type word_vector is array (natural range <>) of word;
begin
	
	xdr_ph_read : entity hdl4fpga.xdr_ph
	generic map (
		n => nr)
	port map (
		xdr_ph_clks => xdr_mpu_clk,
		xdr_ph_din(0) => xdr_mpu_rph,
		xdr_ph_din(1 to 4*nr+3*3) => xdr_phr_din,
		xdr_ph_qout(0) => ph_rea_dummy,
		xdr_ph_qout(1 to 4*nr+3*3) => ph_rea(1 to 4*nr+3*3));

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
