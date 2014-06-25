library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xdr_mpu is
	generic (
		std  : positive range 1 to 3 := 3;
		tCk  : natural := 6;
		tRCD : natural := (15+6-1)/6;
		tRFC : natural := (72+6-1)/6;
		tWR  : natural := (15+6-1)/6;
		tRP  : natural := (15+6-1)/6;
		data_phases : natural;
		data_edges  : natural := 2;
		data_bytes  : natural;
		xdr_mpu_bl : std_logic_vector(0 to 2) := "000";
		xdr_mpu_cl : std_logic_vector(0 to 2) := "010";
		xdr_mpu_cwl : std_logic_vector(0 to 2) := "010");
	port (
		xdr_mpu_rst : in std_logic;
		xdr_mpu_clks : in std_logic;
		xdr_mpu_cmd : in std_logic_vector(0 to 2) := (others => '1');
		xdr_mpu_rdy : out std_logic;
		xdr_mpu_act : out std_logic;
		xdr_mpu_cas : out std_logic := '1';
		xdr_mpu_ras : out std_logic := '1';
		xdr_mpu_we  : out std_logic := '1';

		xdr_mpu_rea : out std_logic := '0';
		xdr_mpu_wri : out std_logic := '0';
		xdr_mpu_wbl : out std_logic := '0';

		xdr_mpu_rwin : out std_logic := '0';
		xdr_mpu_drd : out std_logic_vector(data_edges-1 downto 0);

		xdr_mpu_dwr : out std_logic_vector(data_bytes*data_phases-1 downto 0) := (others => '0');
		xdr_mpu_dqs : out std_logic_vector(data_bytes-1 downto 0) := (others => '0');
		xdr_mpu_dqsz : out std_logic_vector(data_bytes-1 downto 0) := (others => '1');
		xdr_mpu_dqz : out std_logic_vector(data_bytes-1 downto 0) := (others => '1'));

	constant data_rate : natural := data_phases/data_edges;
	constant r : natural := 0;
	constant f : natural := 1;

end;

library hdl4fpga;

architecture arch of xdr_mpu is
	constant ras : natural := 0;
	constant cas : natural := 1;
	constant we  : natural := 2;
	constant n   : natural := 8;
	constant nr  : natural := 8;

	signal xdr_mpu_rph : std_logic := '1';
	signal xdr_mpu_wph : std_logic := '1';
	signal ph_rea : std_logic_vector(0 to 4*nr+9);
	signal ph_rea_dummy : std_logic;

	signal lat_timer : unsigned(0 to 9) := (others => '1');
	constant lat_length : natural := lat_timer'length;

	function to_timer (
		t : integer;
		l : integer) 
		return unsigned is
	begin
		return to_unsigned((2**l-2+t) mod 2**l, l);
	end;

	signal sel_cl : std_logic;
	signal xdr_rea : std_logic;
	signal xdr_wri : std_logic;

	type lattimer_vector is array (natural range <>) of std_logic_vector(0 to lat_timer'length-1);
	constant bl_data : lattimer_vector(0 to 4-1) := (
		std_logic_vector(to_timer(1, lat_length)),
		std_logic_vector(to_timer(2, lat_length)),
		std_logic_vector(to_timer(4, lat_length)),
		std_logic_vector(to_timer(8, lat_length)));

	constant cl1_data : lattimer_vector(0 to 8-1) := (
		2 => std_logic_vector(to_timer(2, lat_length)),
		3 => std_logic_vector(to_timer(3, lat_length)),
		6 => std_logic_vector(to_timer(3, lat_length)),
		others => (others => '-'));

	constant cl3_data : lattimer_vector(0 to 8-1) := (
		(others => '-'),
		std_logic_vector(to_timer(5, lat_length)),
		std_logic_vector(to_timer(6, lat_length)),
		std_logic_vector(to_timer(7, lat_length)),
		std_logic_vector(to_timer(8, lat_length)),
		std_logic_vector(to_timer(9, lat_length)),
		std_logic_vector(to_timer(10, lat_length)),
		std_logic_vector(to_timer(11, lat_length)));

	constant xdr_phr_din : std_logic_vector(1 to 4*nr+3*3) := (others => '-');
	constant xdr_ph_din : std_logic_vector(1 to 4*n+3*3) := (others => '-');

	type castab is array (natural range <>) of natural range 0 to 2**4-1;
	constant ddr1_ph_4cas : castab(0 to 8-1) := (
		0 => 0, 1 => 0, 2 => 4*2, 3 => 4*3,  
		4 => 0, 5 => 0, 6 =>  10, 7 => 4*0);

	constant ddr2_ph_cas : castab (0 to 8-1) := (
		0 => 0, 1 => 0, 2 => 0, 3 => 3,  
		4 => 4, 5 => 5, 6 => 6, 7 => 7);

	constant ddr3_ph_cas : castab(0 to 8-1) := (
		0 => 0, 1 => 4, 2 => 5,  3 => 6,  
		4 => 8, 5 => 9, 6 => 10, 7 => 11);

	type wltab is array (natural range <>) of natural range 0 to 2**4-1;
	constant ddr3_ph_cwl : wltab (0 to 8-1) := (
		0 => 5, 1 => 6, 2 => 7, 3 => 8,  
		4 => 0, 5 => 0, 6 => 0, 7 => 0);

	function xdr_cwl(
		std : positive range 1 to 3)
		return natural is
	begin
		case std is
		when 1 =>
			return tWR+1;
		when 2 =>
			return tWR+ddr2_ph_cas(to_integer(unsigned(xdr_mpu_cl)));
		when 3 =>
			return tWR+ddr3_ph_cwl(to_integer(unsigned(xdr_mpu_cwl)));
		end case;
	end;

--		 xdr_cmi => xdr_dcare, xdr_cmo => xdr_nop, xdr_lat => to_timer(tWR+1),
	constant xdr_nop   : std_logic_vector(0 to 2) := "111";
	constant xdr_act   : std_logic_vector(0 to 2) := "011";
	constant xdr_read  : std_logic_vector(0 to 2) := "101";
	constant xdr_write : std_logic_vector(0 to 2) := "100";
	constant xdr_pre   : std_logic_vector(0 to 2) := "010";
	constant xdr_aut   : std_logic_vector(0 to 2) := "001";
	constant xdr_dcare : std_logic_vector(0 to 2) := "000";

	constant ddrs_act      : std_logic_vector(0 to 2) := "011";
	constant ddrs_read_bl  : std_logic_vector(0 to 2) := "101";
	constant ddrs_read_cl  : std_logic_vector(0 to 2) := "001";
	constant ddrs_write_bl : std_logic_vector(0 to 2) := "100";
	constant ddrs_write_cl : std_logic_vector(0 to 2) := "000";
	constant ddrs_pre      : std_logic_vector(0 to 2) := "010";
	signal xdr_state : std_logic_vector(0 to 2);

	type xdr_state_word is record
		xdr_state : std_logic_vector(0 to 2);
		xdr_state_n : std_logic_vector(0 to 2);
		xdr_cmi : std_logic_vector(0 to 2);
		xdr_cmo : std_logic_vector(0 to 2);
		xdr_lat : unsigned(lat_timer'range);
		xdr_rea : std_logic;
		xdr_wri : std_logic;
		xdr_act : std_logic;
		xdr_rph : std_logic;
		xdr_wph : std_logic;
		xdr_rdy : std_logic;
	end record;

	function setif (
		arg : boolean)
		return natural is
		variable val : std_logic;
	begin
		case arg is
		when true =>
			return 1;
		when false =>
			return 0;
		end case;
	end function;

	signal xdr_rdy_ena : std_logic;

--	constant bl_time : std_logic_vector(lat_timer'range) := bl_data(to_integer(unsigned(xdr_mpu_bl)));
	constant bl_time : std_logic_vector(lat_timer'range) := bl_data(2); --to_integer(unsigned(xdr_mpu_bl)));
--	constant cl_time : std_logic_vector(lat_timer'range) := cl_data(natural'(setif(xdr_mpu_cl(0)='1' and xdr_mpu_cl(2)='1')));
	constant cl_time : std_logic_vector(lat_timer'range) := cl3_data(to_integer(unsigned(xdr_mpu_cl)));
	type xdr_state_vector is array(natural range <>) of xdr_state_word;
	constant xdr_state_tab : xdr_state_vector(0 to 11-1) := (

		-------------
		-- DDR_PRE --
		-------------

		(xdr_state => DDRS_PRE, xdr_state_n => DDRS_PRE,
		 xdr_cmi => xdr_nop, xdr_cmo => xdr_nop, xdr_lat => to_timer(1, lat_length),
		 xdr_rea => '0', xdr_wri => '0',
		 xdr_act => '1', xdr_rdy => '1', xdr_rph => '1', xdr_wph => '1'),
		(xdr_state => DDRS_PRE, xdr_state_n => DDRS_ACT,
		 xdr_cmi => xdr_act, xdr_cmo => xdr_act, xdr_lat => to_timer(tRCD, lat_length),
		 xdr_rea => '0', xdr_wri => '0',
		 xdr_act => '0', xdr_rdy => '1', xdr_rph => '1', xdr_wph => '1'),
		(xdr_state => DDRS_PRE, xdr_state_n => DDRS_PRE,
		 xdr_cmi => xdr_aut, xdr_cmo => xdr_aut, xdr_lat => to_timer(tRFC, lat_length),
		 xdr_rea => '0', xdr_wri => '0',
		 xdr_act => '1', xdr_rdy => '1', xdr_rph => '1', xdr_wph => '1'),

		-------------
		-- DDR_ACT --
		-------------

		(xdr_state => DDRS_ACT, xdr_state_n => DDRS_READ_BL,
		 xdr_cmi => xdr_read, xdr_cmo => xdr_read, xdr_lat => unsigned(bl_time),
		 xdr_rea => '1', xdr_wri => '0',
		 xdr_act => '0', xdr_rdy => '1', xdr_rph => '0', xdr_wph => '1'),
		(xdr_state => DDRS_ACT, xdr_state_n => DDRS_WRITE_BL,
		 xdr_cmi => xdr_write, xdr_cmo => xdr_write, xdr_lat => unsigned(bl_time),
		 xdr_rea => '0', xdr_wri => '1',
		 xdr_act => '0', xdr_rdy => '1', xdr_rph => '1', xdr_wph => '0'),

		--------------
		-- DDR_READ --
		--------------

		(xdr_state => DDRS_READ_BL, xdr_state_n => DDRS_READ_BL,
		 xdr_cmi => xdr_read, xdr_cmo => xdr_read, xdr_lat => unsigned(bl_time),
		 xdr_rea => '1', xdr_wri => '0',
		 xdr_act => '0', xdr_rdy => '1', xdr_rph => '0', xdr_wph => '1'),
		(xdr_state => DDRS_READ_BL, xdr_state_n => DDRS_READ_CL,
		 xdr_cmi => xdr_dcare, xdr_cmo => xdr_nop, xdr_lat => unsigned(cl_time),
		 xdr_rea => '1', xdr_wri => '0',
		 xdr_act => '0', xdr_rdy => '0', xdr_rph => '1', xdr_wph => '1'),
		(xdr_state => DDRS_READ_CL, xdr_state_n => DDRS_PRE,
		 xdr_cmi => xdr_dcare, xdr_cmo => xdr_pre, xdr_lat => to_timer(tRP, lat_length),
		 xdr_rea => '1', xdr_wri => '0',
		 xdr_act => '1', xdr_rdy => '1', xdr_rph => '1', xdr_wph => '1'),

		---------------
		-- DDR_WRITE --
		---------------

		(xdr_state => DDRS_WRITE_BL, xdr_state_n => DDRS_WRITE_BL,
		 xdr_cmi => xdr_write, xdr_cmo => xdr_write, xdr_lat => unsigned(bl_time),
		 xdr_rea => '0', xdr_wri => '1',
		 xdr_act => '0', xdr_rdy => '1', xdr_rph => '1', xdr_wph => '0'),
		(xdr_state => DDRS_WRITE_BL, xdr_state_n => DDRS_WRITE_CL,
		 xdr_cmi => xdr_dcare, xdr_cmo => xdr_nop, xdr_lat => to_timer(xdr_cwl(std), lat_length),
--		 xdr_cmi => xdr_dcare, xdr_cmo => xdr_nop, xdr_lat => to_timer(tWR+1),
--		 xdr_cmi => xdr_dcare, xdr_cmo => xdr_nop, xdr_lat => to_timer(tWR+ddr2_ph_cas(to_integer(unsigned(xdr_mpu_cl)))),
--		 xdr_cmi => xdr_dcare, xdr_cmo => xdr_nop, xdr_lat => to_timer(tWR+ddr3_ph_cwl(to_integer(unsigned(xdr_mpu_cwl)))),
		 xdr_rea => '0', xdr_wri => '1',
		 xdr_act => '0', xdr_rdy => '0', xdr_rph => '1', xdr_wph => '1'),
		(xdr_state => DDRS_WRITE_CL, xdr_state_n => DDRS_PRE,
		 xdr_cmi => xdr_dcare, xdr_cmo => xdr_pre, xdr_lat => to_timer(tRP, lat_length),
		 xdr_rea => '0', xdr_wri => '0',
		 xdr_act => '1', xdr_rdy => '1', xdr_rph => '1', xdr_wph => '1'));

		attribute fsm_encoding : string;
		attribute fsm_encoding of xdr_state : signal is "compact";
begin

	xdr_mpu_p: process (xdr_mpu_clk)
		variable xdr_act : std_logic;
	begin
		if rising_edge(xdr_mpu_clk) then
			if xdr_mpu_rst='0' then
				assert xdr_state/=(xdr_state'range => '-')
					report "ERROR -------------------->>>>"
					severity failure;
				xdr_mpu_act <= xdr_act;
				if lat_timer(0)='1' then
					xdr_state   <= (others => '-');
					lat_timer   <= (others => '-');
					xdr_mpu_ras <= '-';
					xdr_mpu_cas <= '-';
					xdr_mpu_we  <= '-';
					xdr_rea     <= '-';
					xdr_wri     <= '-';
					xdr_act     := '-';
					xdr_mpu_rph <= '-';
					xdr_mpu_wph <= '-';
					xdr_rdy_ena <= '-';
					for i in xdr_state_tab'range loop
						if xdr_state=xdr_state_tab(i).xdr_state then 
							if xdr_state_tab(i).xdr_cmi=xdr_mpu_cmd or
							   xdr_state_tab(i).xdr_cmi="000" then
								xdr_state   <= xdr_state_tab(i).xdr_state_n;
								lat_timer   <= xdr_state_tab(i).xdr_lat;
								xdr_mpu_ras <= xdr_state_tab(i).xdr_cmo(ras);
								xdr_mpu_cas <= xdr_state_tab(i).xdr_cmo(cas);
								xdr_mpu_we  <= xdr_state_tab(i).xdr_cmo(we);
								xdr_rea     <= xdr_state_tab(i).xdr_rea;
								xdr_wri     <= xdr_state_tab(i).xdr_wri;
								xdr_act     := xdr_state_tab(i).xdr_act;
								xdr_mpu_rph <= xdr_state_tab(i).xdr_rph;
								xdr_mpu_wph <= xdr_state_tab(i).xdr_wph;
								xdr_rdy_ena <= xdr_state_tab(i).xdr_rdy;
								exit;
							end if;
						end if;
					end loop;
				else
					xdr_mpu_ras <= xdr_nop(ras);
					xdr_mpu_cas <= xdr_nop(cas);
					xdr_mpu_we  <= xdr_nop(we);
					lat_timer   <= lat_timer - 1;
				end if;
			else
				xdr_state   <= xdr_state_tab(0).xdr_state_n;
				lat_timer   <= xdr_state_tab(0).xdr_lat;
				xdr_mpu_ras <= xdr_state_tab(0).xdr_cmo(ras);
				xdr_mpu_cas <= xdr_state_tab(0).xdr_cmo(cas);
				xdr_mpu_we  <= xdr_state_tab(0).xdr_cmo(we);
				xdr_rea     <= xdr_state_tab(0).xdr_rea;
				xdr_wri     <= xdr_state_tab(0).xdr_wri;
				xdr_mpu_act <= xdr_state_tab(0).xdr_act;
				xdr_mpu_rph <= xdr_state_tab(0).xdr_rph;
				xdr_mpu_wph <= xdr_state_tab(0).xdr_wph;
				xdr_rdy_ena <= '1';
				xdr_act     := '1';
			end if;
		end if;
	end process;

	xdr_mpu_rdy <= lat_timer(0) and xdr_rdy_ena;
	xdr_mpu_rea <= xdr_rea;
	xdr_mpu_wri <= xdr_wri;

	xdr_mpu_wbl <= not xdr_mpu_wph;
--	process (xdr_mpu_clk)
--		variable q : std_logic;
--	begin
--		if rising_edge(xdr_mpu_clk) then
--			q := not xdr_mpu_wph;
--			xdr_mpu_wbl <= q;
--		end if;
--	end process;

	-------------------
	-- Write Enables --
	-------------------

	write_ena_b : block 
	begin
		bytes_g: for i in xdr_mpu_dqs'range generate
			signal ph_wri : std_logic_vector(0 to 4*n+9);
		begin
			xdr_ph_write : entity hdl4fpga.xdr_ph(slr)
			generic map (
				n => n)
			port map (
				xdr_ph_clk   => xdr_mpu_clk,
				xdr_ph_clk90 => xdr_mpu_clk90,
				xdr_ph_din(0) => xdr_mpu_wph,
				xdr_ph_din(1 to 4*n+3*3) => xdr_ph_din,
				xdr_ph_qout => ph_wri);

			ddr1_g : if std=1 generate
				xdr_mpu_dqsz(i) <= ph_wri(4*1) and ph_wri(4*(1+1)-2); -- same phases as dqs
				xdr_mpu_dqs(i) <= not ph_wri(4+2);
				xdr_mpu_dqz(i) <= ph_wri(4+1);
				xdr_mpu_dwr(data_bytes*i+r) <= not ph_wri(4+2-1);
				xdr_mpu_dwr(data_bytes*i+f) <= not ph_wri(4+2+1);
			end generate;

			ddr2_g : if std=2 generate
				xdr_mpu_dqsz(i) <= 
					  ph_wri(4*0+4*(ddr2_ph_cas(to_integer(unsigned(xdr_mpu_cl)))-1)-4) and
					  ph_wri(4*1+4*(ddr2_ph_cas(to_integer(unsigned(xdr_mpu_cl)))-1));
				xdr_mpu_dqs(i) <= not ph_wri(4*ddr2_ph_cas(to_integer(unsigned(xdr_mpu_cl)))-2);
				xdr_mpu_dqz(i) <= ph_wri(4*(ddr2_ph_cas(to_integer(unsigned(xdr_mpu_cl)))-1)+1);
				xdr_mpu_dwr(data_bytes*i+r) <= not ph_wri(4*(ddr2_ph_cas(to_integer(unsigned(xdr_mpu_cl)))-1)+2-1-4);
				xdr_mpu_dwr(data_bytes*i+f) <= not ph_wri(4*(ddr2_ph_cas(to_integer(unsigned(xdr_mpu_cl)))-1)+2+1-4);
			end generate;

			ddr3_g : if std=3 generate
				xdr_mpu_dqsz(i) <= 
					  ph_wri(4*0+4*ddr3_ph_cwl(to_integer(unsigned(xdr_mpu_cwl)))-2) and
					  ph_wri(4*1+4*ddr3_ph_cwl(to_integer(unsigned(xdr_mpu_cwl)))-2);
				xdr_mpu_dqs(i) <= 
					ph_wri(4*0+4*ddr3_ph_cwl(to_integer(unsigned(xdr_mpu_cwl)))) and
					ph_wri(4*1+4*ddr3_ph_cwl(to_integer(unsigned(xdr_mpu_cwl))));
				xdr_mpu_dqz(i) <= ph_wri(4*ddr3_ph_cwl(to_integer(unsigned(xdr_mpu_cwl)))+1);
				xdr_mpu_dwr(data_bytes*i+r) <= not ph_wri(4*(ddr3_ph_cwl(to_integer(unsigned(xdr_mpu_cwl)))+1)-1);
				xdr_mpu_dwr(data_bytes*i+f) <= not ph_wri(4*(ddr3_ph_cwl(to_integer(unsigned(xdr_mpu_cwl)))+1)+1);
			end generate;
		end generate;
	end block;
	
	------------------
	-- Read Enables --
	------------------
	
	xdr_ph_read : entity hdl4fpga.xdr_ph(slr)
	generic map (
		n => nr)
	port map (
		xdr_ph_clks  => xdr_mpu_clk,
		xdr_ph_din(0) => xdr_mpu_rph,
		xdr_ph_din(1 to 4*nr+3*3) => xdr_phr_din,
		xdr_ph_qout(0) => ph_rea_dummy,
		xdr_ph_qout(1 to 4*nr+3*3) => ph_rea(1 to 4*nr+3*3));

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
		xdr_mpu_drd(f)  <= not (
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
