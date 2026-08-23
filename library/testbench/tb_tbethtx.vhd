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

library hdl4fpga;

architecture tb_tbethtx of testbench is
	signal rst : std_logic;
	signal mii_clk : std_logic := '0';

	signal mii_req  : std_logic;
	signal mii_rdy  : std_logic;
	signal mii_txen : std_logic;
	signal mii_txd  : std_logic_vector(0 to 2-1);

begin

	rst <= '1', '0' after 10 ns;
	mii_clk <= not mii_clk after 1000 ns / 50 /2;

	process (rst, mii_clk)
		variable req : std_logic;
	begin
		if rst='1' then
			mii_req <= mii_rdy;
			req     := mii_rdy;
		elsif rising_edge(mii_clk) then
			if rst='0' then
				mii_req <= not req;
			end if;
		end if;
	end process;

	tbipoe_e : entity work.tb_ethtx
	generic map(
		sha  => "0x00_27_0e_0f_f5_95",
		data => "[" &
			"{ arp: {spa:192.168.0.2,tpa:192.168.0.14}}," &
			"{icmp: {spa:192.168.0.2,tpa:192.168.0.14}}]")
	port map (
		req  => mii_req,
		rdy  => mii_rdy,
		txc  => mii_clk,
		txen => mii_txen,
		txd  => mii_txd);

	process
	begin
		report "hello world";
		wait;
	end process;

end;
