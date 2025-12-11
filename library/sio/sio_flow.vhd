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

entity sio_flow is
	generic (
		debug   : boolean := false);
	port (
		rx_clk  : in std_logic;
		rx_frm  : in std_logic;
		rx_irdy : in std_logic;
		rx_trdy : out std_logic;
		rx_data : in std_logic_vector;
		fcs_sb  : in  std_logic;
		fcs_vld : in  std_logic;

		so_clk  : in std_logic;
		so_frm  : buffer std_logic;
		so_irdy : buffer std_logic;
		so_trdy : in  std_logic := '1';
		so_data : buffer std_logic_vector;

		si_clk  : in  std_logic := '-';
		si_frm  : in  std_logic;
		si_irdy : in  std_logic;
		si_trdy : out std_logic;
		si_data : in  std_logic_vector;

		tx_clk  : in std_logic;
		tx_frm  : out std_logic;
		tx_irdy : buffer std_logic;
		tx_trdy : in  std_logic := '1';
		tx_data : buffer std_logic_vector;
		tp      : out std_logic_vector(1 to 32));

end;

architecture struct of sio_flow is

	signal rgtr_frm  : std_logic;
	signal rgtr_irdy : std_logic;
	signal rgtr_trdy : std_logic;
	signal rid_act   : std_logic;

	signal pyl_frm   : std_logic_vector(0 to 2-1);
	signal pyl_irdy  : std_logic_vector(0 to 2-1);

	signal tx_frms   : std_logic_vector(0 to 2-1);
	signal tx_irdys  : std_logic_vector(0 to 2-1);
	signal tx_trdys  : std_logic_vector(0 to 2-1) := (others => '1');

	alias  ackrx_frm  is tx_frms(0);
	alias  ackrx_irdy is tx_irdys(0);
	alias  ackrx_trdy is tx_trdys(0);

	signal acktx_data : std_logic_vector(tx_data'range);
	signal dup_equ    : std_logic := '0';

begin

	siosin_e : entity hdl4fpga.sio_sin
	port map (
		clk       => rx_clk,
		frm       => rx_frm,
		irdy      => rx_irdy,
		data      => rx_data,
		rid_act   => rid_act,
		rgtr_frm  => rgtr_frm,
		rgtr_irdy => rgtr_irdy,
		rgtr_trdy => rgtr_trdy);

	siodecode_e : entity hdl4fpga.sio_decode
	generic map (
		rids => "[0x00, 0x01]")
	port map (
		clk      => rx_clk,
		frm      => rgtr_frm,
		irdy     => rgtr_irdy,
		trdy     => rgtr_trdy,
		data     => rx_data,
		rid_act  => rid_act,
		pyl_frm  => pyl_frm,
		pyl_irdy => pyl_irdy);

	ack_b : block

		signal rom_data  : std_logic_vector(rx_data'range);
		signal ram_frm   : std_logic;
		signal ram_irdy  : std_logic;
		signal ram_data  : std_logic_vector(rx_data'range);
		signal data_frm  : std_logic;
		signal data_irdy : std_logic;

		signal fifo_frm  : std_logic;
		signal fifo_irdy : std_logic;
		signal fifo_trdy : std_logic;
		signal fifo_data : std_logic_vector(rx_data'range);

		signal commit0   : std_logic;
		signal rollback0 : std_logic;
		signal commit    : std_logic;
		signal rollback  : std_logic;

	begin

		process (rgtr_irdy, pyl_frm(1), rx_clk)
			variable equ : std_logic;
		begin
			if rising_edge(rx_clk) then
				if equ='0' then
					if (rgtr_frm or rgtr_irdy)='1' then
						equ := pyl_frm(1);
					end if;
				elsif (rgtr_frm or rgtr_irdy)='0' then
					equ := '0';
				elsif (rgtr_frm or not rgtr_trdy)='0' then
					equ := '0';
				end if;
			end if;
			ram_irdy <= (pyl_frm(1) or equ) and rgtr_irdy;
		end process;

		rom_i : entity hdl4fpga.sio_rom
		generic map (
			bitdata => reverse(x"01"))
		port map (
			so_clk  => rx_clk,
			so_frm  => rgtr_frm,
			so_irdy => rgtr_irdy,
			so_data => rom_data);

		ram_data <=
			rx_data  when ram_irdy='1' else
			rom_data;

		tx_frms(0) <= tx_irdys(0);

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
				mr_irdy => ram_irdy,
				mr_data => ram_data,
				sl_frm  => cmp_frm,
				sl_irdy => cmp_irdy,
				sl_data => cmp_data,
				equ     => cmp_equ);

			ram1_frm  <= ackrx_frm  and not ram_t;
			ram1_irdy <= ackrx_irdy and not ram_t;
			ram2_frm  <= ackrx_frm  and ram_t;
			ram2_irdy <= ackrx_irdy and ram_t;

			ram1_i : entity hdl4fpga.sio_ram
			generic map (
				bitdata => (0 to 16-1 => '-'))
				-- bitdata => reverse(x"0042",8))
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
				-- bitdata => (0 to 16-1 => '-'))
				bitdata => reverse(x"0042",8))
			port map (
				si_clk  => rx_clk,
				si_frm  => ram2_frm,
				si_irdy => ram2_irdy,
				si_data => rx_data,
				so_clk  => rx_clk,
				so_frm  => cmp_frm,
				so_irdy => cmp_irdy,
				so_data => cmp2_data);

		end block;

		process (pyl_irdy, rx_clk)
			type states is (s_start, s_bridge);
			variable state : states;
		begin
			if rising_edge(rx_clk) then
				if (rgtr_frm or rgtr_irdy)='1' then
					case state is
					when s_start =>
						if pyl_irdy(0)='1' then
							state := s_bridge;
						end if;
					when s_bridge =>
						if pyl_irdy(1)='1' then
							state := s_start;
						end if;
					end case;
				else
					state := s_start;
				end if;
			end if;
			if state=s_bridge then
				commit0 <= '1';
			else
				commit0 <= pyl_irdy(0) or pyl_irdy(1);
			end if;
		end process;

		rollback0 <= not commit0;
		fifo0_i : entity hdl4fpga.fifo
		generic map (
			check_sov => true,
			check_dov => true,
			max_depth => (4*8)/rx_data'length)
		port map (
			src_clk    => rx_clk,
			src_irdy   => rgtr_irdy,
			src_trdy   => open,
			src_data   => rx_data,

			commit     => commit0,
			rollback   => rollback0,

			dst_clk    => rx_clk,
			dst_irdy   => fifo_irdy,
			dst_trdy   => fifo_trdy,
			dst_data   => fifo_data);

		commit   <= fcs_sb and     (fcs_vld and not dup_equ);
		rollback <= fcs_sb and not (fcs_vld and not dup_equ);
		fifo_i : entity hdl4fpga.fifo
		generic map (
			check_sov => true,
			check_dov => true,
			max_depth => (64*8)/rx_data'length)
		port map (
			src_clk    => rx_clk,
			src_irdy   => fifo_irdy,
			src_trdy   => fifo_trdy,
			src_data   => fifo_data,

			commit     => commit,
			rollback   => rollback,

			dst_clk    => tx_clk,
			dst_irdy   => tx_irdys(0),
			dst_trdy   => tx_trdys(0),
			dst_data   => acktx_data);

	end block;

	artibiter_b : block
		signal gntd : std_logic_vector(0 to 2-1);
	begin

		tx_frms(1)  <= si_frm;
		tx_irdys(1) <= si_irdy;
		si_trdy     <= tx_trdys(1);

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
			acktx_data when gntd(0)='1' else
			si_data    when gntd(1)='1' else
			(tx_data'range => '-');

	end block;

	so_frm <= so_irdy;
	fifo_b : block
		signal commit   : std_logic;
		signal rollback : std_logic;
	begin

		commit   <= fcs_sb and fcs_vld and not dup_equ;
		rollback <= fcs_sb and not fcs_vld;
		fifo_i : entity hdl4fpga.fifo
		generic map (
			max_depth => (2048*8)/rx_data'length)
		port map (
			src_clk    => rx_clk,
			src_frm    => rx_frm,
			src_irdy   => rx_irdy,
			src_trdy   => rx_trdy,
			src_data   => rx_data,

			commit     => commit,
			rollback   => rollback,

			dst_clk    => so_clk,
			dst_irdy   => so_irdy,
			dst_trdy   => so_trdy,
			dst_data   => so_data);

	end block;

end;
