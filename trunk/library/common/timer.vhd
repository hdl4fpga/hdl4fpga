library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity timer is
	generic ( 
		timer_len  : natural;
		timer_data : natural_vector);
	port (
		timer_clk  : in  std_logic;
		timer_rst  : in  std_logic;
		timer_sel  : in  std_logic_vector;
		timer_req  : out std_logic;
		timer_rdy  : out std_logic);
end;

architecture def of timer is
	constant n : natural := 4;
	
	signal q0  : std_logic_vector(n-1 downto 0);
	signal rdy : std_logic;
begin

	cntr_g: for i in q0'range generate
		process (timer_clk)
			variable ena   : std_logic;
			variable load  : std_logic;
			variable cntr  : unsigned(0 to timer_len/n);
			variable data  : unsigned(1 to cntr'right);
			variable value : unsigned(data'range);
		begin
			if rising_edge(timer_clk) then
				ena := q0(0);

				ena := not rdy;
				for j in 1 to i-1 loop
					ena := ena and q0(i);
				end loop;

				data := value;
				if timer_req='0' then
					data := to_unsigned(2**data'length-2, data'length);
				end if;

				cntr := dec (
					cntr => cntr,
					ena  => not timer_req or ena,
					load => not timer_req or cntr(0),
					data => data);
	
				rdy   <= setif(q0=(q0'range => '1'));
				value := to_unsigned((timer_data(to_integer(unsigned(timer_sel)))/2**(i*cntr'right)) mod 2**(cntr'right), value'length);

			end if;
		end process;

	end generate;
end;
