library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity xdr_timer is
	generic ( 
		timers : natural_vector);
	port (
		sys_clk : in  std_logic;
		tmr_id  : in  std_logic_vector;
		sys_req : in  std_logic;
		sys_rdy : out std_logic);
end;

architecture def of xdr_timer is
	signal data : std_logic_vector(unsigned_num_bits(max(timers))-1 downto 0);
begin

	timer_e : entity hdl4fpga.timer
	generic map (
		n => timers'length)
	port map (
		data => data,
		clk => sys_clk,
		req => sys_req,
		rdy => sys_rdy);

end;
