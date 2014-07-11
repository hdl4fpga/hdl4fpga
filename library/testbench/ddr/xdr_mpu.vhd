library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

use std.textio.all;
library hdl4fpga;

architecture xdr_mpu of testbench is
	constant period : time := 4 ns;

	signal clk : std_logic := '0';
	signal rst : std_logic;
	signal rdy : std_logic;
	subtype cmdword is std_logic_vector(0 to 2);
	type cmdword_vector is array (natural range <>) of cmdword;

	signal cmd : std_logic_vector(0 to 2);
begin
	clk <= not clk after period/2;
	rst <= '1', '0' after 10 ns;

	process (clk)
		variable i : natural := 0;
		constant cmds : cmdword_vector(0 to 2) := ("011", "101", "010");
	begin
		if rst='1' then
			cmd <= cmds(i);
			i := 0;
		elsif rising_edge(clk) then
			if rdy='1' then
				i := (i+1) mod cmdword'length;
				cmd <= cmds(i);
			end if;
		end if;
	end process;

	du : entity hdl4fpga.xdr_mpu
	generic map (
		lRCD => 1,
		lRFC => 1,
		lWR  => 1,
		lRP  => 1,
		bl_cod => "000",
		bl_tab => (0 => 8),
		cl_cod => "000",
		cl_tab => (0 => 7),
		cwl_cod => "000",
		cwl_tab => (0 => 7))
	port map (
		xdr_mpu_bl  => "001",
		xdr_mpu_cl  => "001",
		xdr_mpu_cwl => "001",

		xdr_mpu_rst => rst,
		xdr_mpu_clk => clk,
		xdr_mpu_cmd => cmd,
		xdr_mpu_rdy => rdy);

end;
