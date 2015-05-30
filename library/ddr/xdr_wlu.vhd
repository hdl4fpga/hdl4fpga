use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.xdr_param.all;

entity xdr_wlu is
	port (
		xdr_wlu_clk : in  std_logic;
		xdr_wlu_req : in  std_logic;
		xdr_wlu_rdy : out std_logic;
		xdr_wlu_stp : in  std_logic;

		xdr_wlu_cke : out std_logic;
		xdr_wlu_cs  : out std_logic;
		xdr_wlu_ras : out std_logic;
		xdr_wlu_cas : out std_logic;
		xdr_wlu_we  : out std_logic;
		xdr_wlu_odt : out std_logic;
		xdr_wlu_b   : out std_logic_vector);

	constant tCLK    : natural := 100;
	constant tMOD    : natural := 10000;
	constant tWLDQSE : natural := 10000;
	constant tWLO    : natural := 1000;
	constant tDQSL   : natural := 4000;
	constant tDQSH   : natural := 1000;
	constant tODTL   : natural := 1000;

end;

architecture ddr3 of xdr_wlu is

	type timer_id is (ID_MOD, ID_WLDQSEN, ID_DQSPRE, ID_DQLHEA, ID_DQSH, ID_DQLTWO, ID_DQSSFX, ID_ODT);
	type lattab is array (timer_id) of natural;

	function to_naturalvector (
		constant arg : lattab)
		return natural_vector is
		variable val : natural_vector(0 to arg'length-1);
	begin
		for i in arg'range loop
			val(timer_id'pos(i)-1) := arg(i);
		end loop;
		return val;
	end;

	constant latdb : lattab := (
		ID_MOD     => round_lat(tMOD,         tCLK)-2,
		ID_WLDQSEN => round_lat(tWLDQSE-tMOD, tCLK)-2,
		ID_DQSPRE  => round_lat(tWLO,         tCLK)-2,
		ID_DQLHEA  => round_lat(tDQSL-tWLO,   tCLK)-2,
		ID_DQSH    => round_lat(tDQSH,        tCLK)-2,
		ID_DQLTWO  => round_lat(tWLO,         tCLK)-2,
		ID_DQSSFX  => round_lat(tDQSL-tWLO,   tCLK)-2,
		ID_ODT     => round_lat(tODTL+tWLO,   tCLK)-2);

	constant lat_size : natural := unsigned_num_bits(max(to_naturalvector(latdb)))+1;
	signal lat_timer : signed(0 to lat_size-1) := (others => '1');

	type wlstate_id is (WSID_MRS, WSID_WLDQSEN, WSID_DQSLPRE, WSID_DQSLHEA, WSID_DQSH, WSID_DQLTWO, WSID_DQSSFX, WSID_ODT, WSID_RDY);
	subtype wls_cod is std_logic_vector(0 to 4-1);

	constant WLS_MRS     : wls_cod := "0000";
	constant WLS_WLDQSEN : wls_cod := "0001"; 
	constant WLS_DQSLPRE : wls_cod := "0011";
	constant WLS_DQSLHEA : wls_cod := "0010";
	constant WLS_DQSH    : wls_cod := "0110";
	constant WLS_DQLTWO  : wls_cod := "0111";
	constant WLS_DQSSFX  : wls_cod := "0101";
	constant WLS_ODT     : wls_cod := "0100";
	constant WLS_RDY     : wls_cod := "1100";

	signal input : std_logic_vector(0 to 0);
	type xdr_state_word is record
		state   : wls_cod;
		state_n : wls_cod;
		mask    : std_logic_vector(input'range);
		input   : std_logic_vector(input'range);
		lat     : timer_id;
		cmd     : ddr3_cmd;
		odt     : std_logic;
		dqs     : std_logic;
	end record;
	type xdr_state_vector is array (natural range <>) of xdr_state_word;

	constant xdr_state_tab : xdr_state_vector(0 to 9-1) := (
--		+------------+--------------+-------+------+-------------+-----------+-----+-----+
--		| xdr_state  | xdr_state_n  | input | mask | xdr_lat     | cmd       | odt | dqs |
--		+------------+--------------+-------+------+-------------+-----------+-----+-----+
		( WLS_MRS,     WLS_WLDQSEN,   "0",    "0",   ID_MOD,       ddr3_mrs,   '0',  '0'),		
		( WLS_WLDQSEN, WLS_DQSLPRE,   "0",    "0",   ID_WLDQSEN,   ddr3_nop,   '1',  '0'),
		( WLS_DQSLPRE, WLS_DQSLHEA,   "0",    "0",   ID_DQSPRE,    ddr3_nop,   '1',  '0'),
                                                                              
		( WLS_DQSLHEA, WLS_DQSH,      "1",    "0",   ID_DQLHEA,    ddr3_nop,   '0',  '0'),
		( WLS_DQSH,    WLS_DQLTWO,    "1",    "0",   ID_DQSH,      ddr3_nop,   '0',  '0'),
		( WLS_DQLTWO,  WLS_DQSLHEA,   "1",    "1",   ID_DQLTWO,    ddr3_nop,   '0',  '1'),
		( WLS_DQLTWO,  WLS_DQSSFX,    "1",    "0",   ID_DQSSFX,    ddr3_nop,   '0',  '1'),
                                                                              
		( WLS_DQSSFX,  WLS_ODT,       "0",    "0",   ID_ODT,       ddr3_nop,   '1',  '0'),
		( WLS_ODT,     WLS_RDY,       "0",    "0",   ID_ODT,       ddr3_mrs,   '1',  '0'));

	signal xdr_wlu_state : wls_cod;
begin

	input(0) <= xdr_wlu_stp;

	process(xdr_wlu_clk )
	begin
		if rising_edge(xdr_wlu_clk) then
			if xdr_wlu_req='0' then
--				xdr_wlu_state <= (others => '-');
				for i in xdr_state_tab'range loop
					if xdr_state_tab(i).state=xdr_wlu_state then
						if ((xdr_state_tab(i).input xor input) and xdr_state_tab(i).mask)=(input'range =>'0') then
							xdr_wlu_state <= xdr_state_tab(i).state_n;
--							<= xdr_state_tab.odt;
--							<= xdr_state_tab.lat;
--							<= xdr_state_tab.odt;
						end if;
					end if;
				end loop;
			else
				xdr_wlu_state <= xdr_state_tab(0).state;
			end if;
		end if;
	end process;
end;
