use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.xdr_param.all;

entity xdr_rgtr is
	generic (
		data_size : natural := 13;
		addr_size : natural := 3);
	port (
		xdr_rgtr_ods  : in  std_logic := '0';
		xdr_rgtr_rtt  : in  std_logic_vector(2 downto 0) := "001";
		xdr_rgtr_drtt : in  std_logic_vector(1 downto 0) := "01";
		xdr_rgtr_bl   : in  std_logic_vector(0 to 2);
		xdr_rgtr_cl   : in  std_logic_vector(0 to 2);
		xdr_rgtr_wr   : in  std_logic_vector(0 to 2) := (others => '0');
		xdr_rgtr_cwl  : in  std_logic_vector(0 to 2) := (others => '0');
		xdr_rgtr_pl   : in  std_logic_vector(0 to 2) := (others => '0');
		xdr_rgtr_dqsn : in  std_logic := '0';

		xdr_rgtr_addr : in  std_logic_vector(addr_size-1 downto 0);
		xdr_rgtr_data : out std_logic_vector(data_size-1 downto 0));

	type field_id is (ID_CL, ID_BL, ID_WR, ID_DRTT, ID_RTT, ID_CWL, ID_PL, ID_ODS);


	type mr_array is array (natural range <>) of ddr3_mr;

	signal src : src_word;

end;

architecture ddr3 of xdr_rgtr is

	type fdctr is record
		sz  : natural;
		off : natural;
	end record;
	type fdctr_vector is array of fdctr;

	-- DDR3 Mode Register 0 --
	--------------------------

	constant ddr3_bl   : fdctr_vector(0 to 0) := ((off =>  0, sz => 3));
	constant ddr3_bt   : fdctr_vector(0 to 0) := ((off =>  3, sz => 1));
	constant ddr3_cl   : fdctr_vector(0 to 0) := ((off =>  4, sz => 3));
	constant ddr3_tm   : fdctr_vector(0 to 0) := ((off =>  7, sz => 1));
	constant ddr3_rdll : fdctr_vector(0 to 0) := ((off =>  8, sz => 1));
	constant ddr3_wr   : fdctr_vector(0 to 0) := ((off =>  9, sz => 3));
	constant ddr3_pd   : fdctr_vector(0 to 0) := ((off => 12, sz => 1));

	-- DDR3 Mode Register 1 --
	--------------------------

	constant ddr3_edll : fdctr_vector(0 to 0) := ((off => 0, sz => 1));
	constant ddr3_ods  : fdctr_vector(0 to 1) := (
		(off => 1, sz => 1), 
		(off => 5, sz => 1));
	constant ddr3_rtt  : fdctr_vector(0 to 2) := (
		(off => 2, sz => 1),
		(off => 6, sz => 1),
		(off => 9, sz => 1));
	constant ddr3_al   : fdctr_vector(0 to 0) := ((off =>  3, sz => 2);
	constant ddr3_wl   : fdctr_vector(0 to 0) := ((off =>  7, sz => 1);
	constant ddr3_dqs  : fdctr_vector(0 to 0) := ((off => 10, sz => 1);
	constant ddr3_tdqs : fdctr_vector(0 to 0) := ((off => 11, sz => 1);
	constant ddr3_qoff : fdctr_vector(0 to 0) := ((off => 12, sz => 1);

	-- DDR3 Mode Register 2 --
	--------------------------

	constant ddr3_cwl  : fdctr_vector(0 to 0) := (off => 3, sz => 3);
	constant ddr3_asr  : fdctr_vector(0 to 0) := (off => 6, sz => 1);
	constant ddr3_srt  : fdctr_vector(0 to 0) := (off => 7, sz => 1);
	constant ddr3_drtt : fdctr_vector(0 to 0) := (off => 9, sz => 2);

	-- DDR3 Mode Register 3 --
	--------------------------

	constant ddr3_mpr_rf  : fdctr_vector(0 to 0) := (off => 0, sz => 2);
	constant ddr3_mpr     : fdctr_vector(0 to 0) := (off => 2, sz => 1);

	subtype rgtr_word is std_logic_vector(xdr_rgtr_data'lenth-1 downto 0);

	type rgtrword_vector is array (natural range <>) of word;
	signal rgtrfile is word_vector(0 to 2**xdr_rgtr_addr'length-1);

	function (
		constant rgtr_id  : std_logic_vector;
		constant fld_mask : fdctr_vector;
		constant fld_val  : std_logic_vector)
		return rgrt_word) is
		variable rtgr_word : std_logic_vector(rgtr_word'range) := (others => '0');
	begin
	end;
begin

end;
