library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity timer is
	generic (
		stage_size : natural_vector);
	port (
		data : in  std_logic_vector;
		clk  : in  std_logic;
		req  : in  std_logic;
		rdy  : out std_logic);
end;

architecture def of timer is

	signal cy : std_logic_vector(stage_size'length downto 0) := (0 => '1', others => '0');
	signal en : std_logic_vector(stage_size'length downto 0) := (0 => '1', others => '0');
	signal q  : std_logic_vector(stage_size'length-1 downto 0);
begin

	process (clk)
	begin
		if rising_edge(clk) then
			for i in 0 to stage_size'length-1 loop
				if req='1' then
					cy(i+1) <= '0';
				elsif cy(stage_size'length)='0' then
					cy(i+1) <= q(i) and cy(i);
				end if;
			end loop;
		end if;
	end process;
	en <= cy(stage_size'length downto 1) & not cy(stage_size'length);

	cntr_g : for i in 0 to stage_size'length-1 generate

		impure function csize (
			constant i : natural)
			return natural is
		begin
			if i = 0 then
				return 0;
			end if;
			return stage_size(i-1);
		end;
		constant size : natural := csize(i+1)-csize(i);
		signal cntr : unsigned(0 to size-1);

	begin
		cntr_p : process (clk)
			variable csize : natural_vector(stage_size'length downto 0) := (others => 0);
		begin
			if rising_edge(clk) then
				csize(stage_size'length downto 1) := stage_size;
				if req='1' then
					cntr <= resize(shift_right(unsigned(data), csize(i)), size);
				elsif en(i)='1' then
					if cntr(0)='1' then
						cntr <= to_unsigned((2**(size-1)-2), size);
					else
						cntr <= cntr - 1;
					end if;
				end if;
			end if;
		end process;
		q(i) <= cntr(0);
	end generate;
	rdy <= cy(stage_size'length);
end;
