library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_rgtr2daisy is
port
(
		clk         : in  std_logic;

		rgtr_dv     : in  std_logic := '1';
		rgtr_id     : in  std_logic_vector; -- 8 bit
		rgtr_data   : in  std_logic_vector; -- 32 bit

		chaini_sel  : in  std_logic := '0';

		chaini_frm  : in  std_logic := '1';
		chaini_irdy : in  std_logic := '1';
		chaini_data : in  std_logic_vector; -- 8 bit

		chaino_frm  : out std_logic;
		chaino_irdy : out std_logic;
		chaino_data : out std_logic_vector -- 8 bit
);
end;

architecture beh of scopeio_rgtr2daisy is
	signal S_strm_frm  : std_logic;
	signal R_strm_frm  : std_logic;
	signal S_strm_irdy : std_logic;
	signal S_strm_data : std_logic_vector(chaino_data'range);
	signal R_shift     : std_logic_vector(2*rgtr_id'length + rgtr_data'length - 1 downto 0);
	signal R_pad0      : std_logic_vector(chaino_data'range) := (others => '0');
	constant C_cycles  : integer := R_shift'length / chaino_data'length;
	signal R_counter   : unsigned(unsigned_num_bits(C_cycles)-1 downto 0);
begin
	assert chaino_data'length=chaini_data'length 
		report "chaino_data'length not equal chaini_data'length"
		severity failure;
	process(clk)
	begin
		if rising_edge(clk) then
			if rgtr_dv = '1' then
				R_shift <= rgtr_data( 7 downto  0) -- going out last
				         & rgtr_data(15 downto  8)
				         & rgtr_data(23 downto 16)
				         & rgtr_data(31 downto 24) -- reverse bytes order
				         & x"03"                   -- data length-1 in bytes
				         & rgtr_id;                -- going out first
				R_counter <= to_unsigned(C_cycles - 1, R_counter'length);
				R_strm_frm <= '1';
			else
				if R_counter = 0 then
					R_strm_frm <= '0';
				else
					R_counter <= R_counter - 1;
				end if;
				R_shift <= R_pad0 & R_shift(R_shift'high downto R_pad0'length);
			end if;
		end if;
	end process;
	S_strm_frm <= R_strm_frm;
	S_strm_irdy <= R_strm_frm;
	S_strm_data <= R_shift(chaino_data'high downto 0);
	chaino_frm  <= chaini_frm  when chaini_sel='1' else S_strm_frm; 
	chaino_irdy <= chaini_irdy when chaini_sel='1' else S_strm_irdy;
	chaino_data <= chaini_data when chaini_sel='1' else S_strm_data;
end;
