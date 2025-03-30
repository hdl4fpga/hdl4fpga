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
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity usbphy is
   	generic (
		oversampling : natural := 0;
		watermark    : natural := 0;
		bit_stuffing : natural := 6);
	port (
		tp    : out std_logic_vector(1 to 32);
		dp    : inout std_logic := 'Z';
		dn    : inout std_logic := 'Z';
		idle  : out std_logic;
		clk   : in  std_logic;
		cken  : buffer std_logic;

		phy_dv : out std_logic;
		phy_bs : out std_logic;
		phy_d  : out std_logic;

		txen  : in  std_logic := '0';
		txbs  : buffer std_logic;
		txd   : in  std_logic := '-';

		rxdv  : buffer std_logic;
		rxbs  : buffer std_logic;
		rxd   : buffer std_logic;
		rxerr : out std_logic);
end;

architecture def of usbphy is

	signal j     : std_logic;
	signal k     : std_logic;
	signal se0   : std_logic;
	signal s_k   : std_logic;
	signal s_j   : std_logic;
	signal s_se0 : std_logic;

	signal tx_tp : std_logic_vector(tp'range);
	signal echo : std_logic;
	signal phy_txdv : std_logic;
	signal phy_txbs : std_logic;
	signal phy_txd  : std_logic;
begin

	process (clk)
	begin
		if rising_edge(clk) then
			if cken='1' then
				if tx_tp(1)='1' then
					echo <= '1';
				elsif rxdv='0' then
					echo <= '0';
				end if;
			end if;
		end if;
	end process;

	phy_dv <= '1'      when phy_txdv='1' else rxdv when echo='0' else '0';
	phy_bs <= phy_txbs when phy_txdv='1' else rxbs;
	phy_d  <= phy_txd  when phy_txdv='1' else rxd;

	tp(1) <= '1'      when tx_tp(1)='1' else rxdv when echo='0' else '0';
	tp(2) <= tx_tp(2) when tx_tp(1)='1' else rxbs;
	tp(3) <= tx_tp(3) when tx_tp(1)='1' else rxd;

	linestates_p : process (clk)
		type states is (s_idle, s_sop, s_eop, s_resume, s_suspend);
		variable state : states;
	begin
		if rising_edge(clk) then
			case state is
			when s_idle =>
				if k='1' then
					idle  <= '0';
					state := s_sop;
				else
					idle  <= '1';
				end if;
			when s_sop =>
				if se0='1' then
					if cken='1' then
						state := s_eop;
					end if;
				end if;
			when s_resume =>
			when s_suspend =>
			when s_eop =>
				if j='1' then
					idle  <= '1';
					state := s_idle;
				end if;
			end case;
		end if;
	end process;

	oversampling_g : if oversampling/=0 generate
    	oversampling_p : process (clk)
			-- constant wm : natural := setif(watermark=0, (oversampling)/2, watermark);
			constant wm : natural := setif(watermark=0, (oversampling)/2, watermark);
    		variable cntr : natural range 0 to oversampling-1;
    		variable q    : std_logic;
			variable dp_s : std_logic;
			variable dn_s : std_logic;
    	begin
    		if rising_edge(clk) then
    			if (to_bit(q) xor to_bit(k))='1' then
    				cntr := oversampling-1;
    			elsif cntr=0 then
    				cntr := oversampling-1;
    			else
    				cntr := cntr - 1;
    			end if;
    			if cntr=wm then
    				cken <= '1';
    			else
    				cken <= '0';
    			end if;
    			q     := not dp_s and     dn_s;
    			s_k   <= not dp_s and     dn_s;
    			s_j   <=     dp_s and not dn_s;
    			s_se0 <= not dp_s and not dn_s;
				dp_s := dp;
				dn_s := dn;
    		end if;
			k   <= not dp_s and     dn_s;
			j   <=     dp_s and not dn_s;
			se0 <= not dp_s and not dn_s;
    	end process;
	end generate;
	
	nooversampling_g : if oversampling=0 generate
		k     <= not dp and     dn;
		j     <=     dp and not dn;
		se0   <= not dp and not dn;
		s_k   <= k;
		s_j   <= j;
		s_se0 <= se0;
		cken  <= '1';
	end generate;

	usbphyrx_e : entity hdl4fpga.usbphy_rx
   	generic map (
		bit_stuffing => bit_stuffing)
	port map (
		clk  => clk,
		cken => cken,
		k    => s_k,
		j    => s_j,
		se0  => s_se0,
		rxdv => rxdv,
		rxbs => rxbs,
		rxd  => rxd,
		err  => rxerr);
		
	usbphytx_e : entity hdl4fpga.usbphy_tx
	port map (
		tp   => tx_tp,
		clk  => clk,
		cken => cken,
		phy_dv => phy_txdv,
		phy_bs => phy_txbs,
		phy_d  => phy_txd,
		txen => txen,
		txbs => txbs,
		txd  => txd,
		txdp => dp,
		txdn => dn);

end;
