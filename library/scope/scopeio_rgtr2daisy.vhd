library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_rgtr2daisy is
port
(
		clk         : in  std_logic;
		
		pointer_dv  : in  std_logic := '0';
		pointer_x   : in  std_logic_vector(10 downto 0);
		pointer_y   : in  std_logic_vector(10 downto 0);

		rgtr_dv     : in  std_logic := '0';
		rgtr_id     : in  std_logic_vector; -- 8 bit
		rgtr_data   : in  std_logic_vector; -- 32 bit

		chaini_frm  : in  std_logic := '0';
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
	constant C_rgtr_packet_length : integer := 2*rgtr_id'length + rgtr_data'length; -- 6 bytes
	constant C_pointer_packet_length : integer := 5*rgtr_id'length; -- 5 bytes
	signal R_shift     : std_logic_vector(C_pointer_packet_length + C_rgtr_packet_length - 1 downto 0);
	signal R_pad0      : std_logic_vector(chaino_data'range) := (others => '0');
	signal S_reverse_packet, S_normal_packet: std_logic_vector(R_shift'range);
	constant C_pointer_and_rgtr_cycles  : integer := R_shift'length / chaino_data'length;
	constant C_pointer_only_cycles: integer := C_pointer_packet_length / chaino_data'length;
	signal R_counter   : unsigned(unsigned_num_bits(C_pointer_and_rgtr_cycles)-1 downto 0);
begin
	assert chaino_data'length=chaini_data'length 
		report "chaino_data'length not equal chaini_data'length"
		severity failure;
	S_normal_packet <= x"15" & x"02" & "00" & pointer_y & pointer_x
		      & rgtr_id & x"03" & rgtr_data;
	G_bytes_reversal:
	for i in 0 to S_reverse_packet'length/8-1 generate
		S_reverse_packet(i*8+7 downto i*8) <= -- reverse(S_normal_packet(i*2+1 downto i*2));
		  --  reverse(S_normal_packet(i*8+7 downto i*8));
		    S_normal_packet(i*8+1)
		  & S_normal_packet(i*8+0)
		  & S_normal_packet(i*8+3)
		  & S_normal_packet(i*8+2)
		  & S_normal_packet(i*8+5)
		  & S_normal_packet(i*8+4)
		  & S_normal_packet(i*8+7)
		  & S_normal_packet(i*8+6);
		  --  S_normal_packet(i*8+6)
		  --& S_normal_packet(i*8+7)
		  --& S_normal_packet(i*8+4)
		  --& S_normal_packet(i*8+5)
		  --& S_normal_packet(i*8+2)
		  --& S_normal_packet(i*8+3)
		  --& S_normal_packet(i*8+0)
		  --& S_normal_packet(i*8+1);
	end generate;
	process(clk)
	begin
		if rising_edge(clk) then
			-- if R_strm_frm is 1 the request will be dropped
			-- to prevent overwriting currently active serializing
			if R_counter = 0 then
				R_strm_frm <= '0';
				if (rgtr_dv = '1' or pointer_dv = '1') then
					if R_strm_frm = '0' and (chaini_frm = '0' and chaini_irdy = '0') then
						R_shift <= S_reverse_packet;
						if rgtr_dv = '1' and rgtr_id /= x"00" then
							R_counter <= to_unsigned(C_pointer_and_rgtr_cycles - 1, R_counter'length);
						else
							R_counter <= to_unsigned(C_pointer_only_cycles - 1, R_counter'length);
						end if;
						R_strm_frm <= '1';
					end if;
				end if;
			else
				R_counter <= R_counter - 1;
				R_shift <= R_shift(R_shift'high - R_pad0'length downto 0) & R_pad0;
			end if;
		end if;
	end process;
	S_strm_frm  <= R_strm_frm;
	S_strm_irdy <= R_strm_frm;
	S_strm_data <= R_shift(R_shift'high downto R_shift'length - chaino_data'length);
	chaino_frm  <= chaini_frm  when R_strm_frm='0' else S_strm_frm; 
	chaino_irdy <= chaini_irdy when R_strm_frm='0' else S_strm_irdy;
	chaino_data <= chaini_data when R_strm_frm='0' else S_strm_data;
end;
