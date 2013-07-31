library ieee;
use ieee.std_logic_1164.all;

entity ddr_io_dm is
	generic (
		data_bytes : natural);
	port (
		ddr_io_clk : in std_logic;
		ddr_io_dmz : in std_logic;
		ddr_io_st_r : in std_logic;
		ddr_io_st_f : in std_logic;
		ddr_io_dm_r : in std_logic_vector(data_bytes*byte_bits-1 downto 0);
		ddr_io_dm_f : in std_logic_vector(data_bytes*byte_bits-1 downto 0);
		ddr_io_dm  : inout std_logic_vector(data_bytes*byte_bits-1 downto 0);
		ddr_io_dmi : out std_logic_vector(data_bytes*byte_bits-1 downto 0));
end;

library unisim;
use unisim.vcomponents.all;

architecture arch of ddr_io_dq is
	signal ddr_io_fclk : std_logic;
begin
	ddr_io_fclk <= not ddr_io_clk;
	bytes_g : for i in ddr_io_dqz'range generate
		bits_g : for j in byte_bits-1 downto 0 generate
			signal dqo : std_logic;
			signal dqz : std_logic;
			signal di : std_logic;
--			signal d1 : std_logic;
--			signal d2 : std_logic;
		begin

--			d1 <= ddr_io_st_r when ddr_io_dmz else
--				ddr_io_dm_r(i*byte_bits+j);
--			d2 <= ddr_io_st_f when else 
--				ddr_io_dm_r(i*byte_bits+j),

			oddr_du : oddr
			port map (
				r => '0',
				s => '0',
				c => ddr_io_clk,
				ce => '1',
				d1 => ddr_io_dm_r(i*byte_bits+j),
				d2 => ddr_io_dm_f(i*byte_bits+j),
--				d1 => d1,
--				d2 => d2,
				q => dqo);

			ffd_i : fdrse
			port map (
				s  => '0',
				r  => '0',
				c  => ddr_io_clk,
				ce => '1',
				d  => ddr_io_dmz,
				q  => dqz);

			ddr_io_dm(i*byte_bits+j) <= 'Z' when dqz='1' else dqo;

			ibuf_dq : ibuf
			port map (
				i => ddr_io_dq(i*byte_bits+j),
				o => di);
			idelay_i : idelay 
			port map (
				rst => '0',
				c  =>'0',
				ce => '0',
				inc => '0',
				i => di,
				o => ddr_io_dmi(i*byte_bits+j));
--			ddr_io_dqi(i*byte_bits+j) <= di;
		end generate;
	end generate;
end;
