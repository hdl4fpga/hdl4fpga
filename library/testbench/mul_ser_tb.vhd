-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;
use hdl4fpga.base.all;

architecture mul_ser_tb of testbench is
	constant bin_digits : natural := 3;
	constant bcd_length : natural := 4;
	constant bcd_digits : natural := 1;

	signal clk         : std_logic := '0';
	signal ena         : std_logic := '1';
	signal bcd         : std_logic_vector(0 to 4-1);

	signal mul_req     : std_logic := '0';
	signal mul_rdy     : std_logic;
	signal dbdbbl_req  : std_logic;
	signal dbdbbl_rdy  : std_logic;
	signal dbdbbl_trdy : std_logic;

	signal a           : std_logic_vector(4-1 downto 0) := b"0111";
	signal b           : std_logic_vector((5+8)-1 downto 0) := b"0100_0000_01001";
	signal bin         : std_logic_vector(0 to bin_digits*((b'length+a'length+bin_digits-1)/bin_digits)-1);
begin
	clk <= not clk after 1 ns;

	process (clk)
	begin
		if rising_edge(clk) then
			if mul_req='0' then
				-- mul_req <= '1'; --not to_stdulogic(to_bit(mul_rdy));
			end if;
		end if;
	end process;
	mul_req <= not to_stdulogic(to_bit(dbdbbl_rdy));
	du_e : entity hdl4fpga.mul_ser
	generic map ( lsb => true)
	port map (
		clk => clk,
		ena => ena,
		req => mul_req,
		rdy => mul_rdy,
		a   => a,
		b   => b,
		s   => bin);

	dbdbbl_req <= to_stdulogic(to_bit(mul_rdy));
	bin2bcd_e : entity hdl4fpga.dbdbbl_seq
	generic map (
		bcd_width => 5,
		bcd_digits => 1)
	port map (
		clk  => clk,
		req  => dbdbbl_req,
		rdy  => dbdbbl_rdy,
		bcd_irdy => dbdbbl_trdy,
		bin  => bin,
		bcd  => bcd);
	
	process (bin)
	begin
		report to_string(bin);
	end process;

end;



