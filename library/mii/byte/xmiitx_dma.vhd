library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity miitx_dma is
	generic (
		xd_len : natural := 8);
    port (
		sys_addr : out std_logic_vector;
		sys_data : in  std_logic_vector;

        mii_txc  : in  std_logic;
		mii_treq : in  std_logic;
        mii_txen : out std_logic;
        mii_txd  : out std_logic_vector(0 to xd_len-1));
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture def of miitx_dma is
	constant word_byte : natural := sys_data'length/mii_txd'length;
	constant cntr_size : natural := sys_addr'length+unsigned_num_bits(word_byte-1);
	signal cntr : unsigned(cntr_size downto 0);
begin

	process (mii_txc)
	begin
		if rising_edge(mii_txc) then
			if mii_treq='0' then
				cntr <= to_unsigned(2**cntr_size-2, cntr'length); 
			elsif cntr(cntr'left)='0' then
				cntr <= cntr - 1;
			end if;

		end if;
	end process;
	sys_addr <= std_logic_vector(cntr(cntr_size-1 downto unsigned_num_bits(word_byte-1)));

	process (mii_txc, mii_treq)
	begin
		if mii_treq='0' then
			mii_txen <= '0';
		elsif rising_edge(mii_txc) then
			mii_txen <= '1';
		end if;
	end process;

	mii_txd  <= reverse(
		word2byte(
			word => sys_data ror mii_txd'length,
			addr => std_logic_vector(cntr(unsigned_num_bits(word_byte-1)-1 downto 0))));
end;
