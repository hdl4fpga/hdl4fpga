library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xdr_mr is
	port (
		xdr_mr_al   : in  std_logic_vector(2-1 downto 0) := (others => '0');
		xdr_mr_asr  : in  std_logic_vector(1-1 downto 0) := (others => '0');
		xdr_mr_bl   : in  std_logic_vector(3-1 downto 0) := (others => '0');
		xdr_mr_bt   : in  std_logic_vector(1-1 downto 0) := (others => '0');
		xdr_mr_cl   : in  std_logic_vector(3-1 downto 0) := (others => '0');
		xdr_mr_cwl  : in  std_logic_vector(3-1 downto 0) := (others => '0');
		xdr_mr_drtt : in  std_logic_vector(2-1 downto 0) := (others => '0');
		xdr_mr_edll : in  std_logic_vector(1-1 downto 0) := (others => '0');
		xdr_mr_ods  : in  std_logic_vector(2-1 downto 0) := (others => '0');
		xdr_mr_mpr  : in  std_logic_vector(1-1 downto 0) := (others => '0');
		xdr_mr_mprrf : in std_logic_vector(2-1 downto 0) := (others => '0');
		xdr_mr_pd   : in  std_logic_vector(1-1 downto 0) := (others => '0');
		xdr_mr_qoff : in  std_logic_vector(1-1 downto 0) := (others => '0');
		xdr_mr_rdll : in  std_logic_vector(1-1 downto 0) := (others => '1');
		xdr_mr_rtt  : in  std_logic_vector(3-1 downto 0) := (others => '0');
		xdr_mr_srt  : in  std_logic_vector(1-1 downto 0) := (others => '0');
		xdr_mr_tdqs : in  std_logic_vector(1-1 downto 0) := (others => '0');
		xdr_mr_wl   : in  std_logic_vector(1-1 downto 0) := (others => '0');
		xdr_mr_wr   : in  std_logic_vector(3-1 downto 0) := (others => '0');
		xdr_mr_zqc  : in  std_logic_vector(1-1 downto 0) := (others => '0');

		xdr_mr_addr : in  std_logic_vector(3-1 downto 0) := (others => '0');
		xdr_mr_data : out std_logic_vector(13-1 downto 0) := (others => '0'));
end;

architecture ddr3 of xdr_mr is

	type fd is record	-- Field Descritpor
		sz  : natural;	-- Size
		off : natural;	-- Offset
	end record;

	type fd_vector is array (natural range <>) of fd;

	-- DDR3 Mode Register 0 --
	--------------------------

	constant ddr3_bl   : fd_vector(0 to 0) := (0 => (off =>  0, sz => 3));
	constant ddr3_bt   : fd_vector(0 to 0) := (0 => (off =>  3, sz => 1));
	constant ddr3_cl   : fd_vector(0 to 0) := (0 => (off =>  4, sz => 3));
	constant ddr3_rdll : fd_vector(0 to 0) := (0 => (off =>  8, sz => 1));
	constant ddr3_wr   : fd_vector(0 to 0) := (0 => (off =>  9, sz => 3));
	constant ddr3_pd   : fd_vector(0 to 0) := (0 => (off => 12, sz => 1));

	-- DDR3 Mode Register 1 --
	--------------------------

	constant ddr3_edll : fd_vector(0 to 0) := (0 => (off => 0, sz => 1));
	constant ddr3_ods  : fd_vector(0 to 1) := (
		0 => (off => 1, sz => 1), 
		1 => (off => 5, sz => 1));
	constant ddr3_rtt  : fd_vector(0 to 2) := (
		0 => (off => 2, sz => 1),
		1 => (off => 6, sz => 1),
		2 => (off => 9, sz => 1));
	constant ddr3_al   : fd_vector(0 to 0) := (0 => (off =>  3, sz => 2));
	constant ddr3_wl   : fd_vector(0 to 0) := (0 => (off =>  7, sz => 1));
	constant ddr3_tdqs : fd_vector(0 to 0) := (0 => (off => 11, sz => 1));
	constant ddr3_qoff : fd_vector(0 to 0) := (0 => (off => 12, sz => 1));

	-- DDR3 Mode Register 2 --
	--------------------------

	constant ddr3_cwl  : fd_vector(0 to 0) := (0 => (off => 3, sz => 3));
	constant ddr3_asr  : fd_vector(0 to 0) := (0 => (off => 6, sz => 1));
	constant ddr3_srt  : fd_vector(0 to 0) := (0 => (off => 7, sz => 1));
	constant ddr3_drtt : fd_vector(0 to 0) := (0 => (off => 9, sz => 2));

	-- DDR3 Mode Register 3 --
	--------------------------

	constant ddr3_mprrf : fd_vector(0 to 0) := (0 => (off => 0, sz => 2));
	constant ddr3_mpr   : fd_vector(0 to 0) := (0 => (off => 2, sz => 1));

	constant ddr3_zqc   : fd_vector(0 to 0) := (0 => (off => 10, sz => 1));

	function mr_field (
		constant mask : fd_vector;
		constant src  : std_logic_vector)
		return std_logic_vector is
		variable aux : unsigned(src'range) := unsigned(src);
		variable fld : unsigned(xdr_mr_data'length-1 downto 0) := (others => '0');
		variable val : unsigned(fld'range) := (others => '0');
	begin
		for i in mask'reverse_range loop
			fld := (others => '0');
			for j in 1 to mask(i).sz loop
				fld := fld sll 1;
				fld(0) := aux(0);
				aux := aux srl 1;
			end loop;
			fld := fld sll mask(i).off;
			val := val or  fld;
		end loop;
		return std_logic_vector(val);
	end;

begin

	with xdr_mr_addr(2 downto 0) select
	xdr_mr_data <=

		-- Mode Register 0 --

		mr_field(mask => ddr3_bl, src => xdr_mr_bl) or
		mr_field(mask => ddr3_bt, src => xdr_mr_bt) or
		mr_field(mask => ddr3_cl, src => xdr_mr_cl) or
		mr_field(mask => ddr3_pd, src => xdr_mr_pd) or
		mr_field(mask => ddr3_rdll, src => xdr_mr_rdll) or
		mr_field(mask => ddr3_wr, src => xdr_mr_wr) when "000",

		-- Mode Register 1 --

		mr_field(mask => ddr3_al,   src => xdr_mr_al) or
		mr_field(mask => ddr3_edll, src => xdr_mr_edll) or
		mr_field(mask => ddr3_ods,  src => xdr_mr_ods) or
		mr_field(mask => ddr3_qoff, src => xdr_mr_qoff) or
		mr_field(mask => ddr3_rtt,  src => xdr_mr_rtt) or
		mr_field(mask => ddr3_tdqs, src => xdr_mr_tdqs) or
		mr_field(mask => ddr3_wl,   src => xdr_mr_wl) when "001",

		-- Mode Register 2 --

		mr_field(mask => ddr3_asr,  src => xdr_mr_asr) or
		mr_field(mask => ddr3_cwl,  src => xdr_mr_cwl) or
		mr_field(mask => ddr3_drtt, src => xdr_mr_drtt) or
		mr_field(mask => ddr3_srt,  src => xdr_mr_srt) when "010",

		-- Mode Register 3 --

		mr_field(mask => ddr3_mprrf, src => xdr_mr_mprrf) or
		mr_field(mask => ddr3_mpr,   src => xdr_mr_mpr) when "011",
		
		mr_field(mask => ddr3_zqc,   src => xdr_mr_zqc) when "100",

		(xdr_mr_data'range => '-') when others; 


end;
