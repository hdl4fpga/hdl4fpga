library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xdr_ba is
	generic (
		bank_bits  : natural := 2;
		addr_bits  : natural := 13);
	port (
		sys_clk : in std_logic;
		sys_cke : in std_logic;
		sys_odt : in std_logic;
		sys_ras : in std_logic;
		sys_cas : in std_logic;
		sys_we  : in std_logic;
		sys_a   : in std_logic_vector(addr_bits-1 downto 0);
		sys_b   : in std_logic_vector(bank_bits-1 downto 0);

		sys_cfg_rdy : in std_logic;
		sys_cfg_ras : in std_logic;
		sys_cfg_cas : in std_logic;
		sys_cfg_we  : in std_logic;
		sys_cfg_a   : in std_logic_vector(addr_bits-1 downto 0);
		sys_cfg_b   : in std_logic_vector(bank_bits-1 downto 0);

		xdr_cke : out std_logic;
		xdr_odt : out std_logic;
		xdr_ras : out std_logic;
		xdr_cas : out std_logic;
		xdr_we  : out std_logic;
		xdr_b   : out std_logic_vector(bank_bits-1 downto 0);
		xdr_a   : out std_logic_vector(addr_bits-1 downto 0));
end;

library hdl4fpga;

architecture mix of xdr_ba is
begin
	xdr_ras <= sys_ras when sys_cfg_rdy='1' else sys_cfg_ras;
	xdr_cas <= sys_cas when sys_cfg_rdy='1' else sys_cfg_cas;
	xdr_we  <= sys_we  when sys_cfg_rdy='1' else sys_cfg_we;
	xdr_a   <= sys_a   when sys_cfg_rdy='1' else sys_cfg_a;
	xdr_b   <= sys_b   when sys_cfg_rdy='1' else sys_cfg_b;
end;
