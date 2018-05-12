--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.cgafont.all;

entity mii_debug is
	port (
		mii_rxc   : in  std_logic;
		mii_rxd   : in  std_logic_vector;
		mii_rxdv  : in  std_logic;

		mii_req   : in  std_logic;
		mii_txc   : in  std_logic;
		mii_txd   : out std_logic_vector;
		mii_txdv  : out std_logic;

		video_clk : in  std_logic;
		video_dot : out std_logic;
		video_hs  : out std_logic;
		video_vs  : out std_logic);
	end;

architecture struct of mii_debug is

	signal video_frm      : std_logic;
	signal video_hon      : std_logic;
	signal video_nhl      : std_logic;
	signal video_vld      : std_logic;
	signal video_vcntr    : std_logic_vector(11-1 downto 0);
	signal video_hcntr    : std_logic_vector(11-1 downto 0);
	signal mac_vld        : std_logic;
	signal pkt_vld        : std_logic;
	signal ip_vld         : std_logic;
begin

	eth_b : block
		signal pre_rdy  : std_logic;
		signal mac_rdy  : std_logic;
		signal mac_rxdv : std_logic;
		signal mac_rxd  : std_logic_vector(mii_rxd'range);

		constant mii_mymac : std_logic_vector := reverse(x"00_40_00_01_02_03", 8);
	begin

		mii_pre_e : entity hdl4fpga.miirx_pre 
		port map (
			mii_rxc  => mii_rxc,
			mii_rxd  => mii_rxd,
			mii_rxdv => mii_rxdv,
			mii_rdy  => pre_rdy);


		miimymac_e  : entity hdl4fpga.mii_mem
		generic map (
			mem_data => mii_mymac)
		port map (
			mii_txc  => mii_rxc,
			mii_treq => pre_rdy,
			mii_trdy => mac_rdy,
			mii_txen => mac_rxdv,
			mii_txd  => mac_rxd);

		macvld_b : block
			signal vld : std_logic;
		begin
			process (mii_rxc)
			begin
				if rising_edge(mii_rxc) then
					if pre_rdy='0' then
						vld <= '1';
					elsif mac_rdy='0' then
						vld <= vld and setif(mac_rxd=mii_rxd);
					end if;
				end if;
			end process;
			mac_vld <= vld and mac_rdy;
--			mac_vld <= pre_rdy;
		end block;

		ip_b: block
			constant tabindex : natural_vector(0 to 1)   := (0, 2*8/mii_txd'length);
			constant tabdata  : std_logic_vector := "1" & "0";

			function lookup (
				constant tabindex : natural_vector;
				constant tabdata  : std_logic_vector;
				constant lookup   : std_logic_vector) 
				return std_logic_vector is
				variable aux      : unsigned(0 to tabdata'length-1);
				variable retval   : std_logic_vector(0 to tabdata'length/tabindex'length-1);
			begin
				retval := (others => '0');
				aux    := unsigned(tabdata);
				for i in tabindex'range loop
					next when tabindex(i) < to_integer(unsigned(lookup));
					retval := std_logic_vector(aux(retval'range));
					aux    := aux rol retval'length;
				end loop;

				return retval;
			end;

			signal miiip_ena  : std_logic;
			signal miiip_rdy  : std_logic;
			signal miiip_rxdv : std_logic;
			signal miiip_rxd  : std_logic_vector(mii_rxd'range);
			signal cntr       : unsigned(0 to 5);

		begin

			process (mii_rxc)
			begin
				if rising_edge(mii_rxc) then
					if mac_vld='0' then
						cntr <= (others => '0');
					elsif cntr(0)='0' then
						cntr <= cntr + 1;
					end if;
				end if;
			end process;
			miiip_ena <= lookup(tabindex, tabdata, std_logic_vector(cntr))(0) and not cntr(0) and mac_vld;

			miiip_e : entity hdl4fpga.mii_mem
			generic map (
--				mem_data => reverse(x"0800"))
				mem_data => reverse(x"0025",8))
			port map (
				mii_txc  => mii_rxc,
				mii_treq => mac_vld,
				mii_trdy => miiip_rdy,
				mii_txen => miiip_rxdv,
				mii_txd  => miiip_rxd);

			process (mii_txc, miiip_rdy)
				variable cy  : std_logic;
				variable vld : std_logic;
			begin
				if rising_edge(mii_txc) then
					if mac_vld='0' then
						cy  := '1';
						vld := '0';
					elsif miiip_rxdv='1' then
						if cy='1' then
							if miiip_rxd/=mii_rxd then
								cy := '0';
							end if;
						end if;
						vld := cy;
					end if;
				end if;
				ip_vld <= miiip_rdy and cy;
			end process;

		end block;

	end block;
		
	cgaadapter_b : block
		signal font_col  : std_logic_vector(3-1 downto 0);
		signal font_row  : std_logic_vector(4-1 downto 0);
		signal font_addr : std_logic_vector(8+4-1 downto 0);
		signal font_line : std_logic_vector(8-1 downto 0);

		signal cga_clk   : std_logic;
		signal cga_ena   : std_logic;
		signal cga_rdata : std_logic_vector(ascii'range);
		signal cga_wdata : std_logic_vector(ascii'length*2-1 downto 0);
		signal cga_addr  : std_logic_vector(13-1 downto 0) := (others => '0');

		signal video_on  : std_logic;
	begin
	
		video_e : entity hdl4fpga.video_vga
		generic map (
			mode => 7,
			n    => 11)
		port map (
			clk   => video_clk,
			hsync => video_hs,
			vsync => video_vs,
			hcntr => video_hcntr,
			vcntr => video_vcntr,
			don   => video_hon,
			frm   => video_frm,
			nhl   => video_nhl);

		cgabram_b : block
			signal video_addr : std_logic_vector(14-1 downto 0);

			signal rd_addr    : std_logic_vector(video_addr'range);
			signal rd_data    : std_logic_vector(cga_rdata'range);
			signal rxd8       : std_logic_vector(0 to 8-1);
		begin

			process (cga_clk)
				variable edge : std_logic := '0';
			begin
				if rising_edge(cga_clk) then
					if cga_ena='1' then
						cga_addr <= std_logic_vector(unsigned(cga_addr) + 1);
					elsif (mac_vld='0' or mii_rxdv='0') and edge='1' then
						cga_addr <= std_logic_vector(unsigned(cga_addr) + 1);
					end if;
					edge := mac_vld and mii_rxdv;
				end if;
			end process;

			cga_clk  <= mii_rxc;
			pkt_vld <= ip_vld and mii_rxdv;

			process (mii_rxc, mii_rxd, pkt_vld)
				variable aux  : unsigned(0 to 8-mii_rxd'length-1);
				variable cntr : unsigned(0 to 8/mii_rxd'length-1);
			begin
				if mii_rxd'length < rxd8'length then
					if rising_edge(mii_rxc) then
						if pkt_vld='0' then
							cntr := (1 to cntr'length-1 => '0') & "1";
						else
							aux := aux rol mii_rxd'length; 
							aux(mii_rxd'range) := unsigned(mii_rxd);
							cntr := cntr rol 1;
						end if;
						cga_ena <= cntr(0);
					end if;
					rxd8 <= std_logic_vector(aux) & mii_rxd;
				else
					rxd8 <= mii_rxd;
					cga_ena <= pkt_vld;
				end if;
			end process;

			process (mii_rxd)
				constant tab  : ascii_vector(0 to 16-1) := to_ascii("0123456789ABCDEF");
				variable rxd  : unsigned(rxd8'range);
				variable data : unsigned(2*ascii'length-1 downto 0);
			begin
				rxd := unsigned(reverse(rxd8));
				for i in 0 to rxd'length/4-1 loop
					data := data ror ascii'length;
					data(ascii'range) := unsigned(tab(to_integer(rxd(0 to 4-1))));
					rxd  := rxd sll 4;
				end loop;
				cga_wdata <= std_logic_vector(data);
			end process;

			process (video_vcntr, video_hcntr)
				variable aux : unsigned(video_addr'range);
			begin
				aux := resize(unsigned(video_vcntr) srl 4, video_addr'length);
				aux := ((aux sll 4) - aux) sll 4;  -- * (1920/8)
				aux := aux + (unsigned(video_hcntr) srl 3);
				video_addr <= std_logic_vector(aux);
			end process;

			rdaddr_e : entity hdl4fpga.align
			generic map (
				n => video_addr'length,
				d => (video_addr'range => 1))
			port map (
				clk => video_clk,
				di  => video_addr,
				do  => rd_addr);

			cgaram_e : entity hdl4fpga.dpram
			port map (
				wr_clk  => cga_clk,
				wr_ena  => cga_ena,
				wr_addr => cga_addr,
				wr_data => cga_wdata,
				rd_addr => rd_addr,
				rd_data => rd_data);

			rddata_e : entity hdl4fpga.align
			generic map (
				n => cga_rdata'length,
				d => (cga_rdata'range => 1))
			port map (
				clk => video_clk,
				di  => rd_data,
				do  => cga_rdata);

		end block;

		vsync_e : entity hdl4fpga.align
		generic map (
			n => font_row'length,
			d => (font_row'range => 2))
		port map (
			clk => video_clk,
			di  => video_vcntr(4-1 downto 0),
			do  => font_row);

		hsync_e : entity hdl4fpga.align
		generic map (
			n => font_col'length,
			d => (font_col'range => 4))
		port map (
			clk => video_clk,
			di  => video_hcntr(font_col'range),
			do  => font_col);

		font_addr <= cga_rdata & font_row;

		cgarom_e : entity hdl4fpga.rom
		generic map (
			synchronous => 2,
			bitrom => psf1cp850x8x16)
		port map (
			clk  => video_clk,
			addr => font_addr,
			data => font_line);

		don_e : entity hdl4fpga.align
		generic map (
			n => 1,
			d => (1 to 1 => 4))
		port map (
			clk => video_clk,
			di(0)  => video_hon,
			do(0)  => video_on);

		video_dot <= word2byte(font_line, font_col)(0) and video_on;

	end block;

	du : entity hdl4fpga.miitx_dhcp
	port map (
		mii_txc  => mii_txc,
		mii_treq => mii_req,
		mii_txdv => mii_txdv,
		mii_txd  => mii_txd);

end;
