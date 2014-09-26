library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity xdr_timer is
	generic ( 
		timers : natural_vector(0 to 0) :=(0 => 2000000));
	port (
		sys_clk : in  std_logic;
		tmr_id  : in  std_logic_vector(0 to 0);
		sys_req : in  std_logic;
		sys_rdy : out std_logic);
end;

architecture def of xdr_timer is
	constant stages : natural := 3;
	constant timer_size : natural := unsigned_num_bits(max(timers))+stages;
	type tword_vector is array (natural range <>) of std_logic_vector(timer_size-1 downto 0);
	
  impure function stage_size
    return natural_vector is
    variable val : natural_vector(stages downto 0);
    variable quo : natural := timer_size mod stages;
  begin
    val(0) := 0;
    for i in 1 to stages loop
      val(i) := timer_size/stages + val(i-1);
      if i*quo >= stages then
        val(i) := val(i) + 1;
        quo := quo - 1;
      end if;
    end loop;
    return val;
  end;
  
	impure function pp 
		return tword_vector is
		variable val : tword_vector(timers'range);
		variable csize : natural;
	begin
		val := (others => (others => '-'));
		for i in timers'range loop
			for j in stages-1 downto 0 loop
				csize := stage_size(j+1)-stage_size(j);
				val(i) := val(i) sll csize;
				val(i)(csize-1 downto 0) := to_unsigned(((2**csize-1)+((timers(i)-(stages-1))/2**(stage_size(j))) mod 2**(csize-1)) mod 2**csize, csize);
			end loop;
		end loop;
		return val;
	end;

	constant timer_data : tword_vector(timers'range) := pp;
	constant xx : natural_vector(stages-1 downto 0) := stage_size(stages downto 1);

begin

	timer_e : entity hdl4fpga.timer
	generic map (
		stage_size => xx)
	port map (
		data => timer_data(0),
		clk => sys_clk,
		req => sys_req,
		rdy => sys_rdy);

end;