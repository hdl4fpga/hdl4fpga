library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity counter is
	generic (
		stage_size : natural_vector := (0 => 13, 1 => 26, 2 => 30));
	port (
		clk  : in  std_logic;
		ena  : in  std_logic;
		load : in  std_logic;
		data : in  std_logic_vector(stage_size(stage_size'high) downto 0);
		qo   : out std_logic_vector(stage_size(stage_size'high) downto 0));
end;

architecture def of counter is

	signal cy : std_logic_vector(stage_size'length downto 0) := (0 => '1', others => '0');
	signal en : std_logic_vector(stage_size'length downto 0) := (0 => '1', others => '0');
	signal q  : std_logic_vector(stage_size'length-1 downto 0);

begin

	process (clk)
	begin
		if rising_edge(clk) then
			for i in 0 to stage_size'length-1 loop
				if load='1' then
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
		signal cntr   : unsigned(csize(i) to csize(i)+size-1);

	begin

		cntr_p : process (clk)
			variable csize : natural_vector(stage_size'length downto 0) := (others => 0);
		begin
			if rising_edge(clk) then
				csize(stage_size'length downto 1) := stage_size;
				if load='1' then
					cntr <= resize(shift_right(unsigned(data), csize(i)), size);
				elsif en(i)='1' then
					if cntr(cntr'left)='1' then
						cntr <= to_unsigned((2**(size-1)-2), size);
					else
						cntr <= cntr - 1;
					end if;
				end if;
			end if;
		end process;

		qo_g : for i in cntr'range generate
			qo(i) <= cntr(i);
		end generate;
		q(i) <= cntr(cntr'left);

	end generate;
	--rdy <= cy(stage_size'length);
end;
