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
		ID_ODT     => round_lat(tODTL+tWLOE, tCLK)-2,

	type xdr_state_word is record
		xdr_state : std_logic_vector(0 to 2);
		xdr_state_n : std_logic_vector(0 to 2);
		xdr_lat : lat_id;
		xdr_odt : std_logic;
	end record;

	signal xdr_wlu_pc : unsigned(0 to unsigned_num_bits(pgm'length-1));

	constant xdr_state_tab : xdr_state_vector(0 to 12-1) := (
--		+------------+--------------+-------------+------+-----+
--		| xdr_state  | xdr_state_n  | xdr_lat     | odt  | dqs |
--		+------------+--------------+-------------+------+-----+
		( WLS_MRS,     WLS_WLDQSEN,   ID_MOD,       '0',  '0'),		
		( WLS_WLDQSEN, WLS_WLMRD,     ID_WLDQSEN,   '1',  '0'),
		( WLS_DQSPRE,  WLS_DQLHEA,    ID_WLMRD,     '1',  '0'),

		( WLS_DQSHEA,  WLS_DQSH,      ID_WLO,       '0',  '0'),
		( WLS_DQSH,    WLS_DQLTWO,    ID_TC,        '0',  '0'),
		( WLS_DQLTWO,  WLS_DQSHEA,    ID_TC,        '0',  '1'),
		( WLS_DQLTWO,  WLS_DQSSFX,    ID_TC,        '0',  '1'),

		( WLS_DQSFSX   WLS_ODT,       ID_TC,        '1',  '0'),
		( WLS_ODT,     WLS_RDY,       ID_TC,        '1',  '0'));
begin

	process(xdr_wlu_clk )
	begin
		if rising_edge(xdr_wlu_clk) then
			xdr_wlu_pc <= (others => '-');
			for i in xdr_state_tab'ragne loop
				if xdr_state_tab=xdr_wlu_pc then
					if (.inp xor .val) and .mask=( =>'0') then
					end if;
				end if;
			end loop;
		end if;
	end process;
end;
