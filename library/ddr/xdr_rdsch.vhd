library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xdr_rdsch is
	generic (
		std  : positive range 1 to 3 := 3;
		data_phases : natural;
		data_edges  : natural := 2;
		data_bytes  : natural;
		byte_size : natural;
		word_size : natural);
	port (
		sys_lat : std_logic_vector;
		sys_clks : in std_logic_vector(0 to data_phases/data_edges-1);
		xdr_dqw : out std_logic := '0';
		xdr_stw : out std_logic_vector(0 to data_phases-1));

	constant data_rate : natural := data_phases/data_edges;

end;

library hdl4fpga;

architecture def of xdr_rdsch is
	constant start : natural := 0;
	constant stop  : natural := 1;

	constant lattab := (
		brst => (start => , stop => )
		ds   => (r => ( start => , stop => ))
begin

	------------------
	-- Read Enables --
	------------------
	
	xdr_ph_read : entity hdl4fpga.xdr_ph(slr)
	generic map (
		n => nr)
	port map (
		xdr_ph_clks => xdr_mpu_clk,
		xdr_ph_din(0) => xdr_mpu_rph,
		xdr_ph_din(1 to 4*nr+3*3) => xdr_phr_din,
		xdr_ph_qout(0) => ph_rea_dummy,
		xdr_ph_qout(1 to 4*nr+3*3) => ph_rea(1 to 4*nr+3*3));

	stw_p : process (ph_rea)
	begin
		xdr_stw(0) <= ph_rea() and ph_rea(4+);
		for i in 1 to data_phases-1 loop
			xdr_stw(i) <= not ph_rea(2+);
		end loop;
	end process;

	dqw_p : process (ph_rea)
	begin
		xdr_dqw <= not ph_rea(4*2+);
	end process;

	ddr1_g : if std=1 generate
	begin
		xdr_mpu_rwin <= not ph_rea(4*2+4*((ddr1_ph_4cas(to_integer(unsigned(xdr_mpu_cl)))+3)/4));
		xdr_mpu_drd(r)  <= not (
			ph_rea(ddr1_ph_4cas(to_integer(unsigned(xdr_mpu_cl)))) and
			ph_rea(4*1+ddr1_ph_4cas(to_integer(unsigned(xdr_mpu_cl)))));
		xdr_mpu_drd(f) <= not ph_rea(ddr1_ph_4cas(to_integer(unsigned(xdr_mpu_cl)))+2);
	end generate;

	ddr2_g : if std=2 generate
	begin
		xdr_mpu_rwin <= not ph_rea(4*2+4*ddr2_ph_cas(to_integer(unsigned(xdr_mpu_cl))));
		xdr_mpu_drd(r)  <= not (
			ph_rea(4*ddr2_ph_cas(to_integer(unsigned(xdr_mpu_cl)))+2+1-4-2) and
			ph_rea(4*1+4*ddr2_ph_cas(to_integer(unsigned(xdr_mpu_cl)))+2+1-4-2));
			ph_rea(4*ddr2_ph_cas(to_integer(unsigned(xdr_mpu_cl)))+1-4-2) and
			ph_rea(4*1+4*ddr2_ph_cas(to_integer(unsigned(xdr_mpu_cl)))+1-4-2));
	end generate;

	ddr3_g : if std=3 generate
	begin
		xdr_mpu_rwin <= not ph_rea(4*2+4*((4*ddr3_ph_cas(to_integer(unsigned(xdr_mpu_cl)))+3)/4));
		xdr_mpu_drd(r)  <= not (
			ph_rea(ddr3_ph_cas(to_integer(unsigned(xdr_mpu_cl)))) and 
			ph_rea(4*1+ddr3_ph_cas(to_integer(unsigned(xdr_mpu_cl)))));
		xdr_mpu_drd(f) <= not ph_rea(4*ddr3_ph_cas(to_integer(unsigned(xdr_mpu_cl)))+2);
	end generate;
end;
