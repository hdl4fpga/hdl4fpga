use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.xdr_param.all;

entity xdr_wlp is
	port (
		xdr_wlp_clk : in  std_logic;
		xdr_wlp_req : in  std_logic;
		xdr_wlp_rdy : out std_logic;
		xdr_wlp_cke : out std_logic;
		xdr_wlp_cs  : out std_logic;
		xdr_wlp_ras : out std_logic;
		xdr_wlp_cas : out std_logic;
		xdr_wlp_we  : out std_logic;
		xdr_wlp_odt : out std_logic;
		xdr_wlp_b   : out std_logic_vector);

end;

architecture ddr3 of xdr_wlp is

	constant lat_size : natural := unsigned_num_bits(max(natural_vector'(0 => lRCD, 1 => lRFC, 2 => lWR, 3 => lRP) & bl_tab & cl_tab & cwl_tab));
	signal lat_timer : signed(0 to lat_size-1) := (others => '1');

	type xdr_state_word is record
		xdr_state : std_logic_vector(0 to 2);
		xdr_state_n : std_logic_vector(0 to 2);
		xdr_cmdi : std_logic_vector(0 to 3);
		xdr_cmdo : std_logic_vector(0 to 3);
		xdr_odt : std_logic;
		xdr_lat : lat_id;
		xdr_rea : std_logic;
		xdr_wri : std_logic;
		xdr_rph : std_logic;
		xdr_wph : std_logic;
		xdr_rdy : std_logic;
	end record;

	signal xdr_wlp_pc : unsigned(0 to unsigned_num_bits(pgm'length-1));

	constant xdr_state_tab : xdr_state_vector(0 to 12-1) := (
		(xdr_state => WLS_MRS, xdr_state_n => WLS_WLDQSEN,
		 xdr_cmi => xdr_pre, xdr_cmo => xdr_pre, xdr_lat => ID_MOD,),

		(xdr_state => WLS_WLDQSEN, xdr_state_n => WLS_WLMRD,
		 xdr_cmi => xdr_pre, xdr_cmo => xdr_pre, xdr_lat => ID_WLDQSEN,),

		(xdr_state => WLS_WLMRD, xdr_state_n => WLS_WLO,
		 xdr_cmi => xdr_pre, xdr_cmo => xdr_pre, xdr_lat => ID_WLMRD,),

		(xdr_state => WLS_WLO, xdr_state_n => WLS_WLO,
		 xdr_cmi => xdr_pre, xdr_cmo => xdr_pre, xdr_lat => ID_WLO,),

		(xdr_state => WLS_WLO, xdr_state_n => WLS_TA,
		 xdr_cmi => xdr_pre, xdr_cmo => xdr_pre, xdr_lat => ID_WLMRD,),

		(xdr_state => WLS_TA, xdr_state_n => WLS_TB,
		 xdr_cmi => xdr_pre, xdr_cmo => xdr_pre, xdr_lat => ID_WLMRD,),

		(xdr_state => WLS_TB, xdr_state_n => WLS_TC,
		 xdr_cmi => xdr_pre, xdr_cmo => xdr_pre, xdr_lat => ID_WLMRD,),

		(xdr_state => WLS_TC, xdr_state_n => WLS_TD,
		 xdr_cmi => xdr_pre, xdr_cmo => xdr_pre, xdr_lat => ID_WLMRD,),

begin

end;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity xdr_mpu is
	generic (
		lRCD : natural;
		lRFC : natural;
		lWR  : natural;
		lRP  : natural;

		bl_cod : std_logic_vector;
		bl_tab : natural_vector;

		cl_cod : std_logic_vector;
		cl_tab : natural_vector;

		cwl_cod : std_logic_vector;
		cwl_tab : natural_vector);
	port (
		xdr_mpu_bl  : in std_logic_vector;
		xdr_mpu_cl  : in std_logic_vector;
		xdr_mpu_cwl : in std_logic_vector;

		xdr_mpu_rst : in std_logic;
		xdr_mpu_clk : in std_logic;
		xdr_mpu_cmd : in std_logic_vector(0 to 2) := (others => '1');
		xdr_mpu_rdy : out std_logic;
		xdr_mpu_act : out std_logic;
		xdr_mpu_cas : out std_logic;
		xdr_mpu_ras : out std_logic;
		xdr_mpu_we  : out std_logic;
		xdr_mpu_cen : out std_logic;

		xdr_mpu_rea  : out std_logic;
		xdr_mpu_rwin : out std_logic;
		xdr_mpu_wri  : out std_logic;
		xdr_mpu_wwin : out std_logic);

end;

architecture arch of xdr_mpu is
	constant ras : natural := 0;
	constant cas : natural := 1;
	constant we  : natural := 2;


	signal xdr_rea : std_logic;
	signal xdr_wri : std_logic;

	constant xdr_nop   : std_logic_vector(0 to 2) := "111";
	constant xdr_act   : std_logic_vector(0 to 2) := "011";
	constant xdr_read  : std_logic_vector(0 to 2) := "101";
	constant xdr_write : std_logic_vector(0 to 2) := "100";
	constant xdr_pre   : std_logic_vector(0 to 2) := "010";
	constant xdr_aut   : std_logic_vector(0 to 2) := "001";
	constant xdr_dcare : std_logic_vector(0 to 2) := "000";

	constant xdrs_act      : std_logic_vector(0 to 2) := "011";
	constant xdrs_read_bl  : std_logic_vector(0 to 2) := "101";
	constant xdrs_read_cl  : std_logic_vector(0 to 2) := "001";
	constant xdrs_write_bl : std_logic_vector(0 to 2) := "100";
	constant xdrs_write_cl : std_logic_vector(0 to 2) := "000";
	constant xdrs_pre      : std_logic_vector(0 to 2) := "010";
	signal xdr_state : std_logic_vector(0 to 2);

	type lat_id is (ID_IDLE, ID_RCD, ID_RFC, ID_RP, ID_BL, ID_CL, ID_CWL);
	type xdr_state_word is record
		xdr_state : std_logic_vector(0 to 2);
		xdr_state_n : std_logic_vector(0 to 2);
		xdr_cmi : std_logic_vector(0 to 2);
		xdr_cmo : std_logic_vector(0 to 2);
		xdr_lat : lat_id;
		xdr_cen : std_logic;
		xdr_rea : std_logic;
		xdr_wri : std_logic;
		xdr_act : std_logic;
		xdr_rph : std_logic;
		xdr_wph : std_logic;
		xdr_rdy : std_logic;
	end record;

	signal xdr_rdy_ena : std_logic;

	type xdr_state_vector is array(natural range <>) of xdr_state_word;
	constant xdr_state_tab : xdr_state_vector(0 to 12-1) := (

		-------------
		-- DDR_PRE --
		-------------

		(xdr_state => XDRS_PRE, xdr_state_n => XDRS_PRE,
		 xdr_cmi => xdr_pre, xdr_cmo => xdr_pre, xdr_lat => ID_RP,
		 xdr_rea => '0', xdr_wri => '0', xdr_cen => '0',
		 xdr_act => '1', xdr_rdy => '1', xdr_rph => '0', xdr_wph => '0'),
		(xdr_state => XDRS_PRE, xdr_state_n => XDRS_PRE,
		 xdr_cmi => xdr_nop, xdr_cmo => xdr_nop, xdr_lat => ID_IDLE,
		 xdr_rea => '0', xdr_wri => '0', xdr_cen => '0',
		 xdr_act => '1', xdr_rdy => '1', xdr_rph => '0', xdr_wph => '0'),
		(xdr_state => XDRS_PRE, xdr_state_n => XDRS_ACT,
		 xdr_cmi => xdr_act, xdr_cmo => xdr_act, xdr_lat => ID_RCD,
		 xdr_rea => '0', xdr_wri => '0', xdr_cen => '0',
		 xdr_act => '0', xdr_rdy => '1', xdr_rph => '0', xdr_wph => '0'),
		(xdr_state => XDRS_PRE, xdr_state_n => XDRS_PRE,
		 xdr_cmi => xdr_aut, xdr_cmo => xdr_aut, xdr_lat => ID_RFC,
		 xdr_rea => '0', xdr_wri => '0', xdr_cen => '0',
		 xdr_act => '1', xdr_rdy => '1', xdr_rph => '0', xdr_wph => '0'),

		-------------
		-- DDR_ACT --
		-------------

		(xdr_state => XDRS_ACT, xdr_state_n => XDRS_READ_BL,
		 xdr_cmi => xdr_read, xdr_cmo => xdr_read, xdr_lat => ID_BL,
		 xdr_rea => '1', xdr_wri => '0', xdr_cen => '1',
		 xdr_act => '0', xdr_rdy => '1', xdr_rph => '1', xdr_wph => '0'),
		(xdr_state => XDRS_ACT, xdr_state_n => XDRS_WRITE_BL,
		 xdr_cmi => xdr_write, xdr_cmo => xdr_write, xdr_lat => ID_BL,
		 xdr_rea => '0', xdr_wri => '1', xdr_cen => '1',
		 xdr_act => '0', xdr_rdy => '1', xdr_rph => '0', xdr_wph => '1'),

		--------------
		-- DDR_READ --
		--------------

		(xdr_state => XDRS_READ_BL, xdr_state_n => XDRS_READ_BL,
		 xdr_cmi => xdr_read, xdr_cmo => xdr_read, xdr_lat => ID_BL,
		 xdr_rea => '1', xdr_wri => '0', xdr_cen => '1',
		 xdr_act => '0', xdr_rdy => '1', xdr_rph => '1', xdr_wph => '0'),
		(xdr_state => XDRS_READ_BL, xdr_state_n => XDRS_READ_CL,
		 xdr_cmi => xdr_dcare, xdr_cmo => xdr_nop, xdr_lat => ID_CL,
		 xdr_rea => '1', xdr_wri => '0', xdr_cen => '0',
		 xdr_act => '0', xdr_rdy => '0', xdr_rph => '0', xdr_wph => '0'),
		(xdr_state => XDRS_READ_CL, xdr_state_n => XDRS_PRE,
		 xdr_cmi => xdr_dcare, xdr_cmo => xdr_pre, xdr_lat => ID_RP,
		 xdr_rea => '1', xdr_wri => '0', xdr_cen => '0',
		 xdr_act => '1', xdr_rdy => '1', xdr_rph => '0', xdr_wph => '0'),

		---------------
		-- DDR_WRITE --
		---------------

		(xdr_state => XDRS_WRITE_BL, xdr_state_n => XDRS_WRITE_BL,
		 xdr_cmi => xdr_write, xdr_cmo => xdr_write, xdr_lat => ID_BL,
		 xdr_rea => '0', xdr_wri => '1', xdr_cen => '1',
		 xdr_act => '0', xdr_rdy => '1', xdr_rph => '0', xdr_wph => '1'),
		(xdr_state => XDRS_WRITE_BL, xdr_state_n => XDRS_WRITE_CL,
		 xdr_cmi => xdr_dcare, xdr_cmo => xdr_nop, xdr_lat => ID_CWL,
		 xdr_rea => '0', xdr_wri => '1', xdr_cen => '0',
		 xdr_act => '0', xdr_rdy => '0', xdr_rph => '0', xdr_wph => '0'),
		(xdr_state => XDRS_WRITE_CL, xdr_state_n => XDRS_PRE,
		 xdr_cmi => xdr_dcare, xdr_cmo => xdr_pre, xdr_lat => ID_RP,
		 xdr_rea => '0', xdr_wri => '0', xdr_cen => '0',
		 xdr_act => '1', xdr_rdy => '1', xdr_rph => '0', xdr_wph => '0'));

		attribute fsm_encoding : string;
		attribute fsm_encoding of xdr_state : signal is "compact";

	function "+" (
		constant tab : natural_vector;
		constant off : natural)
		return natural_vector is
		variable val : natural_vector(tab'range);
	begin
		for i in tab'range loop
			val(i) := tab(i) + off;
		end loop;
		return val;
	end;

	impure function select_lat (
		constant lat_val : std_logic_vector;
		constant lat_cod : std_logic_vector;
		constant lat_tab : natural_vector)
		return signed is
		subtype latword is std_logic_vector(0 to lat_cod'length/lat_tab'length-1);
		type latword_vector is array (natural range <>) of latword;

		function to_latwordvector(
			constant arg : std_logic_vector)
			return latword_vector is
			variable aux : std_logic_vector(0 to arg'length-1) := arg;
			variable val : latword_vector(0 to arg'length/latword'length-1);
		begin
			for i in val'range loop
				val(i) := aux(latword'range);
				aux := aux sll latword'length;
			end loop;
			return val;
		end;

		impure function select_latword (
			constant lat_val : std_logic_vector;
			constant lat_cod : latword_vector;
			constant lat_tab : natural_vector)
			return signed is
			variable val : signed(lat_timer'range);
		begin
			val := (others => '-');
			for i in lat_cod'range loop
				if lat_cod(i)=lat_val then
					val := to_signed(lat_tab(i)-2, lat_timer'length);
					exit;
				end if;
			end loop;
			return val;
		end;
			
	begin
		return select_latword(lat_val, to_latwordvector(lat_cod), lat_tab);
	end;

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
					xdr_state <= (others => '-');
					lat_timer <= (others => '-');
					xdr_mpu_ras <= '-';
					xdr_mpu_cas <= '-';
					xdr_mpu_we  <= '-';
					xdr_rea <= '-';
					xdr_wri <= '-';
					xdr_act := '-';
					xdr_mpu_rwin <= '-';
					xdr_mpu_wwin <= '-';
					xdr_rdy_ena <= '-';
					xdr_mpu_cen <= '-';
					for i in xdr_state_tab'range loop
						if xdr_state=xdr_state_tab(i).xdr_state then 
							if xdr_state_tab(i).xdr_cmi=xdr_mpu_cmd or
							   xdr_state_tab(i).xdr_cmi="000" then
								xdr_state <= xdr_state_tab(i).xdr_state_n;
								xdr_mpu_ras <= xdr_state_tab(i).xdr_cmo(ras);
								xdr_mpu_cas <= xdr_state_tab(i).xdr_cmo(cas);
								xdr_mpu_we  <= xdr_state_tab(i).xdr_cmo(we);
								xdr_rea <= xdr_state_tab(i).xdr_rea;
								xdr_wri <= xdr_state_tab(i).xdr_wri;
								xdr_act := xdr_state_tab(i).xdr_act;
								xdr_mpu_cen <= xdr_state_tab(i).xdr_cen;
								xdr_mpu_rwin <= xdr_state_tab(i).xdr_rph;
								xdr_mpu_wwin <= xdr_state_tab(i).xdr_wph;
								xdr_rdy_ena <= xdr_state_tab(i).xdr_rdy;

								case xdr_state_tab(i).xdr_lat is
								when ID_BL =>
									lat_timer <= select_lat(xdr_mpu_bl, bl_cod, bl_tab);
								when ID_CL =>
									lat_timer <= select_lat(xdr_mpu_cl, cl_cod, cl_tab);
								when ID_CWL =>
									lat_timer <= select_lat(xdr_mpu_cwl, cwl_cod, cwl_tab+lWR);
								when ID_RCD =>
									lat_timer <= to_signed(lRCD-2, lat_timer'length);
								when ID_RFC =>
									lat_timer <= to_signed(lRFC-2, lat_timer'length);
								when ID_RP =>
									lat_timer <= to_signed(lRP-2, lat_timer'length);
								when ID_IDLE =>
									lat_timer <= (others => '1');
								end case;
								exit;
							end if;
						end if;
					end loop;
				else
					xdr_mpu_ras <= xdr_nop(ras);
					xdr_mpu_cas <= xdr_nop(cas);
					xdr_mpu_we  <= xdr_nop(we);
					xdr_mpu_cen <= '0';
					lat_timer   <= lat_timer - 1;
				end if;
			else
				xdr_state <= xdr_state_tab(0).xdr_state_n;
				xdr_mpu_ras <= xdr_state_tab(0).xdr_cmo(ras);
				xdr_mpu_cas <= xdr_state_tab(0).xdr_cmo(cas);
				xdr_mpu_we  <= xdr_state_tab(0).xdr_cmo(we);
				xdr_rea <= xdr_state_tab(0).xdr_rea;
				xdr_wri <= xdr_state_tab(0).xdr_wri;
				xdr_act := '1';
				xdr_mpu_act <= xdr_state_tab(0).xdr_act;
				xdr_mpu_cen <= '0';
				xdr_mpu_rwin <= xdr_state_tab(0).xdr_rph;
				xdr_mpu_wwin <= xdr_state_tab(0).xdr_wph;
				xdr_rdy_ena <= '1';
				lat_timer <= (others => '1');
			end if;
		end if;
	end process;

	xdr_mpu_rdy <= lat_timer(0) and xdr_rdy_ena;
	xdr_mpu_rea <= xdr_rea;
	xdr_mpu_wri <= xdr_wri;

end;
