library ieee;
use ieee.std_logic_1164.all;

entity ddr_io_dm is
	generic (
		data_bytes : natural);
	port (
		ddr_io_clk : in std_logic;
		ddr_io_dmx_r : in std_logic_vector(data_bytes-1 downto 0);
		ddr_io_dmx_f : in std_logic_vector(data_bytes-1 downto 0);
		ddr_io_st_r : in std_logic;
		ddr_io_st_f : in std_logic;
		ddr_io_dm_r : in std_logic_vector(data_bytes-1 downto 0);
		ddr_io_dm_f : in std_logic_vector(data_bytes-1 downto 0);
		ddr_io_dm  : inout std_logic_vector(data_bytes-1 downto 0);
		ddr_io_dmi : out std_logic_vector(data_bytes-1 downto 0));
end;

library unisim;
use unisim.vcomponents.all;

architecture arch of ddr_io_dm is
	signal ddr_io_fclk : std_logic;
begin
	ddr_io_fclk <= not ddr_io_clk;
	bytes_g : for i in ddr_io_dm'range generate
		signal dqo : std_logic;
		signal di : std_logic;
		signal d1 : std_logic;
		signal d2 : std_logic;
	begin
		process (ddr_io_clk)
		begin
			if rising_edge(ddr_io_clk) then
				case ddr_io_dmx_r(i) is
				when '0' =>
					d1 <= ddr_io_st_r;
				when others =>
					d1 <= ddr_io_dm_r(i);
				end case;
			end if;
		end process;

		process (ddr_io_fclk)
		begin
			if rising_edge(ddr_io_fclk) then
				case ddr_io_dmx_f(i) is
				when '0' =>
					d2 <= ddr_io_st_f;
				when others =>
					d2 <= ddr_io_dm_f(i);
				end case;
			end if;
		end process;

		oddr_du : oddr
		port map (
			r => '0',
			s => '0',
			c => ddr_io_clk,
			ce => '1',
			d1 => d1,
			d2 => d2,
			q => dqo);

		obuf_i : obuft
		port map (
			t => '0', -- dqz,
			i => dqo,
			o => ddr_io_dm(i));

		ibuf_i : ibuf
		port map (
			i => ddr_io_dm(i),
			o => di);

		idelay_i : idelay 
		port map (
			rst => '0',
			c   =>'0',
			ce  => '0',
			inc => '0',
			i => di,
			o => ddr_io_dmi(i));

	end generate;
end;
