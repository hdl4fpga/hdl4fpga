use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.xdr_param.all;

entity xdr_wlu is
	generic (
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

end;

architecture ddr3 of xdr_wlu is

	constant lat_size : natural := unsigned_num_bits(
		max(());
	signal lat_timer : signed(0 to lat_size-1) := (others => '1');

	type timer_id is (ID_MOD, ID_WLDQSEN, ID_WLMRD, ID_WLO, ID_TB);

	type lattab is array (timer_id) of natural;
	constant latdb : lattab := (
		ID_MOD     => round_lat(tMOD, tCLK)-2,
		ID_WLDQSEN => round_lat(tWLDQSE-tMOD, tCLK)-2,
		ID_DQSPRE  => round_lat(tWLO, tCLK)-2,

		ID_DQLHEA  => round_lat(tDQSL-tWLO, tCLK)-2,
		ID_DQSH    => round_lat(tDQSH, tCLK)-2,
		ID_DQLTWO  => round_lat(tWLO, tCLK)-2,

		ID_DQSSFX  => round_lat(, tCLK)-2,
		ID_ODT     => round_lat(tODTL+tWLOE, tCLK)-2);

	type xdr_state_word is record
		state : std_logic_vector(0 to 2);
		state_n : std_logic_vector(0 to 2);
		lat : lat_id;
		cmd : ddr3_cmd;
		odt : std_logic;
	end record;

	signal xdr_wlu_pc : unsigned(0 to unsigned_num_bits(pgm'length-1));

	constant xdr_state_tab : xdr_state_vector(0 to 12-1) := (
--		+------------+--------------+-------+------+-------------+-----------+-----+-----+
--		| xdr_state  | xdr_state_n  | input | mask | xdr_lat     | cmd       | odt | dqs |
--		+------------+--------------+-------+------+-------------+-----------+-----+-----+
		( WLS_MRS,     WLS_WLDQSEN,   "0",    "0",   ID_MOD,       ddr3_mrs,   '0',  '0'),		
		( WLS_WLDQSEN, WLS_WLMRD,     "0",    "0",   ID_WLDQSEN,   ddr3_nop,   '1',  '0'),
		( WLS_DQSPRE,  WLS_DQLHEA,    "0",    "0",   ID_WLMRD,     ddr3_nop,   '1',  '0'),
                                                                              
		( WLS_DQSHEA,  WLS_DQSH,      "1",    "0",   ID_WLO,       ddr3_nop,   '0',  '0'),
		( WLS_DQSH,    WLS_DQLTWO,    "1",    "0",   ID_TC,        ddr3_nop,   '0',  '0'),
		( WLS_DQLTWO,  WLS_DQSHEA,    "1",    "1",   ID_TC,        ddr3_nop,   '0',  '1'),
		( WLS_DQLTWO,  WLS_DQSSFX,    "1",    "0",   ID_TC,        ddr3_nop,   '0',  '1'),
                                                                              
		( WLS_DQSFSX   WLS_ODT,       "0",    "0",   ID_TC,        ddr3_nop,   '1',  '0'),
		( WLS_ODT,     WLS_RDY,       "0",    "0",   ID_TC,        ddr3_mrs,   '1',  '0'));
begin

	process(xdr_wlu_clk )
	begin
		if rising_edge(xdr_wlu_clk) then
			if xdr_wlu_req='0' then
				xdr_wlu_pc <= (others => '-');
				for i in xdr_state_tab'range loop
					if xdr_state_tab.state=xdr_wlu_state then
						if (xdr_state_tab.input xor input) and xdr_state_tab.mask=(input'range =>'0') then
							xdr_wlu_state <= xdr_state_tab.state_n;
							<= xdr_state_tab.odt;
							<= xdr_state_tab.lat;
							<= xdr_state_tab.odt;
						end if;
					end if;
				end loop;
			else
				xdr_wlu_pc <= xdr_state_tab(0).xdr_state;
			end if;
		end if;
	end process;
end;
