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
	constant stages : natural := 4;
	constant timer_size : natural := unsigned_num_bits(max(timers))+stage_size'length;
	constant stage_size : natural_vector(stages-1 downto 0) := (3 => timer_size-1, 2 => 3, 1 => 3, 0 => 0);
	type tword_vector is array (natural range <>) of std_logic_vector(timer_size-1 downto 0);

	impure function pp 
		return tword_vector is
		variable val : tword_vector(timers'range);
		constant csize : natural := stage_size(i+1)-stage_size(i);
		variable aux : std_logic_vector(csize-1 downto 0);
	begin
		val := (others => (others => '-'));
		for i in timers'range loop
			for j in stages-1 downto 0 loop
				aux := to_unsigned(((2**csize-1)+(timers(i)/2**stage_size(i))) mod 2**csize, csize);
				val(i) := val(i) sll aux'length;
				val(i)(aux'range) := aux;
			end loop;
		end loop;
		return val;
	end;

	constant timer_data : tword_vector(timers'range) := pp;
begin

	timer_e : entity hdl4fpga.timer
	generic map (
		n => stages())
	port map (
		data => timer_data(0),
		clk => sys_clk,
		req => sys_req,
		rdy => sys_rdy);

end;
