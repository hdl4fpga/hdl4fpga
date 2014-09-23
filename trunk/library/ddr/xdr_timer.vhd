library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity xdr_timer is
	generic ( 
		timers : natural_vector(0 to 1) := (500, 200));
	port (
		sys_clk : in  std_logic;
		tmr_id  : in  std_logic_vector(0 to 0);
		sys_req : in  std_logic;
		sys_rdy : out std_logic);
end;

architecture def of xdr_timer is
	signal data : std_logic_vector;
begin

	process (
	timer : entity hdl4fpga.timer
	port (
		data => data
		clk => sys_clk,
		req => sys_req,
		rdy => sys_rdy);

	process (cntr_clk)
		variable meta : std_logic := '0';
	begin
		if rising_edge(cntr_clk) then
			cntr_req <= meta;
			meta := req;
		end if;
	end process;


end;
