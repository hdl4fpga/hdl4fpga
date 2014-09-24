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
	constant stages : natural := 3;
	function (
		constant data : natural_vector)
		return std_logic_vector is
		constant size : natural := ((data'length+n-1)/n);
	begin
		for i in aux'range loop
			for j in aux'range loop
				aux(j) := to_unsigned((2**size-1)+timers(i)) mod 2**size, size);
			end loop;
		end loop;
	end;

	signal data : std_logic_vector(unsigned_num_bits(max(timers))-1 downto 0);
begin

	process (sys_clk)
		variable aux : natural_vector(stages-1 downto 0);
	begin
		if rising_edge(sys_clk) then
		end if;
	end process;

	timer_e : entity hdl4fpga.timer
	generic map (
		n => n)
	port map (
		data => data,
		clk => sys_clk,
		req => sys_req,
		rdy => sys_rdy);

end;
