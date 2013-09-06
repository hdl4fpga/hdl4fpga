library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity timers is
	generic ( 
		timer_len  : natural;
		timer_data : natural_vector);
	port (
		timer_clk : in  std_logic;
		timer_sel : in  std_logic_vector;
		timer_req : in  std_logic;
		timer_rdy : out std_logic);
end;

architecture def of timers is
	constant n : natural := 3;
	
	signal q0  : std_logic_vector(n-1 downto 0);
	signal rdy : std_logic;
begin

	timer_rdy <= rdy;
	cntr_g: for i in q0'range generate
		cntr_p : process (timer_clk)
			variable ena   : std_logic;
			variable cntr  : unsigned(0 to (timer_len-1)/n+1);
			variable data  : unsigned(0 to cntr'right);
			variable value : unsigned(data'range);

			function deca_data (
				constant data : natural_vector;
				constant deca : natural;
				constant size : natural)
				return natural_vector is
				variable val : hdl4fpga.std.natural_vector(data'range);
			begin
				for i in data'range loop
					val(i) := ((((data(i)-1)/2**(deca*size)) mod 2**size)+2**(size+1)-1) mod 2**(size+1);
				end loop;
				return val;
			end;

			constant deca_rom : natural_vector := deca_data(timer_data, i, cntr'right);
		begin
			if rising_edge(timer_clk) then
				ena := not rdy;
				for j in i-1 downto 0 loop
					ena := ena and q0(j);
				end loop;

				data := value;
				if timer_req='1' then
					data := to_unsigned(2**(data'length-1)-2, data'length);
				end if;

				cntr := dec (
					cntr => std_logic_vector(cntr),
					ena  => not timer_req or ena,
					load => not timer_req or cntr(0),
					data => std_logic_vector(data));
				q0(i) <= cntr(0);
	
				value := to_unsigned(deca_rom(to_integer(unsigned(timer_sel))), value'length);

			end if;
		end process;

	end generate;

	process (timer_clk)
	begin
		if rising_edge(timer_clk) then
			rdy <= setif(q0=(q0'range => '1') or rdy='1') and timer_req;
		end if;
	end process;
	
end;
