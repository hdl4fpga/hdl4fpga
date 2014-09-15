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
		tmr_req : in  std_logic;
		tmr_rdy : out std_logic);

--	attribute fsm_encoding : string;
--	attribute fsm_encoding of xdr_timer : entity is "compact";
end;

architecture def of xdr_timer is

	type counter_t record is
		low  : unsigned;
		high : unsigned;
	end record;

	type counter_vector is array (natural range <>) of counter_t;

	function (
			arg : natural_vector
		)
		return counter_vector is
		variable val : counter_vector(arg'range);
	begin
		for i in val'range loop

		end loop;
		return val;
	end;

	signal counter : counter_t;
begin

	process (sys_clk)
	begin
		if rising_edge(sys_clk) then
			if sys_req='1' then
				counter := 
			end if;
		end if;
	end process;

	sys_rdy <= counter.high(0);
end;
