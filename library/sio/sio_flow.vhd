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
		so_frm  : buffer std_logic;
		so_irdy : buffer std_logic;
		so_trdy : in  std_logic := '1';
		so_data : buffer std_logic_vector;

		si_clk  : in  std_logic := '-';
		si_frm  : in  std_logic;
		si_irdy : in  std_logic;
		si_trdy : out std_logic;
		si_data : in  std_logic_vector;

		tx_clk  : in  std_logic;
		tx_frm  : out std_logic;
		tx_irdy : buffer std_logic;
		tx_trdy : in  std_logic := '1';
		tx_data : buffer std_logic_vector;
		tp      : out std_logic_vector(1 to 32));

end;

architecture struct of sio_flow is

	signal rgtr_frm   : std_logic;
	signal rgtr_irdy  : std_logic;
	signal rgtr_trdy  : std_logic;
	signal rid_act    : std_logic;
	signal pyl_act    : std_logic;
	signal rgtr_frms  : std_logic_vector(0 to 2-1);
	signal rgtr_irdys : std_logic_vector(0 to 2-1);
	signal rgtr_trdys : std_logic_vector(0 to 2-1);

	signal acktx_data : std_logic_vector(tx_data'range);
	signal dup_equ    : std_logic := '0';

	alias rgtr0_frm  is rgtr_frms(0);
	alias rgtr0_irdy is rgtr_irdys(0);
	alias rgtr1_frm  is rgtr_frms(1);
	alias rgtr1_irdy is rgtr_irdys(1);

	constant thada_length : natural :=     -- lattice semi complains
		hdo(frames)**".format.mac.hwda" +  -- lattice semi complains
		hdo(frames)**".format.ipv4.da";    -- lattice semi complains
	constant thada_value : string := natural'image(thada_length);  -- lattice semi complains
	constant rgtr0_frame : string := compact('{'                       &
		 "thada:" & thada_value                            & ',' &
			"sp:" & string'(hdo(frames)**".format.udp.dp") & ',' &
			"dp:" & string'(hdo(frames)**".format.udp.dp") & '}');

	signal rgtr0_acts  : std_logic_vector(0 to length(rgtr0_frame));
	signal rgtr0_frms  : std_logic_vector(rgtr0_acts'range);
	signal rgtr0_irdys : std_logic_vector(rgtr0_acts'range);

	alias thada_act   is rgtr0_acts(0);
	alias sp_act      is rgtr0_acts(1);
	alias length_act  is rgtr0_acts(1);
	alias dp_act      is rgtr0_acts(2);

	alias thada_frm   is rgtr0_frms(0);
	alias sp_frm      is rgtr0_frms(1);
	alias length_frm  is rgtr0_frms(1);
	alias dp_frm      is rgtr0_frms(2);

	alias thada_irdy  is rgtr0_irdys(0);
	alias sp_irdy     is rgtr0_irdys(1);
	alias length_irdy is rgtr0_irdys(1);
	alias dp_irdy     is rgtr0_irdys(2);

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
		pyl_act   => pyl_act,
		rgtr_frm  => rgtr_frm,
		rgtr_irdy => rgtr_irdy,
		rgtr_trdy => rgtr_trdy);

	siodecode_e : entity hdl4fpga.sio_decode
	generic map (
		rids => "[0x00,0x01]")
	port map (
		clk        => rx_clk,
		frm        => rgtr_frm,
		irdy       => rgtr_irdy,
		trdy       => rgtr_trdy,
		data       => rx_data,
		rid_act    => rid_act,
		pyl_act    => pyl_act,
		pyl_frms   => rgtr_frms,
		pyl_irdys  => rgtr_irdys,
		pyl_trdys  => rgtr_trdys);
	rgtr_trdys <= (others => '1');

	rxrgtr_i : entity hdl4fpga.frame_decode
	generic map (
		frame => rgtr0_frame,
		size  => rx_data'length)
	port map (
		clk   => rx_clk,
		frm   => rgtr0_frm,
		irdy  => rgtr0_irdy,
		acts  => rgtr0_acts,
		frms  => rgtr0_frms,
		irdys => rgtr0_irdys);

	dup_b : block

		signal mr_irdy   : std_logic;
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

		process (rgtr1_irdy, rx_clk)
			variable equ : std_logic;
		begin
			if rising_edge(rx_clk) then
				if equ='0' then
					if (rgtr_frm or rgtr_irdy)='1' then
						equ := rgtr1_frm;
					end if;
				elsif (rgtr_frm or rgtr_irdy)='0' then
					equ := '0';
				elsif (rgtr_frm or not rgtr_trdy)='0' then
					equ := '0';
				end if;
			end if;
			mr_irdy <= equ and rgtr1_irdy;
		end process;

		process (rx_clk)
		begin
			if rising_edge(rx_clk) then
				if (fcs_sb and fcs_vld and not dup_equ)='1' then
					ram_t <= not ram_t;
				end if;
			end if;
		end process;

		process (rx_clk)
		begin
			if rising_edge(rx_clk) then
				if fcs_vld='1' then
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
			mr_frm  => rgtr_frm,
			mr_irdy => mr_irdy,
			mr_data => rx_data,
			sl_frm  => cmp_frm,
			sl_irdy => cmp_irdy,
			sl_data => cmp_data,
			equ     => cmp_equ);

		ram1_frm  <= rgtr_frm and not ram_t;
		ram1_irdy <= mr_irdy  and not ram_t;
		ram2_frm  <= rgtr_frm and ram_t;
		ram2_irdy <= mr_irdy  and ram_t;

		ram1_i : entity hdl4fpga.sio_ram
		generic map (
			bitdata => (0 to 8-1 => '-'))
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
			bitdata => (0 to 16-1 => '-'))
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

			signal mode      : std_logic_vector(0 to 1);
			signal rxsp_frm  : std_logic;
			signal rxsp_irdy : std_logic;
			signal length_data : std_logic_vector(rx_data'range);
			signal src_irdy  : std_logic;
			signal src_trdy  : std_logic;
			signal src_data  : std_logic_vector(rx_data'range);
			signal dst_irdy  : std_logic;
			signal dst_trdy  : std_logic;
			signal dst_data  : std_logic_vector(tx_data'range);
			signal txdp_frm  : std_logic;
			signal txdp_irdy : std_logic;
			signal txdp_data : std_logic_vector(tx_data'range);
		begin

			rxsp_frm  <= sp_frm;
			rxsp_irdy <= sp_irdy;

			mode <= 
				"10" when (fcs_sb and     fcs_vld)='1' else
				"00" when (fcs_sb and not fcs_vld)='1' else
				"11";

			length_i : entity hdl4fpga.sio_mux
			port map (
				mux_data => reverse(x"0003",8),
				sio_clk  => rx_clk,
				sio_frm  => length_frm,
				sio_irdy => length_irdy,
				sio_trdy => open,
				so_data  => length_data);

			src_irdy <= thada_irdy or length_irdy or dp_irdy;
			src_data <= 
				length_data when length_act='1' else
				rx_data;

			dp_i : entity hdl4fpga.sio_ram
			generic map (
				bitdata => x"0000")
			port map (
				si_clk  => rx_clk,
				si_frm  => rxsp_frm,
				si_irdy => rxsp_irdy,
				si_data => rx_data,
				so_clk  => tx_clk,
				so_frm  => txdp_frm,
				so_irdy => txdp_irdy,
				so_data => txdp_data);

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

			dst_b : block
				constant header_length : natural :=     -- lattice semi complains
					hdo(frames)**".format.mac.hwda"   + -- lattice semi complains
					hdo(frames)**".format.ipv4.da"    + -- lattice semi complains
					hdo(frames)**".format.udp.length" + -- lattice semi complains
					hdo(frames)**".format.udp.sp";      -- lattice semi complains
				constant header_value : string := natural'image(header_length);  -- lattice semi complains
				constant frame : string := compact('{'                       &
					"header:" & header_value                           & ',' &
						"dp:" & string'(hdo(frames)**".format.udp.dp") & '}');

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

			begin

				frame_i : entity hdl4fpga.frame_decode
				generic map (
					frame => frame,
					size  => tx_data'length)
				port map (
					clk   => tx_clk,
					frm   => dst_irdy,
					irdy  => dst_irdy,
					acts  => acts,
					frms  => frms,
					irdys => irdys,
					trdys => trdys);
				trdys <= (others => acktx_trdy);
				rxsp_frm  <= dp_frm;
				rxsp_irdy <= dp_irdy;

				acktx_frm  <= dst_irdy;
				acktx_irdy <= dst_irdy;
				dst_trdy   <= acktx_trdy;

				acktx_data <=
					dst_data  when header_act='1' else
					txdp_data; -- when     dp_act='1' else

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

	fifo_b : block
		constant tha_length: natural := 
			16 +
			hdo(frames)**".format.mac.hwda" +
			hdo(frames)**".format.ipv4.da"  +
			hdo(frames)**".format.udp.sp";
		constant tha_value : string := natural'image(tha_length);
		constant dst_frame : string := compact('{' &
			"tha:" & tha_value & ',' & --"tha:" & natural'image( -- Lattice Semi error
			" dp:" & string'(hdo(frames)**".format.udp.dp") & '}');

		signal commit    : std_logic;
		signal rollback  : std_logic;
		signal src_irdy  : std_logic;
		signal dst_irdy  : std_logic;
		signal dst_trdy  : std_logic;
		signal dst_data  : std_logic_vector(so_data'range);
		signal dst_acts  : std_logic_vector(0 to length(dst_frame));
		signal dst_frms  : std_logic_vector(0 to length(dst_frame));
		signal dst_trdys : std_logic_vector(0 to length(dst_frame)) := (others => '1');
		signal dp_data   : std_logic_vector(so_data'range);

	begin

		src_irdy <= 
			rx_irdy when rgtr_frms=(rgtr_frms'range => '0') else
			'1'     when rgtr0_irdys(0)='1' else
			'1'     when rgtr0_irdys(2)='1' else
			'0';

		commit   <= (not fcs_sb or     fcs_vld); -- and not dup_equ;
		rollback <= (not fcs_sb or not fcs_vld);
		fifo_i : entity hdl4fpga.fifo
		generic map (
			latency   => 1,
			check_sov => true,
			check_dov => true,
			max_depth => (2048*8)/rx_data'length)
		port map (
			src_clk  => rx_clk,
			src_irdy => src_irdy,
			src_trdy => open,
			src_data => rx_data,

			mode(0)  => commit,
			mode(1)  => rollback,

			dst_clk  => so_clk,
			dst_irdy => dst_irdy,
			dst_trdy => dst_trdy,
			dst_data => dst_data);

		dst_trdy <= '0' when dst_frms(1)='1' else so_trdy;
		dst_i : entity hdl4fpga.frame_decode
		generic map (
			frame => dst_frame,
			size  => so_data'length)
		port map (
			clk   => so_clk,
			frm   => dst_irdy,
			irdy  => dst_irdy,
			frms  => dst_frms,
			trdys => dst_trdys,
			acts  => dst_acts);
		dst_trdys <= (others => so_trdy);

		dp_i : entity hdl4fpga.sio_ram
		generic map (
			bitdata => (0 to 16-1 => '-'))
		port map (
			si_clk  => rx_clk,
			si_frm  => rgtr0_frms(1),
			si_irdy => rgtr0_irdys(1),
			si_data => rx_data,
			so_clk  => so_clk,
			so_frm  => dst_frms(1),
			so_irdy => so_trdy,
			so_data => dp_data);

		so_frm  <= dst_irdy;
		so_irdy <= dst_irdy;
		so_data <= dp_data when dst_frms(1)='1' else dst_data;

	end block;

end;
