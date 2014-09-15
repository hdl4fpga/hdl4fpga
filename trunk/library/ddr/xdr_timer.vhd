library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity xdr_timer is
	generic ( 
		tmr_high : natural;
		tmr_low  : natural;
		timers : natural_vector);
	port (
		sys_clk : in  std_logic;
		tmr_id  : in  std_logic_vector;
		sys_req : in  std_logic;
		sys_rdy : out std_logic);
end;

architecture def of xdr_timer is

	type counter_t is record
		low  : unsigned(0 to tmr_low);
		high : unsigned(0 to tmr_high);
	end record;

	type counter_vector is array (natural range <>) of counter_t;

	function counter_init (
		constant arg : natural_vector)
		return counter_vector is
		variable val : counter_vector(arg'range);
		variable aux : natural;
	begin
		for i in val'range loop
			aux := ((arg(i)-1)+15)/16;
			val(i).high := to_unsigned(aux  /  2**tmr_low, tmr_high+1);
			val(i).low  := to_unsigned(aux mod 2**tmr_low,  tmr_low+1);
		end loop;
		return val;
	end;

	constant counter_data : counter_vector(timers'range) := counter_init(timers);

	signal req : std_logic := '0';
	signal cntr_req : std_logic := '0';
	signal cntr_clk : std_logic;
	signal counter : counter_t;

begin

	process (sys_clk)
		variable div : unsigned(0 to 3) := (others => '0');
	begin
		if rising_edge(sys_clk) then
			div := div + 1;
			cntr_clk <= div(0);
			req <= sys_req or (req and not sys_req and not cntr_req);
		end if;
	end process;

	process (cntr_clk)
		variable meta : std_logic := '0';
	begin
		if rising_edge(cntr_clk) then
			cntr_req <= meta;
			meta := req;
		end if;
	end process;

	process (cntr_clk)
	begin
		if rising_edge(cntr_clk) then
			if cntr_req='1' then
				counter <= counter_data(to_integer(unsigned(tmr_id)));
			elsif counter.high(0) = '0' then
				if counter.low(0) = '1' then
					counter.low  <= to_unsigned(2**tmr_low-2, tmr_low+1);
					counter.high <= counter.high - 1;
				else
					counter.low  <= counter.low  - 1;
				end if;
			end if;
		end if;
	end process;

	process (sys_clk)
		variable meta : std_logic;
	begin
		if rising_edge(sys_clk) then
			sys_rdy <= meta;
			meta := counter.high(0);
		end if;
	end process;

end;
