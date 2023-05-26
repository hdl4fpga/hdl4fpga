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

library ecp5u;
use ecp5u.components.all;

entity ecp5_sdrdqphy is
	generic (
		wl_delay   : time := 0 ns;

		byteno     : natural;
		bypass     : boolean := false;
		debug      : boolean := false;
		gear       : natural;
		byte_size  : natural;
		rd_fifo    : boolean := true;
		rd_align   : boolean := true;
		wr_fifo    : boolean := true;

		taps       : natural);
	port (
		rst        : in  std_logic;
		sclk       : in  std_logic;
		eclk       : in  std_logic;
		ddrdel     : in  std_logic;
		pause      : in  std_logic;

		phy_wlreq  : in  std_logic;
		phy_wlrdy  : buffer std_logic;
		phy_rlreq  : in  std_logic := 'U';
		phy_rlrdy  : buffer std_logic;
		read_rdy   : in  std_logic;
		read_req   : buffer std_logic;
		phy_locked : buffer std_logic;

		sys_sti    : in  std_logic_vector(gear-1 downto 0);
		sys_sto    : buffer std_logic_vector(gear-1 downto 0);
		sys_dmt    : in  std_logic_vector(gear-1 downto 0) := (others => '0');
		sys_dmi    : in  std_logic_vector(gear-1 downto 0) := (others => '-');
		sys_dmo    : out std_logic_vector(gear-1 downto 0);
		sys_dqo    : out std_logic_vector(gear*byte_size-1 downto 0);
		sys_dqt    : in  std_logic_vector(gear-1 downto 0);
		sys_dqv    : in  std_logic_vector(gear-1 downto 0) := (others => '0');
		sys_dqi    : in  std_logic_vector(gear*byte_size-1 downto 0);
		sys_dqsi   : in  std_logic_vector(gear-1 downto 0);
		sys_dqst   : in  std_logic_vector(gear-1 downto 0);

		sdram_dqs  : inout std_logic;
		sdram_dqst : buffer std_logic;
		sdram_dqso : buffer std_logic;

		sdram_dm   : inout std_logic;
		sdram_dmo  : buffer std_logic;
		sdram_dq   : inout std_logic_vector(byte_size-1 downto 0);
		sdram_dqt  : buffer std_logic_vector(byte_size-1 downto 0);
		sdram_dqi  : in std_logic_vector(byte_size-1 downto 0) := (others => '-');
		sdram_dqo  : buffer std_logic_vector(byte_size-1 downto 0);

		tp         : out std_logic_vector(1 to 32));

end;

library hdl4fpga;
use hdl4fpga.base.all;

architecture ecp5 of ecp5_sdrdqphy is

	signal srst         : std_logic;

	signal dqsr90       : std_logic;
	signal dqsw         : std_logic;
	signal dqsw270      : std_logic;
	
	signal dqt          : std_logic_vector(sys_dqt'range);
	signal dqi          : std_logic_vector(sys_dqi'range);
	signal dqo          : std_logic_vector(sys_dqo'range);
	signal dmi          : std_logic_vector(sys_dmi'range);
	signal sto          : std_logic_vector(sys_sto'range);

	signal wle          : std_logic;

	signal rdpntr       : std_logic_vector(3-1 downto 0);
	signal wrpntr       : std_logic_vector(3-1 downto 0);

	signal rd           : std_logic;
	signal lat          : std_logic_vector(3-1 downto 0);
	signal rdclksel     : std_logic_vector(3-1 downto 0);
	signal wlpha        : std_logic_vector(8-1 downto 0);
	signal burstdet     : std_logic;
	signal dqs_pause    : std_logic;
	signal datavalid    : std_logic;

	signal adjstep_req  : std_logic;
	signal adjstep_rdy  : std_logic;

	signal rlpause_rdy  : std_logic;
	signal rlpause_req  : std_logic;
	signal rlpause1_rdy : std_logic;
	signal rlpause1_req : std_logic;
	signal wlpause_rdy  : std_logic;
	signal wlpause_req  : std_logic;
	signal lv_pause     : std_logic;

	constant delay      : time := 10*0.625 ns;

	signal wlstep_req   : std_logic;
	signal wlstep_rdy   : std_logic;
	signal dqi0         : std_logic;

	signal sdram_dmt    : std_logic;

	constant wldelay : time := 0.5 ns;
begin

	process (rst, sclk)
	begin
		if rst='1' then
			srst <= '1';
		elsif rising_edge(sclk) then
			srst <= '0';
		end if;
	end process;

	rl_b : block
		signal step_req : std_logic;
		signal step_rdy : std_logic;
		signal adj_req  : std_logic;
		signal adj_rdy  : std_logic;

	begin

		gear1or2 : if gear=1 or gear=2 generate
			lat : entity hdl4fpga.latency
			generic map (
				n => sys_sti'length,
				d => (0 to sys_sti'length-1 => setif(bypass,0,1)))
			port map (
				clk => sclk,
				di  => sys_sti,
				do  => sto);
		end generate;

		gear4_g : if gear=4 generate
    		adjbrst_e : entity hdl4fpga.adjbrst
    		generic map (
    			debug      => debug)
    		port map (
    			sclk       => sclk,
    			adj_req    => adj_req,
    			adj_rdy    => adj_rdy,
    			pause_req  => rlpause_req,
    			pause_rdy  => rlpause_rdy,
    			step_req   => step_req,
    			step_rdy   => step_rdy,
    			read       => rd,
    			datavalid  => datavalid,
    			burstdet   => burstdet,
    			locked     => phy_locked,
    			lat        => lat,
    			readclksel => rdclksel);

    		lat_b : block
    			signal q : std_logic_vector(0 to 5-1);
    		begin
    			q(0) <= sys_sti(sys_sti'right);
    			process(sclk)
    			begin
    				if rising_edge(sclk) then
    					q(1 to q'right) <= q(0 to q'right-1);
    				end if;
    			end process;
    			rd <= multiplex(q(0 to q'right-1), lat, 1)(0);
    		end block;

			sto <= (others => datavalid);
			tp(1 to 7) <= lat & rdclksel & phy_locked;
		end generate;

		adjust_p : process (srst, sclk, read_req)
			type states is (s_start, s_adj, s_paused);
			variable state : states;
		begin
			if rising_edge(sclk) then
				if srst='1' then
					phy_rlrdy <= to_stdulogic(to_bit(phy_rlreq));
					state     := s_start;
					adj_req <= '0';
				elsif (phy_rlrdy xor to_stdulogic(to_bit(phy_rlreq)))='1' then
					case state is
					when s_start =>
						adj_req <= not adj_rdy;
						state   := s_adj;
					when s_adj =>
						if (adj_rdy xor to_stdulogic(to_bit(adj_req)))='0' then
							rlpause1_req <= not rlpause1_rdy;
							state        := s_paused;
						end if;
					when s_paused =>
						if (rlpause1_req xor rlpause1_rdy)='0' then
							phy_rlrdy <= to_stdulogic(to_bit(phy_rlreq));
							state     := s_start;
						end if;
					end case;
				else
					rlpause1_req <= rlpause1_rdy;
					state        := s_start;
				end if;
			end if;
		end process;

		step_p : process (sclk, read_req)
			type states is (s_start, s_read);
			variable state : states;
		begin
			if rising_edge(sclk) then
				if srst='1' then
					state := s_start;
					step_rdy <= to_stdulogic(to_bit(step_req));
				elsif (adj_rdy xor to_stdulogic(to_bit(adj_req)))='1' then
					case state is
					when s_start =>
						if (step_rdy xor to_stdulogic(to_bit(step_req)))='1' then
							read_req <= not read_rdy;
							state    := s_read;
						end if;
					when s_read =>
						if (read_rdy xor to_stdulogic(to_bit(read_req)))='0' then
							step_rdy <= step_req;
							state    := s_start;
						end if;
					end case;
				else
					step_rdy <= to_stdulogic(to_bit(step_req));
					state := s_start;
				end if;
			end if;
		end process;

	end block;

	wl_b : block
		signal d : std_logic_vector(0 to 0);
	begin

		d(0) <= transport to_stdulogic(to_bit(dqi0)) after delay;
		adjdqs_e : entity hdl4fpga.adjpha
		generic map (
			dtaps    => 1,
			taps     => taps)
		port map (
			edge     => std_logic'('0'),
			clk      => sclk,
			rst      => srst,
			req      => phy_wlreq,
			rdy      => phy_wlrdy,
			step_req => wlstep_req,
			step_rdy => wlstep_rdy,
			smp      => d,
			delay    => wlpha);

	end block;
	wlpause_req <= wlstep_req;
	wlstep_rdy  <= wlpause_rdy;

	dqsi_b : block
		signal latch      : std_logic;
   		signal readclksel : std_logic_vector(2 downto 0);
		signal dyndelay   : std_logic_vector(7 downto 0);
		signal dqsi_buf   : std_logic;
	begin
		dqsi_buf <= transport sdram_dqs after delay;
		pause_b : block
	
			signal pause_req : bit;
			signal pause_rdy : bit;

		begin

			pause_req <= to_bit(rlpause_req) xor to_bit(rlpause1_req) xor to_bit(wlpause_req);
			process (srst, sclk)
				variable cntr : unsigned(0 to 4);
			begin
				if rising_edge(sclk) then
					if srst='1' then
						pause_rdy <= pause_req;
					elsif (pause_rdy xor pause_req)='0' then
						lv_pause <= '0';
						cntr := (others => '0');
					elsif cntr(0)='0' then
						if cntr(1)='0' then
							lv_pause <= '1';
						else
							lv_pause <= '0';
						end if;
						cntr := cntr + 1;
					else
						lv_pause  <= '0';
						pause_rdy <= pause_req;
					end if;
					if cntr(0 to 2)="001" then
						latch <= '1';
					else 
						latch <= '0';
					end if;
				end if;
			end process;
	
			process (srst, sclk, pause_rdy )
			begin
				if rising_edge(sclk) then
					if srst='1' then
						wlpause_rdy  <= to_stdulogic(to_bit(wlpause_req));
						rlpause1_rdy <= to_stdulogic(to_bit(rlpause1_req));
						rlpause_rdy  <= to_stdulogic(to_bit(rlpause_req));
					elsif (pause_rdy xor pause_req)='0' then
						wlpause_rdy  <= to_stdulogic(to_bit(wlpause_req));
						rlpause1_rdy <= to_stdulogic(to_bit(rlpause1_req));
						rlpause_rdy  <= to_stdulogic(to_bit(rlpause_req));
					end if;
				end if;
			end process;
	
		end block;

		process (sclk)
		begin
			if rising_edge(sclk) then
				if latch='1' then
					dyndelay   <= wlpha;
					readclksel <= rdclksel;
				end if;
			end if;
		end process;

		dqs_pause <= pause or lv_pause;
		dqsbufm_i : dqsbufm 
		port map (
			rst       => rst,
			sclk      => sclk,
			eclk      => eclk,

			ddrdel    => ddrdel,
			pause     => dqs_pause,

			dqsi      => dqsi_buf,
			dqsr90    => dqsr90,

			read1     => rd,
			read0     => rd,
			readclksel2 => readclksel(2),
			readclksel1 => readclksel(1),
			readclksel0 => readclksel(0),

			rdpntr2   => rdpntr(2),
			rdpntr1   => rdpntr(1),
			rdpntr0   => rdpntr(0),
			wrpntr2   => wrpntr(2),
			wrpntr1   => wrpntr(1),
			wrpntr0   => wrpntr(0),

			burstdet  => burstdet,
			datavalid => datavalid,
			rdmove    => '0',
			wrmove    => '0',
			rdcflag   => open,
			wrcflag   => open,

			rdloadn   => '0',
			rddirection => '0',
			wrloadn   => '0',
			wrdirection => '0',

			dyndelay0 => dyndelay(0),
			dyndelay1 => dyndelay(1),
			dyndelay2 => dyndelay(2),
			dyndelay3 => dyndelay(3),
			dyndelay4 => dyndelay(4),
			dyndelay5 => dyndelay(5),
			dyndelay6 => dyndelay(6),
			dyndelay7 => dyndelay(7),

			dqsw      => dqsw,
			dqsw270   => dqsw270);
		end block;

	iddr_g : for i in byte_size-1 downto 0 generate
		signal d : std_logic;
		signal z : std_logic;
	begin
		d <= transport sdram_dq(i) after delay;
		dqi0_g : if i=0 generate
			dqi0 <= z;
		end generate;

		delay_i : delayg
		generic map (
			del_mode => "DQS_ALIGNED_X2")
		port map (
			a => d,
			z => z);

		no_bypass_g : if bypass generate
			shuffle_g : for j in gear-1 downto 0 generate
				dqo(j*byte_size+i) <= d;
			end generate;
		end generate;

		bypass_g : if not bypass generate
			signal q : std_logic_vector(gear-1 downto 0);
		begin
			gear1or2_g : if gear=1 or gear=2 generate
			begin
				ibx_i : entity hdl4fpga.ecp5_igbx
				generic map (
					gear => gear)
				port map (
					rst  => rst,
					sclk => sdram_dqs,
					d(0) => d,
					q    => q);
			end generate;

			gear4_g : if gear=4 generate
				iddrx2_i : iddrx2dqa
				port map (
					rst     => rst,
					sclk    => sclk,
					eclk    => eclk,
					dqsr90  => dqsr90,
					rdpntr2 => rdpntr(2),
					rdpntr1 => rdpntr(1),
					rdpntr0 => rdpntr(0),
					wrpntr2 => wrpntr(2),
					wrpntr1 => wrpntr(1),
					wrpntr0 => wrpntr(0),
					d       => z,
					q0      => q(3),
					q1      => q(2),
					q2      => q(1),
					q3      => q(0));
			end generate;

			shuffle_g : for j in q'range generate
				dqo(j*byte_size+i) <= q(j);
			end generate;

		end generate;
	end generate;

	rdfifo_g : if rd_fifo generate

        latsto_e : entity hdl4fpga.latency
        generic map (
        	n => gear,
        	d => (0 to gear-1 => 1))
        port map (
        	clk => sclk,
        	di  => sto,
        	do  => sys_sto);

		gear_g : for i in gear-1 downto 0 generate
			signal in_clk  : std_logic;
			signal in_rst  : std_logic;
			signal out_rst : std_logic;
			signal test   : std_logic_vector(byte_size-1 downto 0);
		begin

			-- process (sdram_dqs)
				-- variable cntr : unsigned(test'range);
			-- begin
				-- if rising_edge(sdram_dqs) then
					-- if sto(i)='0' then
						-- cntr := to_unsigned(1-byteno, cntr'length);
					-- else
						-- cntr := cntr + 2;
					-- end if;
					-- test <= std_logic_vector(cntr);
				-- end if;
			-- end process;

			in_clk  <= sdram_dqs when bypass else sclk;
			in_rst  <= not sto(i);
			out_rst <= not sys_sto(i);
			fifo_i : entity hdl4fpga.phy_iofifo
			port map (
				in_clk   => sdram_dqs,
				in_rst   => in_rst,
				in_data  => dqo(byte_size*(i+1)-1 downto byte_size*i),
				-- in_data  => test,
				out_clk  => sclk,
				out_rst  => out_rst,
				out_data => sys_dqo(byte_size*(i+1)-1 downto byte_size*i));
		end generate;

	end generate;
	
	no_rdfifo_g : if not rd_fifo generate
		sys_sto  <= sto;
		sys_dqo  <= dqo;
	end generate;

	dmi_g : block
		signal d : std_logic;
	begin
		gear1or2_g : if gear=1 or gear=2 generate
			ibx_i : entity hdl4fpga.ecp5_igbx
			generic map (
				gear => gear)
			port map (
				rst  => rst,
				sclk => sdram_dqs,
				d(0) => sdram_dm,
				q    => sys_dmo);
		end generate;

		gear4_g : if gear=4 generate
			delay_i : delayg
			generic map (
				del_mode => "DQS_ALIGNED_X2")
			port map (
				a => sdram_dm,
				z => d);

			iddrx2_i : iddrx2dqa
			port map (
				rst     => rst,
				sclk    => sclk,
				eclk    => eclk,
				dqsr90  => dqsr90,
				rdpntr0 => rdpntr(0),
				rdpntr1 => rdpntr(1),
				rdpntr2 => rdpntr(2),
				wrpntr0 => wrpntr(0),
				wrpntr1 => wrpntr(1),
				wrpntr2 => wrpntr(2),
				d       => d,
				q0      => sys_dmo(3),
				q1      => sys_dmo(2),
				q2      => sys_dmo(1),
				q3      => sys_dmo(0));
			end generate;
	end block;

	datao_b : block


	begin

		wrfifo_g : if wr_fifo generate
			gear_g : for i in gear-1 downto 0 generate
				signal in_rst  : std_logic;
				signal in_data  : std_logic_vector(sys_dqi'length/gear downto 0);
				signal out_rst  : std_logic;
				signal out_data : std_logic_vector(sys_dqi'length/gear downto 0);
			begin

				in_rst <= not sys_dqv(sys_dqv'right);
				process (sclk)
				begin
					if rising_edge(sclk) then
						out_rst <= not sys_dqv(i);
					end if;
				end process;

				in_data <= sys_dmi(i) & sys_dqi(byte_size*(i+1)-1 downto byte_size*i);
				fifo_i : entity hdl4fpga.phy_iofifo
				port map (
					in_clk   => sclk,
					in_rst   => in_rst,
					in_data  => in_data,
					out_clk  => sclk,
					out_rst  => out_rst,
					out_data => out_data);
				dmi(i) <= out_data(out_data'left);
				dqi(byte_size*(i+1)-1 downto byte_size*i) <= out_data(out_data'left-1 downto 0);
			end generate;
		end generate;
		
		no_wrfifo_g : if not wr_fifo generate
			dqi <= sys_dqi;
			dmi <= sys_dmi;
		end generate;

		wle <= to_stdulogic(to_bit(phy_wlrdy)) xor phy_wlreq;

		dqt <= sys_dqt when wle='0' else (others => '1');
		oddr_g : for i in 0 to byte_size-1 generate
			signal di : std_logic_vector(gear-1 downto 0);
			signal sw : std_logic;
		begin

			process (sclk)
			begin
				if rising_edge(sclk) then
					sw <= phy_rlrdy xor to_stdulogic(to_bit(phy_rlreq));
				end if;
			end process;

			process (sw, dqi)
			begin
				for j in di'range loop
					if sw='1' then
						if j mod 2=0 then
							di(j) <= '1';
						else
							di(j) <= '0';
						end if;
					else
						di(j) <= dqi(byte_size*j+i);
					end if;
				end loop;
			end process;

			ogbx_i : entity hdl4fpga.ecp5_ogbx
			generic map (
				gear => gear)
			port map (
				rst     => rst,
				sclk    => sclk,
				eclk    => eclk,
				dqsw270 => dqsw270,
				t       => dqt,
				tq(0)   => sdram_dqt(i),
				d       => di,
				q(0)    => sdram_dqo(i));

			sdram_dq(i) <= transport sdram_dqo(i) after wl_delay when sdram_dqt(i)='0' else 'Z' after wl_delay;
		end generate;

		dm_b : block
		begin

			ogbx_i : entity hdl4fpga.ecp5_ogbx
			generic map (
				gear => gear)
			port map (
				rst     => rst,
				sclk    => sclk,
				eclk    => eclk,
				dqsw270 => dqsw270,
				t       => sys_dmt,
				tq(0)   => sdram_dmt,
				d       => dmi,
				q(0)    => sdram_dmo);

			sdram_dm <= transport sdram_dmo after wl_delay when sdram_dmt='0' else 'Z' after wl_delay;

		end block;
	end block;

	dqso_b : block 
		signal dqsi : std_logic_vector(sys_dqsi'range);
		signal dqst : std_logic_vector(sys_dqst'range);
	begin


		gear4_g : if gear=4 generate
			dqst <= sys_dqst when wle='0' else (others => '0');
			dqsi <= sys_dqsi when wle='0' else (others => '1');

			tshx2dqsa_i : tshx2dqsa
			port map (
				rst  => rst,
				sclk => sclk,
				eclk => eclk,
				dqsw => dqsw,
				t0   => dqst(2*1+1),
				t1   => dqst(2*0+1),
				q    => sdram_dqst);
	
			oddrx2dqsb_i : oddrx2dqsb
			port map (
				rst  => rst,
				sclk => sclk,
				eclk => eclk,
				dqsw => dqsw,
				d0   => '0',
				d1   => dqsi(2*1),
				d2   => '0',
				d3   => dqsi(2*0),
				q    => sdram_dqso);

			sdram_dqs <= transport sdram_dqso after wl_delay when sdram_dqst='0' else 'Z' after wl_delay;
		end generate;


	end block;

end;
