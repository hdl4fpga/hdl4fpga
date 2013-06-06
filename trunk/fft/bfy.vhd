library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;

entity bfy is
	generic (
		num : natural := 13);
	port (
		clk : in  std_logic;
		s   : in  std_logic;
		di  : in  sfixed;
		do  : out sfixed);
end;

use work.std.all;

architecture def of bfy is
	signal fifo_di : std_logic_vector(di'range);
	signal fifo_do : std_logic_vector(di'range);
begin
	process (clk)
	begin
		if rising_edge(clk) then
			if s='1' then
				do <= resize(to_sfixed(signed(fifo_do),di) + di, di);
				fifo_di <= to_stdlogicvector(resize(to_sfixed(signed(fifo_do),di) - di, di));
			else
				do <= to_sfixed(signed(fifo_do),di);
				fifo_di <= to_stdlogicvector(di);
			end if;
		end if;
	end process;

	fifo_e : entity work.fifo
	generic map (
		data_size => di'length,
		addr_size => num)
	port map (
		clk => clk,
		deep => to_unsigned(2**num-2, num),
		di  => fifo_di,
		do  => fifo_do);
end;

use work.fft.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;

entity cbfy is
	generic (
		num : natural := 13);
	port (
		clk : in  std_logic;
		s   : in  std_logic;
		di  : in  cfixed;
		do  : out cfixed);
end;

architecture def of cbfy is
begin

	bfyre_e : entity work.bfy
	generic map (
		num => num)
	port map (
		clk => clk,
		s   => s,
		di  => di.re,
		do  => do.re);

	bfyim_e : entity work.bfy
	generic map (
		num => num)
	port map (
		clk => clk,
		s   => s,
		di  => di.im,
		do  => do.im);

end;

use work.fft.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;

entity radix22 is
	generic (
		num : natural := 13);
	port (
		clk : in  std_logic;
		s   : in  std_logic_vector(0 to 2-1);
		di  : in  cfixed;
		do  : out cfixed);
end;

architecture def of radix22 is
	signal data : cfixed_vector(0 to s'length);
begin

	data(0) <= di;
	radix_g : for i in s'range generate
		cbfy_e : entity work.cbfy
		generic map (
			num => num-i)
		port map (
			clk => clk,
			s   => s(i),
			di  => data(i),
			do  => data(i+1));
	end generate;
	do <= data(data'high);

end;

use work.fft.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity twdtab is
	port (
		clk  : in std_logic;
		addr : in std_logic_vector;
		cos_data : out std_logic_vector;
		sin_data : out std_logic_vector);
end;

architecture def of twdtab is

	subtype word is std_logic_vector(sin_data'length-1 downto 0);
	type word_vector is array (natural range <>) of word;

	impure function sintab 
		return word_vector is
		variable val : word_vector(0 to 2**addr'length-1);
	begin
		for i in val'range loop
			val(i) := sin (i, 2**(addr'length+2), word'length);
		end loop;
		return val;
	end;

	constant tab : word_vector(0 to 2**addr'length-1) := sintab;

	signal re_addr: unsigned(addr'range);
	signal im_addr: unsigned(addr'range);

begin

	process (clk)
	begin
		if rising_edge(clk) then
			re_addr <= unsigned(-signed(addr));
			im_addr <= unsigned(addr);
		end if;
	end process;

	process (clk)
	begin
		if rising_edge(clk) then
			cos_data <= tab(to_integer(re_addr));
		end if;
	end process;

	process (clk)
	begin
		if rising_edge(clk) then
			sin_data <= tab(to_integer(im_addr));
		end if;
	end process;

end;

use work.fft.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;

entity twd is
	port (
		clk : in  std_logic;
		di  : in  cfixed;
		twd : in  ctwd;
		do  : out cfixed);
end;

architecture def of twd is
begin
	process (clk)
	begin
		if rising_edge(clk) then
			do <= di*twd;
		end if;
	end process;
end;

use work.fft.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;

entity fft22 is
	port (
		clk : in  std_logic;
		s   : in  std_logic_vector(0 to 2-1);
		di  : in  cfixed;
		do  : out cfixed);
end;

architecture def of fft22 is

	signal rdx_di : cfixed;
	signal rdx_do : cfixed;
	signal twd_di : cfixed;
	signal twd_do : cfixed;
	signal twd_factor : ctwd;
	signal cos_data : std_logic_vector(work.fft.p-1 downto 0);
	signal sin_data : std_logic_vector(work.fft.p-1 downto 0);

begin

	bfy_e : entity work.radix22
	generic map (
		num => 14)
	port map (
		clk => clk,
		s  => s,
		di => rdx_di,
		do => rdx_do);

	twdtab_e : entity work.twdtab
	port map (
		clk  => clk,
		addr => s,
		cos_data => cos_data,
		sin_data => sin_data);

	twd_factor.re <= to_sfixed(signed(cos_data),twd_factor.re);
	twd_factor.im <= to_sfixed(signed(sin_data),twd_factor.im);

	twd_e : entity work.twd
	port map (
		clk => clk,
		di  => twd_di,
		twd => twd_factor,
		do  => twd_do);

end;
