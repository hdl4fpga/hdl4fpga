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

library ecp5u;
use ecp5u.components.all;

entity ecp5_sdrbaphy is
	generic (
		wl_delay   : time    := 0 ns;
		gear       : natural := 2;
		bank_size  : natural := 2;
		addr_size  : natural := 13;
		ba_latency : natural);
	port (
		grst       : in  std_logic;
		sclk       : in  std_logic;
		eclk       : in  std_logic;

		sys_rst    : in  std_logic_vector(0 to gear-1);
		sys_cs     : in  std_logic_vector(0 to gear-1);
		sys_cke    : in  std_logic_vector(0 to gear-1);
		sys_b      : in  std_logic_vector(gear*bank_size-1 downto 0);
		sys_a      : in  std_logic_vector(gear*addr_size-1 downto 0);
		sys_ras    : in  std_logic_vector(0 to gear-1);
		sys_cas    : in  std_logic_vector(0 to gear-1);
		sys_we     : in  std_logic_vector(0 to gear-1);
		sys_odt    : in  std_logic_vector(0 to gear-1);

		sdram_rst  : out std_logic;
		sdram_cs   : out std_logic;
		sdram_cke  : out std_logic;
		sdram_odt  : out std_logic;
		sdram_ras  : out std_logic;
		sdram_cas  : out std_logic;
		sdram_we   : out std_logic;
		sdram_b    : out std_logic_vector(bank_size-1 downto 0);
		sdram_a    : out std_logic_vector(addr_size-1 downto 0));
end;

library hdl4fpga;

architecture ecp5 of ecp5_sdrbaphy is

	signal rst : std_logic_vector(gear-1 downto 0) := (others => '-');
	signal cs  : std_logic_vector(gear-1 downto 0);
	signal cke : std_logic_vector(gear-1 downto 0);
	signal b   : std_logic_vector(gear*bank_size-1 downto 0);
	signal a   : std_logic_vector(gear*addr_size-1 downto 0);
	signal ras : std_logic_vector(gear-1 downto 0);
	signal cas : std_logic_vector(gear-1 downto 0);
	signal we  : std_logic_vector(gear-1 downto 0);
	signal odt : std_logic_vector(gear-1 downto 0);

	signal nodelay_sdram_rst : std_logic;
	signal nodelay_sdram_cs  : std_logic;
	signal nodelay_sdram_cke : std_logic;
	signal nodelay_sdram_odt : std_logic;
	signal nodelay_sdram_ras : std_logic;
	signal nodelay_sdram_cas : std_logic;
	signal nodelay_sdram_we  : std_logic;
	signal nodelay_sdram_b   : std_logic_vector(bank_size-1 downto 0);
	signal nodelay_sdram_a   : std_logic_vector(addr_size-1 downto 0);
begin

	sdram_rst  <= transport nodelay_sdram_rst after wl_delay;
	sdram_cs   <= transport nodelay_sdram_cs  after wl_delay;
	sdram_cke  <= transport nodelay_sdram_cke after wl_delay;
	sdram_odt  <= transport nodelay_sdram_odt after wl_delay;
	sdram_ras  <= transport nodelay_sdram_ras after wl_delay;
	sdram_cas  <= transport nodelay_sdram_cas after wl_delay;
	sdram_we   <= transport nodelay_sdram_we  after wl_delay;
	sdram_b    <= transport nodelay_sdram_b   after wl_delay;
	sdram_a    <= transport nodelay_sdram_a   after wl_delay;

	latency_b : block
	begin
    	b_e : entity hdl4fpga.latency
    	generic map (
    		n => sys_b'length,
    		d => (sys_b'range => ba_latency))
    	port map (
    		clk => sclk,
    		di  => sys_b,
    		do  => b);

    	a_e : entity hdl4fpga.latency
    	generic map (
    		n => sys_a'length,
    		d => (sys_a'range => ba_latency))
    	port map (
    		clk => sclk,
    		di  => sys_a,
    		do  => a);

    	sysrst_e : entity hdl4fpga.latency
    	generic map (
    		n => gear,
    		d => (0 to gear-1=> ba_latency))
    	port map (
    		clk   => sclk,
    		di => sys_rst,
    		do => rst);

    	cs_e : entity hdl4fpga.latency
    	generic map (
    		n => gear,
    		d => (0 to gear-1=> ba_latency))
    	port map (
    		clk   => sclk,
    		di => sys_cs,
    		do => cs);

    	cke_e : entity hdl4fpga.latency
    	generic map (
    		n => gear,
    		d => (0 to gear-1=> ba_latency))
    	port map (
    		clk   => sclk,
    		di => sys_cke,
    		do => cke);

    	ras_e : entity hdl4fpga.latency
    	generic map (
    		n => gear,
    		d => (0 to gear-1=> ba_latency))
    	port map (
    		clk   => sclk,
    		di => sys_ras,
    		do => ras);

    	cas_e : entity hdl4fpga.latency
    	generic map (
    		n => gear,
    		d => (0 to gear-1=> ba_latency))
    	port map (
    		clk   => sclk,
    		di => sys_cas,
    		do => cas);

    	we_e : entity hdl4fpga.latency
    	generic map (
    		n => gear,
    		d => (0 to gear-1=> ba_latency))
    	port map (
    		clk   => sclk,
    		di => sys_we,
    		do => we);

    	odt_e : entity hdl4fpga.latency
    	generic map (
    		n => gear,
    		d => (0 to gear-1=> ba_latency))
    	port map (
    		clk   => sclk,
    		di => sys_odt,
    		do => odt);
	end block;

	rst_i : entity hdl4fpga.ecp5_ogbx
	generic map (
		size => 1,
		gear => gear)
	port map (
		rst  => grst,
		sclk => sclk,
		d    => sys_rst,
		q(0) => nodelay_sdram_rst);

	cs_b : block
	begin

		gear1_g : if gear=1 generate
        	cke_i : entity hdl4fpga.ecp5_ogbx
        	generic map (
        		size => 1,
        		gear => gear)
        	port map (
        		rst  => grst,
        		sclk => sclk,
        		d    => cs,
        		q(0) => nodelay_sdram_cs);
		end generate;

		gear2_g : if gear=2 generate
			signal gear2_cs : std_logic;
		begin
			cs_i : oshx2a
			port map (
				rst  => grst,
				sclk => sclk,
				eclk => eclk, 
				d0   => cs(0),
				d1   => cs(1),
				q    => gear2_cs);
	
			delay_i : delayg
			generic map (
				del_mode => "DQS_ALIGNED_X2")
			port map (
				a => gear2_cs,
				z => nodelay_sdram_cs);
		end generate;

	end block;

	cke_i : entity hdl4fpga.ecp5_ogbx
	generic map (
		size => 1,
		gear => gear)
	port map (
		rst  => grst,
		sclk => sclk,
		d    => cke,
		q(0) => nodelay_sdram_cke);

	ras_i : entity hdl4fpga.ecp5_ogbx
	generic map (
		size => 1,
		gear => gear)
	port map (
		rst  => grst,
		sclk => sclk,
		d    => ras,
		q(0) => nodelay_sdram_ras);

	cas_i : entity hdl4fpga.ecp5_ogbx
	generic map (
		size => 1,
		gear => gear)
	port map (
		rst  => grst,
		sclk => sclk,
		d    => cas,
		q(0) => nodelay_sdram_cas);

	we_i : entity hdl4fpga.ecp5_ogbx
	generic map (
		size => 1,
		gear => gear)
	port map (
		rst  => grst,
		sclk => sclk,
		d    => we,
		q(0) => nodelay_sdram_we);

	odt_i : entity hdl4fpga.ecp5_ogbx
	generic map (
		size => 1,
		gear => gear)
	port map (
		rst  => grst,
		sclk => sclk,
		d    => odt,
		q(0) => nodelay_sdram_odt);

	b_i : entity hdl4fpga.ecp5_ogbx
	generic map (
		size => sdram_b'length,
		gear => gear)
	port map (
		sclk => sclk,
		d    => b,
		q    => nodelay_sdram_b);

	a_i : entity hdl4fpga.ecp5_ogbx
	generic map (
		size => sdram_a'length,
		gear => gear)
	port map (
		rst  => grst,
		sclk => sclk,
		d    => a,
		q    => nodelay_sdram_a);

end;



