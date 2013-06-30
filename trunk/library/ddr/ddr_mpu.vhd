library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ddr_mpu is
	generic (
		std  : positive range 1 to 3 := 3;
		tCk  : natural := 6;
		tRCD : natural := (15+6-1)/6;
		tRFC : natural := (72+6-1)/6;
		tWR  : natural := (15+6-1)/6;
		tRP  : natural := (15+6-1)/6;
		ddr_mpu_bl : std_logic_vector(0 to 2) := "000";
		ddr_mpu_cl : std_logic_vector(0 to 2) := "010";
		ddr_mpu_cwl : std_logic_vector(0 to 2) := "010");
	port (
		ddr_mpu_rst   : in  std_logic;
		ddr_mpu_clk   : in  std_logic;
		ddr_mpu_clk90 : in  std_logic;
		ddr_mpu_cmd   : in  std_logic_vector(0 to 2) := (others => '1');
		ddr_mpu_rdy   : out std_logic;
		ddr_mpu_act   : out std_logic;
		ddr_mpu_cas   : out std_logic := '1';
		ddr_mpu_ras   : out std_logic := '1';
		ddr_mpu_we    : out std_logic := '1';


		ddr_mpu_rea   : out std_logic := '0';
		ddr_mpu_wri   : out std_logic := '0';
		ddr_mpu_wbl   : out std_logic := '0';

		ddr_mpu_rwin  : out std_logic := '0';
		ddr_mpu_drr   : out std_logic := '0';
		ddr_mpu_drf   : out std_logic := '0';

		ddr_mpu_dwf   : out std_logic_vector(0 to 1) := (others => '0');
		ddr_mpu_dwr   : out std_logic_vector(0 to 1) := (others => '0');
		ddr_mpu_dqs   : out std_logic_vector(0 to 1) := (others => '0');
		ddr_mpu_dqsz  : out std_logic_vector(0 to 1) := (others => '1');
		ddr_mpu_dqz   : out std_logic_vector(0 to 1) := (others => '1'));
end;

library hdl4fpga;

architecture arch of ddr_mpu is
	constant ras : natural := 0;
	constant cas : natural := 1;
	constant we  : natural := 2;
	constant n   : natural := 8;
	constant nr  : natural := 8;

	signal ddr_mpu_rph : std_logic := '1';
	signal ddr_mpu_wph : std_logic := '1';
	signal ph_rea : std_logic_vector(0 to 4*nr+9);
	signal ph_rea_dummy : std_logic;

	signal lat_timer : unsigned(0 to 9) := (others => '1');
	function to_timer (
		constant t : integer) 
		return unsigned is
	begin
		return to_unsigned(
			(2**lat_timer'length-2+t) mod 2**lat_timer'length,
			lat_timer'length);
	end;

	signal sel_cl : std_logic;
	signal ddr_rea : std_logic;
	signal ddr_wri : std_logic;

	type lattimer_vector is array (natural range <>) of std_logic_vector(0 to lat_timer'length-1);
	constant bl_data : lattimer_vector(0 to 4-1) := (
		std_logic_vector(to_timer(1)),
		std_logic_vector(to_timer(2)),
		std_logic_vector(to_timer(4)),
		std_logic_vector(to_timer(8)));

	constant cl1_data : lattimer_vector(0 to 8-1) := (
		2 => std_logic_vector(to_timer(2)),
		3 => std_logic_vector(to_timer(3)),
		6 => std_logic_vector(to_timer(3)),
		others => (others => '-'));

	constant cl3_data : lattimer_vector(0 to 8-1) := (
		(others => '-'),
		std_logic_vector(to_timer(5)),
		std_logic_vector(to_timer(6)),
		std_logic_vector(to_timer(7)),
		std_logic_vector(to_timer(8)),
		std_logic_vector(to_timer(9)),
		std_logic_vector(to_timer(10)),
		std_logic_vector(to_timer(11)));

	constant ddr_phr_din : std_logic_vector(1 to 4*nr+3*3) := (others => '-');
	constant ddr_ph_din : std_logic_vector(1 to 4*n+3*3) := (others => '-');

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

	function ddr_cwl(
		std : positive range 1 to 3)
		return natural is
	begin
		case std is
		when 1 =>
			return tWR+1;
		when 2 =>
			return tWR+ddr2_ph_cas(to_integer(unsigned(ddr_mpu_cl)));
		when 3 =>
			return tWR+ddr3_ph_cwl(to_integer(unsigned(ddr_mpu_cwl)));
		end case;
	end;

--		 ddr_cmi => ddr_dcare, ddr_cmo => ddr_nop, ddr_lat => to_timer(tWR+1),
	constant ddr_nop   : std_logic_vector(0 to 2) := "111";
	constant ddr_act   : std_logic_vector(0 to 2) := "011";
	constant ddr_read  : std_logic_vector(0 to 2) := "101";
	constant ddr_write : std_logic_vector(0 to 2) := "100";
	constant ddr_pre   : std_logic_vector(0 to 2) := "010";
	constant ddr_aut   : std_logic_vector(0 to 2) := "001";
	constant ddr_dcare : std_logic_vector(0 to 2) := "000";

	constant ddrs_act      : std_logic_vector(0 to 2) := "011";
	constant ddrs_read_bl  : std_logic_vector(0 to 2) := "101";
	constant ddrs_read_cl  : std_logic_vector(0 to 2) := "001";
	constant ddrs_write_bl : std_logic_vector(0 to 2) := "100";
	constant ddrs_write_cl : std_logic_vector(0 to 2) := "000";
	constant ddrs_pre      : std_logic_vector(0 to 2) := "010";
	signal ddr_state : std_logic_vector(0 to 2);

	type ddr_state_word is record
		ddr_state : std_logic_vector(0 to 2);
		ddr_state_n : std_logic_vector(0 to 2);
		ddr_cmi : std_logic_vector(0 to 2);
		ddr_cmo : std_logic_vector(0 to 2);
		ddr_lat : unsigned(lat_timer'range);
		ddr_rea : std_logic;
		ddr_wri : std_logic;
		ddr_act : std_logic;
		ddr_rph : std_logic;
		ddr_wph : std_logic;
		ddr_rdy : std_logic;
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

	signal ddr_rdy_ena : std_logic;

--	constant bl_time : std_logic_vector(lat_timer'range) := bl_data(to_integer(unsigned(ddr_mpu_bl)));
	constant bl_time : std_logic_vector(lat_timer'range) := bl_data(2); --to_integer(unsigned(ddr_mpu_bl)));
--	constant cl_time : std_logic_vector(lat_timer'range) := cl_data(natural'(setif(ddr_mpu_cl(0)='1' and ddr_mpu_cl(2)='1')));
	constant cl_time : std_logic_vector(lat_timer'range) := cl3_data(to_integer(unsigned(ddr_mpu_cl)));
	type ddr_state_vector is array(natural range <>) of ddr_state_word;
	constant ddr_state_tab : ddr_state_vector(0 to 11-1) := (

		-------------
		-- DDR_PRE --
		-------------

		(ddr_state => DDRS_PRE, ddr_state_n => DDRS_PRE,
		 ddr_cmi => ddr_nop, ddr_cmo => ddr_nop, ddr_lat => to_timer(1),
		 ddr_rea => '0', ddr_wri => '0',
		 ddr_act => '1', ddr_rdy => '1', ddr_rph => '1', ddr_wph => '1'),
		(ddr_state => DDRS_PRE, ddr_state_n => DDRS_ACT,
		 ddr_cmi => ddr_act, ddr_cmo => ddr_act, ddr_lat => to_timer(tRCD),
		 ddr_rea => '0', ddr_wri => '0',
		 ddr_act => '0', ddr_rdy => '1', ddr_rph => '1', ddr_wph => '1'),
		(ddr_state => DDRS_PRE, ddr_state_n => DDRS_PRE,
		 ddr_cmi => ddr_aut, ddr_cmo => ddr_aut, ddr_lat => to_timer(tRFC),
		 ddr_rea => '0', ddr_wri => '0',
		 ddr_act => '1', ddr_rdy => '1', ddr_rph => '1', ddr_wph => '1'),

		-------------
		-- DDR_ACT --
		-------------

		(ddr_state => DDRS_ACT, ddr_state_n => DDRS_READ_BL,
		 ddr_cmi => ddr_read, ddr_cmo => ddr_read, ddr_lat => unsigned(bl_time),
		 ddr_rea => '1', ddr_wri => '0',
		 ddr_act => '0', ddr_rdy => '1', ddr_rph => '0', ddr_wph => '1'),
		(ddr_state => DDRS_ACT, ddr_state_n => DDRS_WRITE_BL,
		 ddr_cmi => ddr_write, ddr_cmo => ddr_write, ddr_lat => unsigned(bl_time),
		 ddr_rea => '0', ddr_wri => '1',
		 ddr_act => '0', ddr_rdy => '1', ddr_rph => '1', ddr_wph => '0'),

		--------------
		-- DDR_READ --
		--------------

		(ddr_state => DDRS_READ_BL, ddr_state_n => DDRS_READ_BL,
		 ddr_cmi => ddr_read, ddr_cmo => ddr_read, ddr_lat => unsigned(bl_time),
		 ddr_rea => '1', ddr_wri => '0',
		 ddr_act => '0', ddr_rdy => '1', ddr_rph => '0', ddr_wph => '1'),
		(ddr_state => DDRS_READ_BL, ddr_state_n => DDRS_READ_CL,
		 ddr_cmi => ddr_dcare, ddr_cmo => ddr_nop, ddr_lat => unsigned(cl_time),
		 ddr_rea => '1', ddr_wri => '0',
		 ddr_act => '0', ddr_rdy => '0', ddr_rph => '1', ddr_wph => '1'),
		(ddr_state => DDRS_READ_CL, ddr_state_n => DDRS_PRE,
		 ddr_cmi => ddr_dcare, ddr_cmo => ddr_pre, ddr_lat => to_timer(tRP),
		 ddr_rea => '1', ddr_wri => '0',
		 ddr_act => '1', ddr_rdy => '1', ddr_rph => '1', ddr_wph => '1'),

		---------------
		-- DDR_WRITE --
		---------------

		(ddr_state => DDRS_WRITE_BL, ddr_state_n => DDRS_WRITE_BL,
		 ddr_cmi => ddr_write, ddr_cmo => ddr_write, ddr_lat => unsigned(bl_time),
		 ddr_rea => '0', ddr_wri => '1',
		 ddr_act => '0', ddr_rdy => '1', ddr_rph => '1', ddr_wph => '0'),
		(ddr_state => DDRS_WRITE_BL, ddr_state_n => DDRS_WRITE_CL,
		 ddr_cmi => ddr_dcare, ddr_cmo => ddr_nop, ddr_lat => to_timer(ddr_cwl(std)),
--		 ddr_cmi => ddr_dcare, ddr_cmo => ddr_nop, ddr_lat => to_timer(tWR+1),
--		 ddr_cmi => ddr_dcare, ddr_cmo => ddr_nop, ddr_lat => to_timer(tWR+ddr2_ph_cas(to_integer(unsigned(ddr_mpu_cl)))),
--		 ddr_cmi => ddr_dcare, ddr_cmo => ddr_nop, ddr_lat => to_timer(tWR+ddr3_ph_cwl(to_integer(unsigned(ddr_mpu_cwl)))),
		 ddr_rea => '0', ddr_wri => '1',
		 ddr_act => '0', ddr_rdy => '0', ddr_rph => '1', ddr_wph => '1'),
		(ddr_state => DDRS_WRITE_CL, ddr_state_n => DDRS_PRE,
		 ddr_cmi => ddr_dcare, ddr_cmo => ddr_pre, ddr_lat => to_timer(tRP),
		 ddr_rea => '0', ddr_wri => '0',
		 ddr_act => '1', ddr_rdy => '1', ddr_rph => '1', ddr_wph => '1'));

begin

--	process 
--		variable msg : line;
--	begin 
--		write (msg, std_logic_vector(ddr_state_tab(9).ddr_lat));
----		write (msg, twr+ddr3_ph_cwl(to_integer(unsigned(ddr_mpu_cwl))));
--		writeline (output, msg);
--		wait;
--	end process;

	ddr_mpu_p: process (ddr_mpu_clk)
		variable ddr_act : std_logic;
	begin
		if rising_edge(ddr_mpu_clk) then
			if ddr_mpu_rst='0' then
				assert ddr_state/=(ddr_state'range => '-')
					report "ERROR -------------------->>>>"
					severity failure;
				ddr_mpu_act <= ddr_act;
				if lat_timer(0)='1' then
					ddr_state   <= (others => '-');
					lat_timer   <= (others => '-');
					ddr_mpu_ras <= '-';
					ddr_mpu_cas <= '-';
					ddr_mpu_we  <= '-';
					ddr_rea     <= '-';
					ddr_wri     <= '-';
					ddr_act     := '-';
					ddr_mpu_rph <= '-';
					ddr_mpu_wph <= '-';
					ddr_rdy_ena <= '-';
					for i in ddr_state_tab'range loop
						if ddr_state=ddr_state_tab(i).ddr_state then 
							if ddr_state_tab(i).ddr_cmi=ddr_mpu_cmd or
							   ddr_state_tab(i).ddr_cmi="000" then
								ddr_state   <= ddr_state_tab(i).ddr_state_n;
								lat_timer   <= ddr_state_tab(i).ddr_lat;
								ddr_mpu_ras <= ddr_state_tab(i).ddr_cmo(ras);
								ddr_mpu_cas <= ddr_state_tab(i).ddr_cmo(cas);
								ddr_mpu_we  <= ddr_state_tab(i).ddr_cmo(we);
								ddr_rea     <= ddr_state_tab(i).ddr_rea;
								ddr_wri     <= ddr_state_tab(i).ddr_wri;
								ddr_act     := ddr_state_tab(i).ddr_act;
								ddr_mpu_rph <= ddr_state_tab(i).ddr_rph;
								ddr_mpu_wph <= ddr_state_tab(i).ddr_wph;
								ddr_rdy_ena <= ddr_state_tab(i).ddr_rdy;
								exit;
							end if;
						end if;
					end loop;
				else
					ddr_mpu_ras <= ddr_nop(ras);
					ddr_mpu_cas <= ddr_nop(cas);
					ddr_mpu_we  <= ddr_nop(we);
					lat_timer   <= lat_timer - 1;
				end if;
			else
				ddr_state   <= ddr_state_tab(0).ddr_state_n;
				lat_timer   <= ddr_state_tab(0).ddr_lat;
				ddr_mpu_ras <= ddr_state_tab(0).ddr_cmo(ras);
				ddr_mpu_cas <= ddr_state_tab(0).ddr_cmo(cas);
				ddr_mpu_we  <= ddr_state_tab(0).ddr_cmo(we);
				ddr_rea     <= ddr_state_tab(0).ddr_rea;
				ddr_wri     <= ddr_state_tab(0).ddr_wri;
				ddr_mpu_act <= ddr_state_tab(0).ddr_act;
				ddr_mpu_rph <= ddr_state_tab(0).ddr_rph;
				ddr_mpu_wph <= ddr_state_tab(0).ddr_wph;
				ddr_rdy_ena <= '1';
				ddr_act     := '1';
			end if;
		end if;
	end process;

	ddr_mpu_rdy <= lat_timer(0) and ddr_rdy_ena;
	ddr_mpu_rea <= ddr_rea;
	ddr_mpu_wri <= ddr_wri;
	ddr_mpu_wbl <= not ddr_mpu_wph;

	-------------------
	-- Write Enables --
	-------------------

	write_ena_b : block 
	begin
		bytes_g: for i in ddr_mpu_dqs'range generate
			signal ph_wri : std_logic_vector(0 to 4*n+9);
		begin
			ddr_ph_write : entity hdl4fpga.ddr_ph
			generic map (
				n => n)
			port map (
				ddr_ph_clk   => ddr_mpu_clk,
				ddr_ph_clk90 => ddr_mpu_clk90,
				ddr_ph_din(0) => ddr_mpu_wph,
				ddr_ph_din(1 to 4*n+3*3) => ddr_ph_din,
				ddr_ph_qout => ph_wri);

			ddr1_g : if std=1 generate
				ddr_mpu_dqsz(i) <= ph_wri(4*1) and ph_wri(4*(1+1)-2); -- same phases as dqs
				ddr_mpu_dqs(i)  <= not ph_wri(4+2);
				ddr_mpu_dqz(i)  <= ph_wri(4+1);
				ddr_mpu_dwr(i)  <= not ph_wri(4+2-1);
				ddr_mpu_dwf(i)  <= not ph_wri(4+2+1);
			end generate;

			ddr2_g : if std=2 generate
				ddr_mpu_dqsz(i) <= 
					  ph_wri(4*0+4*(ddr2_ph_cas(to_integer(unsigned(ddr_mpu_cl)))-1)-2) and
					  ph_wri(4*1+4*(ddr2_ph_cas(to_integer(unsigned(ddr_mpu_cl)))-1)-2);
				ddr_mpu_dqs(i)  <= not ph_wri(4*ddr2_ph_cas(to_integer(unsigned(ddr_mpu_cl)))-2);
				ddr_mpu_dqz(i)  <= ph_wri(4*(ddr2_ph_cas(to_integer(unsigned(ddr_mpu_cl)))-1)+1);
				ddr_mpu_dwr(i)  <= not ph_wri(4*(ddr2_ph_cas(to_integer(unsigned(ddr_mpu_cl)))-1)+2-1);
				ddr_mpu_dwf(i)  <= not ph_wri(4*(ddr2_ph_cas(to_integer(unsigned(ddr_mpu_cl)))-1)+2+1);
			end generate;

			ddr3_g : if std=3 generate
				ddr_mpu_dqsz(i) <= 
					  ph_wri(4*0+4*ddr3_ph_cwl(to_integer(unsigned(ddr_mpu_cwl)))-2) and
					  ph_wri(4*1+4*ddr3_ph_cwl(to_integer(unsigned(ddr_mpu_cwl)))-2);
				ddr_mpu_dqs(i)  <= 
					ph_wri(4*0+4*ddr3_ph_cwl(to_integer(unsigned(ddr_mpu_cwl)))) and
					ph_wri(4*1+4*ddr3_ph_cwl(to_integer(unsigned(ddr_mpu_cwl))));
				ddr_mpu_dqz(i)  <= ph_wri(4*ddr3_ph_cwl(to_integer(unsigned(ddr_mpu_cwl)))+1);
				ddr_mpu_dwr(i)  <= not ph_wri(4*(ddr3_ph_cwl(to_integer(unsigned(ddr_mpu_cwl)))+1)-1);
				ddr_mpu_dwf(i)  <= not ph_wri(4*(ddr3_ph_cwl(to_integer(unsigned(ddr_mpu_cwl)))+1)+1);
			end generate;
		end generate;
	end block;
	
	------------------
	-- Read Enables --
	------------------
	
	ddr_ph_read : entity hdl4fpga.ddr_ph
	generic map (
		n => nr)
	port map (
		ddr_ph_clk   => ddr_mpu_clk,
		ddr_ph_clk90 => ddr_mpu_clk90,
		ddr_ph_din(0) => ddr_mpu_rph,
		ddr_ph_din(1 to 4*nr+3*3) => ddr_phr_din,
		ddr_ph_qout(0) => ph_rea_dummy,
		ddr_ph_qout(1 to 4*nr+3*3) => ph_rea(1 to 4*nr+3*3));

----	ddr_mpu_rwin <= not ph_rea(4*4+4*((ddr_ph_cas(ddr_mpu_cl)+3)/4));
----	ddr_mpu_drr  <= not (ph_rea(2*4+ddr_ph_cas(ddr_mpu_cl)) and ph_rea(3*4+ddr_ph_cas(ddr_mpu_cl)));
----	ddr_mpu_drf  <= not ph_rea(2*4+2+ddr_ph_cas(ddr_mpu_cl));

	ddr1_g : if std=1 generate
		ddr_mpu_rwin <= not ph_rea(4*2+4*((ddr1_ph_4cas(to_integer(unsigned(ddr_mpu_cl)))+3)/4));
		ddr_mpu_drr  <= not (
			ph_rea(ddr1_ph_4cas(to_integer(unsigned(ddr_mpu_cl)))) and
			ph_rea(4*1+ddr1_ph_4cas(to_integer(unsigned(ddr_mpu_cl)))));
		ddr_mpu_drf  <= not ph_rea(ddr1_ph_4cas(to_integer(unsigned(ddr_mpu_cl))));
	end generate;

--	ddr2_g : if std=2 generate
--		ddr_mpu_rwin <= not ph_rea(4*2+4*((ddr2_ph_cas(to_integer(unsigned(ddr_mpu_cl)))+3)/4));
--		ddr_mpu_drr  <= not (
--			ph_rea(ddr1_ph_4cas(to_integer(unsigned(ddr_mpu_cl)))) and
--			ph_rea(4*1+ddr1_ph_4cas(to_integer(unsigned(ddr_mpu_cl)))));
--		ddr_mpu_drf  <= not ph_rea(ddr1_ph_4cas(to_integer(unsigned(ddr_mpu_cl))));
--	end generate;

	ddr3_g : if std=3 generate
		ddr_mpu_rwin <= not ph_rea(4*2+4*((ddr3_ph_cas(to_integer(unsigned(ddr_mpu_cl)))+3)/4));
		ddr_mpu_drr  <= not (
			ph_rea(ddr3_ph_cas(to_integer(unsigned(ddr_mpu_cl)))) and 
			ph_rea(4*1+ddr3_ph_cas(to_integer(unsigned(ddr_mpu_cl)))));
		ddr_mpu_drf  <= not ph_rea(4*ddr3_ph_cas(to_integer(unsigned(ddr_mpu_cl)))+2);
	end generate;
end;
