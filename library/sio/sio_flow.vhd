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
use hdl4fpga.hdo.all;
use hdl4fpga.base.all;
use hdl4fpga.ipoepkg.all;

entity sio_flow is
	generic (
		reply   : boolean := true;
		debug   : boolean := false);
	port (
		rx_clk  : in  std_logic;
		rx_frm  : in  std_logic;
		rx_irdy : in  std_logic;
		rx_trdy : out std_logic;
		rx_data : in  std_logic_vector;
		fcs_sb  : in  std_logic;
		fcs_vld : in  std_logic;

		so_clk  : in  std_logic;
		so_frm  : out std_logic;
		so_irdy : out std_logic;
		so_trdy : in  std_logic := '1';
		so_data : out std_logic_vector;

		si_clk  : in  std_logic := '-';
		si_frm  : in  std_logic;
		si_irdy : in  std_logic;
		si_trdy : out std_logic;
		si_data : in  std_logic_vector;

		tx_clk  : in  std_logic;
		tx_frm  : out std_logic;
		tx_irdy : out std_logic;
		tx_trdy : in  std_logic := '1';
		tx_data : out std_logic_vector;
		tp      : out std_logic_vector(1 to 32));

end;

architecture struct of sio_flow is

	signal rgtr_frm   : std_logic;
	signal rgtr_irdy  : std_logic;
	signal rgtr_trdy  : std_logic;
	signal rid_act    : std_logic;
	signal len_act    : std_logic;
	signal len_frms   : std_logic_vector(0 to 2-1);
	signal len_irdys  : std_logic_vector(0 to 2-1);
	signal len_trdys  : std_logic_vector(0 to 2-1) := (others => '1');
	signal pyl_act    : std_logic;
	signal pyl_frms   : std_logic_vector(0 to 2-1);
	signal pyl_irdys  : std_logic_vector(0 to 2-1);
	signal pyl_trdys  : std_logic_vector(0 to 2-1);

	signal acktx_data : std_logic_vector(tx_data'range);
	signal dup_equ    : std_logic := '0';

	alias pyl0_frm  is pyl_frms(0);
	alias pyl0_irdy is pyl_irdys(0);
	alias pyl0_trdy is pyl_trdys(0);
	alias pyl1_frm  is pyl_frms(1);
	alias pyl1_irdy is pyl_irdys(1);
	alias pyl1_trdy is pyl_trdys(1);
	alias len1_frm  is len_frms(1);
	alias len1_irdy is len_irdys(1);
	alias len1_trdy is len_trdys(1);

	constant pyl0_frame : string := compact('{'                      &
		   "tha:" & string'(hdo(frames)**".format.mac.hwda")    & ',' &
		"length:" & string'(hdo(frames)**".format.ipv4.length") & ',' &
		    "da:" & string'(hdo(frames)**".format.ipv4.da")     & ',' &
		    "sp:" & string'(hdo(frames)**".format.udp.sp")      & ',' &
		    "dp:" & string'(hdo(frames)**".format.udp.dp") & '}');

	signal pyl0_acts  : std_logic_vector(0 to length(pyl0_frame));
	signal pyl0_frms  : std_logic_vector(pyl0_acts'range);
	signal pyl0_irdys : std_logic_vector(pyl0_acts'range);

	alias tha_act     is pyl0_acts(0);
	alias length_act  is pyl0_acts(1);
	alias da_act      is pyl0_acts(2);
	alias sp_act      is pyl0_acts(3);
	alias dp_act      is pyl0_acts(4);

	alias tha_frm     is pyl0_frms(0);
	alias length_frm  is pyl0_frms(1);
	alias da_frm      is pyl0_frms(2);
	alias sp_frm      is pyl0_frms(3);
	alias dp_frm      is pyl0_frms(4);

	alias tha_irdy    is pyl0_irdys(0);
	alias length_irdy is pyl0_irdys(1);
	alias da_irdy     is pyl0_irdys(2);
	alias sp_irdy     is pyl0_irdys(3);
	alias dp_irdy     is pyl0_irdys(4);

	signal tx_frms  : std_logic_vector(0 to 2-1) := (others => '0');
	signal tx_irdys : std_logic_vector(0 to 2-1) := (others => '0');
	signal tx_trdys : std_logic_vector(0 to 2-1) := (others => '1');

begin

	siosin_e : entity hdl4fpga.sio_sin
	port map (
		clk       => rx_clk,
		frm       => rx_frm,
		irdy      => rx_irdy,
		trdy      => rx_trdy,
		data      => rx_data,
		rid_act   => rid_act,
		len_act   => len_act,
		pyl_act   => pyl_act,
		rgtr_frm  => rgtr_frm,
		rgtr_irdy => rgtr_irdy,
		rgtr_trdy => rgtr_trdy);

	siodecode_e : entity hdl4fpga.sio_decode
	generic map (
		rids => "[0x00,0x01]")
	port map (
		clk       => rx_clk,
		frm       => rgtr_frm,
		irdy      => rgtr_irdy,
		trdy      => rgtr_trdy,
		data      => rx_data,
		rid_act   => rid_act,
		len_act   => len_act,
		len_frms  => len_frms,
		len_irdys => len_irdys,
		len_trdys => len_trdys,
		pyl_act   => pyl_act,
		pyl_frms  => pyl_frms,
		pyl_irdys => pyl_irdys,
		pyl_trdys => pyl_trdys);

	rxrgtr_i : entity hdl4fpga.frame_decode
	generic map (
		frame => pyl0_frame,
		size  => rx_data'length)
	port map (
		clk   => rx_clk,
		frm   => pyl0_frm,
		irdy  => pyl0_irdy,
		trdy  => pyl0_trdy,
		acts  => pyl0_acts,
		frms  => pyl0_frms,
		irdys => pyl0_irdys);

	dup_b : block

		signal cmp_frm   : std_logic;
		signal cmp_irdy  : std_logic;
		signal cmp_data  : std_logic_vector(rx_data'range);
		signal cmp2_data : std_logic_vector(rx_data'range);
		signal cmp1_data : std_logic_vector(rx_data'range);
		signal cmp_equ   : std_logic;

		signal ram1_frm  : std_logic;
		signal ram1_irdy : std_logic;
		signal ram2_frm  : std_logic;
		signal ram2_irdy : std_logic;
		signal ram_t     : std_logic := '0';

	begin

		process (rx_clk)
		begin
			if rising_edge(rx_clk) then
				if fcs_sb='1' then
					if (fcs_vld and not dup_equ)='1' then
						ram_t <= not ram_t;
					end if;
					dup_equ <= '0';
				elsif cmp_equ='1' then
					dup_equ <= '1';
				end if;
			end if;
		end process;

		cmp_data  <= 
			cmp1_data when not ram_t='0' else
			cmp2_data;

		cmp_i : entity hdl4fpga.sio_cmp
		port map (
			clk     => rx_clk,
			mr_frm  => pyl1_frm,
			mr_irdy => pyl1_irdy,
			mr_trdy => pyl1_trdy,
			mr_data => rx_data,
			sl_frm  => cmp_frm,
			sl_irdy => cmp_irdy,
			sl_data => cmp_data,
			equ     => cmp_equ);

		ram1_frm  <= pyl1_frm  and not ram_t;
		ram1_irdy <= pyl1_irdy and not ram_t;
		ram2_frm  <= pyl1_frm  and ram_t;
		ram2_irdy <= pyl1_irdy and ram_t;

		ram1_i : entity hdl4fpga.sio_ram
		generic map (
			bitdata => x"10")
--			bitdata => (0 to 8-1 => '-'))
		port map (
			si_clk  => rx_clk,
			si_frm  => ram1_frm,
			si_irdy => ram1_irdy,
			si_data => rx_data,
			so_clk  => rx_clk,
			so_frm  => cmp_frm,
			so_irdy => cmp_irdy,
			so_data => cmp1_data);

		ram2_i : entity hdl4fpga.sio_ram
		generic map (
			bitdata => x"90")
			--bitdata => (0 to 8-1 => '-'))
		port map (
			si_clk  => rx_clk,
			si_frm  => ram2_frm,
			si_irdy => ram2_irdy,
			si_data => rx_data,
			so_clk  => rx_clk,
			so_frm  => cmp_frm,
			so_irdy => cmp_irdy,
			so_data => cmp2_data);

		ack_b : if reply generate

			alias  acktx_frm  is tx_frms(1);
			alias  acktx_irdy is tx_irdys(1);
			alias  acktx_trdy is tx_trdys(1);

			signal mode        : std_logic_vector(0 to 1);
			signal length_data : std_logic_vector(rx_data'range);
			signal src_irdy    : std_logic;
			signal src_trdy    : std_logic;
			signal src_data    : std_logic_vector(rx_data'range);
			signal dst_irdy    : std_logic;
			signal dst_trdy    : std_logic;
			signal dst_data    : std_logic_vector(tx_data'range);
			signal txdp_frm    : std_logic;
			signal txdp_irdy   : std_logic;
			signal txdp_data   : std_logic_vector(tx_data'range);
			signal bridge      : std_logic;

		begin

			mode <= 
				"10" when (fcs_sb and     (fcs_vld and dup_equ))='1' else
				"00" when (fcs_sb and not (fcs_vld and dup_equ))='1' else
				"11";

			length_i : entity hdl4fpga.sio_mux
			port map (
				mux_data => reverse(x"0003",8),
				sio_clk  => rx_clk,
				sio_frm  => length_frm,
				sio_irdy => length_irdy,
				sio_trdy => open,
				so_data  => length_data);

			process (pyl_frms, pyl_irdys, rx_frm, rx_clk)
				type states is (s_pyl0, s_bridge, s_pyl1);
				variable state : states;
			begin
				if rising_edge(rx_clk) then
					if rx_frm='0' then
						state := s_pyl0;
					else
						case state is
						when s_pyl0 =>
							if pyl0_frm='1' then
								state := s_bridge;
							end if;
						when s_bridge =>
							if pyl1_frm='1' then
								state := s_pyl1;
							end if;
						when s_pyl1 =>
							if pyl1_frm='0' then
								state := s_pyl0;
							end if;
						end case;
					end if;
				end if;
				if rx_frm='0' then
					bridge <= '0';
				elsif (pyl0_frm or pyl0_irdy)='1' then
					bridge <= '0';
				elsif state=s_bridge then
					bridge <= '1';
				elsif (pyl1_frm or pyl1_irdy)='1' then
					bridge <= '1';
				else
					bridge <= '0';
				end if;
			end process;

			src_irdy <= tha_irdy or length_irdy or da_irdy or dp_irdy or (bridge and rx_irdy);
			src_data <= 
				length_data when length_act='1' else
				rx_data;

			fifo_i : entity hdl4fpga.fifo
			generic map (
				latency   => 1,
				check_sov => true,
				check_dov => true,
				max_depth => (64*8)/rx_data'length)
			port map (
				mode     => mode,
				src_clk  => rx_clk,
				src_irdy => src_irdy,
				src_trdy => src_trdy,
				src_data => src_data,

				dst_clk  => tx_clk,
				dst_irdy => dst_irdy,
				dst_trdy => dst_trdy,
				dst_data => dst_data);

			dp_i : entity hdl4fpga.sio_ram
			generic map (
				bitdata => x"0000")
			port map (
				si_clk  => rx_clk,
				si_frm  => sp_frm,
				si_irdy => sp_irdy,
				si_data => rx_data,
				so_clk  => tx_clk,
				so_frm  => txdp_frm,
				so_irdy => txdp_irdy,
				so_data => txdp_data);

			tx_b : block
				constant header_length : natural :=     -- lattice semi complains
					hdo(frames)**".format.mac.hwda"   + -- lattice semi complains
					hdo(frames)**".format.udp.length" + -- lattice semi complains
					hdo(frames)**".format.ipv4.da"    + -- lattice semi complains
					hdo(frames)**".format.udp.sp";      -- lattice semi complains
				constant header_value : string := natural'image(header_length);  -- lattice semi complains
				constant frame : string := compact('{'                       &
					"header:" & header_value                           & ',' &
						"dp:" & string'(hdo(frames)**".format.udp.dp") & '}');

				signal frm   : std_logic;
				signal irdy  : std_logic;
				signal fin   : std_logic;
				signal acts  : std_logic_vector(0 to length(frame));
				signal frms  : std_logic_vector(acts'range);
				signal irdys : std_logic_vector(acts'range);
				signal trdys : std_logic_vector(acts'range);

				alias header_act  is acts(0);
				alias dp_act      is acts(1);

				alias header_frm  is frms(0);
				alias dp_frm      is frms(1);

				alias header_irdy is irdys(0);
				alias dp_irdy     is irdys(1);

				alias header_trdy is trdys(0);
				alias dp_trdy     is trdys(1);

			begin

				frm_p : process (dst_irdy, tx_clk)
					variable acktx_rdy : std_logic := '0';
					variable acktx_req : std_logic := '0';
				begin
					if rising_edge(tx_clk) then
						if dst_irdy='1' then
							acktx_req := not acktx_rdy;
						elsif (acktx_rdy xor acktx_req)='1' then
							if fin='1' then
								acktx_rdy := acktx_req;
							end if;
						end if;
					end if;
					frm <= (acktx_rdy xor acktx_req) and dst_irdy;
				end process;

				irdy <= dst_irdy;
				frame_i : entity hdl4fpga.frame_decode
				generic map (
					frame => frame,
					size  => tx_data'length)
				port map (
					clk   => tx_clk,
					frm   => frm,
					irdy  => irdy,
					fin   => fin,
					acts  => acts,
					frms  => frms,
					irdys => irdys,
					trdys => trdys);
				trdys     <= (others => acktx_trdy);
				txdp_frm  <= dp_frm;
				txdp_irdy <= dp_irdy and acktx_trdy;

				acktx_frm  <= frm;
				acktx_irdy <= irdy;
				dst_trdy   <= '0' when dp_act='1' else acktx_trdy;

				acktx_data <=
					txdp_data when dp_act='1' else
					dst_data;

			end block;

		end generate;

	end block;

	artibiter_b : block
		signal gntd : std_logic_vector(0 to 2-1);
	begin

		tx_frms(0)  <= si_frm;
		tx_irdys(0) <= si_irdy;
		si_trdy     <= tx_trdys(0);

		arbiter_i : entity hdl4fpga.mii_arbiter
		port map (
			clk   => tx_clk,
			gntd  => gntd,
			frms  => tx_frms,
			irdys => tx_irdys,
			trdys => tx_trdys,
			frm   => tx_frm,
			irdy  => tx_irdy,
			trdy  => tx_trdy);

		tx_data <=
			si_data    when gntd(0)='1' else
			acktx_data when gntd(1)='1' else
			(tx_data'range => '-');
	end block;

	so_b : block
		signal mode     : std_logic_vector(0 to 1);
		signal src_irdy : std_logic;
		signal dst_irdy : std_logic;
		signal dst_trdy : std_logic;
		signal dst_data : std_logic_vector(so_data'range);

		signal txdp_frm  : std_logic;
		signal txdp_irdy : std_logic;
		signal txdp_data : std_logic_vector(tx_data'range);

	begin

		src_irdy <= 
			rx_irdy when   pyl0_irdy='0' else
			'1'     when    tha_irdy='1' else
			'1'     when length_irdy='1' else
			'1'     when     da_irdy='1' else
			'1'     when     dp_irdy='1' else
			'0';

		mode <= 
			"10" when (fcs_sb and     (fcs_vld and  not dup_equ))='1' else
			"00" when (fcs_sb and not (fcs_vld and  not dup_equ))='1' else
			"11";

		fifo_i : entity hdl4fpga.fifo
		generic map (
			latency   => 1,
			check_sov => true,
			check_dov => true,
			max_depth => (2048*8)/rx_data'length)
		port map (
			mode     => mode,
			src_clk  => rx_clk,
			src_irdy => src_irdy,
			src_trdy => open,
			src_data => rx_data,

			dst_clk  => so_clk,
			dst_irdy => dst_irdy,
			dst_trdy => dst_trdy,
			dst_data => dst_data);

		dp_i : entity hdl4fpga.sio_ram
		generic map (
			bitdata => x"0000")
		port map (
			si_clk  => rx_clk,
			si_frm  => sp_frm,
			si_irdy => sp_irdy,
			si_data => rx_data,
			so_clk  => tx_clk,
			so_frm  => txdp_frm,
			so_irdy => txdp_irdy,
			so_data => txdp_data);

		tx_b : block
			constant rid_size : natural := 8;
			constant len_size : natural := 8;
			constant header_length : natural :=     -- lattice semi complains
				rid_size+len_size +
				hdo(frames)**".format.mac.hwda"   + -- lattice semi complains
				hdo(frames)**".format.udp.length" + -- lattice semi complains
				hdo(frames)**".format.ipv4.da"    + -- lattice semi complains
				hdo(frames)**".format.udp.sp";      -- lattice semi complains
			constant header_value : string := natural'image(header_length);  -- lattice semi complains
			constant frame : string := compact('{'                       &
				"header:" & header_value                           & ',' &
					"dp:" & string'(hdo(frames)**".format.udp.dp") & '}');

			alias frm   is dst_irdy;
			alias irdy  is dst_irdy;
			signal fin   : std_logic;
			signal acts  : std_logic_vector(0 to length(frame));
			signal frms  : std_logic_vector(acts'range);
			signal irdys : std_logic_vector(acts'range);
			signal trdys : std_logic_vector(acts'range);

			alias header_act  is acts(0);
			alias dp_act      is acts(1);

			alias header_frm  is frms(0);
			alias dp_frm      is frms(1);

			alias header_irdy is irdys(0);
			alias dp_irdy     is irdys(1);

			alias header_trdy is trdys(0);
			alias dp_trdy     is trdys(1);
		begin

			frame_i : entity hdl4fpga.frame_decode
			generic map (
				frame => frame,
				size  => so_data'length)
			port map (
				clk   => so_clk,
				frm   => frm,
				irdy  => irdy,
				fin   => fin,
				acts  => acts,
				frms  => frms,
				irdys => irdys,
				trdys => trdys);
			trdys     <= (others => so_trdy);
			dst_trdy  <= '0' when dp_act='1' else so_trdy;
			txdp_frm  <= dp_frm;
			txdp_irdy <= dp_irdy and so_trdy;

			so_frm  <= frm;
			so_irdy <= irdy;

			so_data <=
				txdp_data when dp_act='1' else
				dst_data;

		end block;

	end block;

end;
