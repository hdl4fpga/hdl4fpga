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

	constant word_byte : natural := sys_data'length/mii_txd'length;

end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture def of miitx_dma is

	signal wcntr : unsigned(0 to sys_addr'length);
	signal bcntr : unsigned(0 to unsigned_num_bits(word_byte-1));
begin

	process (mii_txc)
	begin
		if rising_edge(mii_txc) then
			if mii_treq='0' then
				bcntr <= to_unsigned(2**unsigned_num_bits(word_byte-1)-2, bcntr'length); 
			elsif bcntr(0)='1' then
				if wcntr(0)='0' then
					bcntr <= to_unsigned(2**unsigned_num_bits(word_byte-1)-2, bcntr'length); 
				end if;
			else
				bcntr <= bcntr - 1;
			end if;
		end if;
	end process;

	process (mii_txc)
	begin
		if rising_edge(mii_txc) then
			if mii_treq='0' then
				wcntr <= to_unsigned(2**sys_addr'length-2, wcntr'length); 
			elsif wcntr(0)='0' then
				if bcntr(0)='1' then
					wcntr <= wcntr - 1;
				end if;
			end if;
		end if;
	end process;
	sys_addr <= std_logic_vector(wcntr(1 to sys_addr'length));


	process (mii_txc, mii_treq)
		variable ena : std_logic;
	begin
		if mii_treq='0' then
			mii_txen <= '0';
			ena := '0';
		elsif rising_edge(mii_txc) then
			mii_txen <= ena and (not wcntr(0) or not bcntr(0));
			ena := not wcntr(0) or not bcntr(0);
		end if;
	end process;

	mii_txd  <= reverse (
		word2byte (
			word => sys_data ror (3*mii_txd'length mod sys_data'length),
			addr => std_logic_vector(bcntr(1 to bcntr'length-1))));
end;
