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

		so_clk  : in std_logic;
		so_frm  : out std_logic;
		so_irdy : buffer std_logic;
		so_trdy : in  std_logic := '1';
		so_data : out std_logic_vector;

		si_clk  : in  std_logic := '-';
		si_frm  : in  std_logic;
		si_irdy : in  std_logic;
		si_trdy : out std_logic;
		si_data : in  std_logic_vector;

		tx_clk  : in std_logic;
		tx_frm  : buffer std_logic;
		tx_irdy : buffer std_logic;
		tx_trdy : in  std_logic := '1';
		tx_data : buffer std_logic_vector;
		tp      : out std_logic_vector(1 to 32));

end;

architecture struct of sio_flow is

	constant rgtrmeta_id : std_logic_vector(8-1 downto 0) := x"00";

	signal metarx_irdy  : std_logic;
	signal metarx_data  : std_logic_vector(rx_data'range);

	signal buffer_cmmt  : std_logic;
	signal buffer_rllbk : std_logic;
	signal buffer_ovfl  : std_logic;

	signal meta_cmmt    : std_logic;
	signal meta_rllbk   : std_logic;
	signal meta_ovfl    : std_logic;

	signal pyl_frm     : std_logic;
	signal rgtr_irdy    : std_logic;
	signal rgtr_id      : std_logic_vector(8-1 downto 0);
	signal rgtr_idv     : std_logic;
	signal rgtr_dv      : std_logic;
	signal rgtr_data    : std_logic_vector(0 to 8-1);
	signal data_frm     : std_logic;
	signal data_irdy    : std_logic;

	signal ackrply_req  : bit;
	signal ackrply_rdy  : bit;

	signal ackrx_dv     : std_logic;
	signal ackrx_data   : std_logic_vector(0 to 8-1);

	signal ackrply_data : std_logic_vector(0 to 5*8-1);
	signal acktx_frm    : std_logic;
	signal acktx_irdy   : std_logic;
	signal acktx_trdy   : std_logic;
	signal meta_end     : std_logic;
	signal acktx_end    : std_logic;
	signal acktx_data   : std_logic_vector(tx_data'range);

	signal ackrx_dup    : std_logic;
begin

	siosin_e : entity hdl4fpga.sio_sin
	port map (
		clk      => rx_clk,
		frm      => rx_frm,
		irdy     => rx_irdy,
		data     => rx_data,
		rgtr_frm  => pyl_frm,
		rgtr_irdy => pyl_irdy,
		rgtr_trdy => pyl_trdy,
		pyl_data => pyl_data);

	ack_b : block
		signal rom_data : std_logic_vector(rx_data'range);

		signal ram_frm  : std_logic;
		signal ram_irdy : std_logic;
		signal ram_data : std_logic_vector(rx_data'range);
		signal ack_equ  : std_logic;
	begin

		rom_i : entity hdl4fpga.sio_rom
		generic map (
			bitdata => reverse(x"01"))
		port map (
			so_clk  => rx_clk,
			so_frm  => rgtr_frm,
			so_irdy => rgtr_irdy,
			so_data => rom_data,

		cmp_i : entity hdl4fpga.sio_cmp
		port map (
			clk     => rx_clk,
			mr_frm  => rx_frm,
			mr_irdy => rx_irdy,
			mr_data => rx_data,
			sl_frm  => rx_frm,
			sl_irdy => rom_frm,
			sl_trdy => rom_irdy,
			sl_data => rom_data,
			equ     => ack_equ);

		process (rgtr_irdy, ack_equ, rx_clk)
			variable equ : std_logic;
		begin
			if rising_edge(rx_clk) then
				if equ='0' then
					if (rgtr_frm or rgtr_irdy)='1' then
						equ := ack_equ;
					end if;
				elsif (not rgtr_frm and rgtr_irdy and rgtr_trdy)='1' then
					equ := '0';
				end if;
			end if;
			ram_irdy <= (ack_equ or equ) and rgtr_irdy;
		end process;

		ram_data <=
			rx_data  when ram_irdy='1' else
			rom_data;

		mem_i : entity hdl4fpga.sio_ram
		generic map (
			bitdata => (0 to 24-1 => '-'))
		port map
			si_clk  => rx_clk,
			si_frm  => rgtr_frm,
			si_irdy => ram_irdy,
			si_data => ram_data,
			so_clk  => tx_clk,
			so_frm  => tx_frm,
			so_irdy => tx_irdy,
			so_trdy => tx_trdy,

	end block;

	process (rx_clk)
		variable last : unsigned(ackrx_data'range) := (others => '0');
	begin
		if rising_edge(rx_clk) then
			if ackrx_dv='1' then
				if to_bit(ackrx_data(ackrx_data'right))='1' then
					buffer_rllbk <= '1';
					meta_cmmt   <= '1';
					ackrply_req <= not ackrply_rdy;
				elsif shift_right(unsigned(ackrx_data),2)/=last or debug then
					buffer_cmmt  <= '1';
				else
					buffer_rllbk <= '1';
					meta_cmmt    <= '1';
					ackrply_req  <= not ackrply_rdy;
				end if;
				last := shift_right(unsigned(ackrx_data),2);
			elsif rx_frm='0' then
				buffer_cmmt  <= '0';
				meta_cmmt    <= '0';
				buffer_rllbk <= '0';
			end if;
		end if;
	end process;

	process (tx_clk)
	begin
		if rising_edge(tx_clk) then
			if acktx_end='1' then
				if tx_trdy='1' then
					ackrply_rdy <= ackrply_req;
				end if;
			end if;
		end if;
	end process;

	ackrply_data <= reverse(reverse(x"0003") & x"01" & x"00", 8) & (x"01" or ackrx_data);

	acktx_frm  <= to_stdulogic(ackrply_req xor ackrply_rdy);
	acktx_b : block

		signal meta_irdy  : std_logic;
		signal meta_data  : std_logic_vector(rx_data'range);

		signal ack_irdy   : std_logic;
		signal ack_trdy   : std_logic;
		signal ack_data   : std_logic_vector(tx_data'range);

		signal rx_dfrm    : std_logic;
		signal tx_frm    : std_logic;

	begin

		dly_e : entity hdl4fpga.latency
		generic map (
			n => 1,
			d => (0 to 0 => 2))
		port map (
			clk => rx_clk,
			di(0) => rx_frm,
			do(0) => rx_dfrm);

		meta_rllbk <= not (rx_frm or rx_dfrm);
		meta_ovfl  <= buffer_ovfl;

		meta_e : entity hdl4fpga.fifo
		generic map (
			max_depth => 64,
			latency   => 1,
			check_dov => true)
		port map(
			src_clk   => rx_clk,
			src_irdy  => metarx_irdy,
			src_trdy  => open,
			src_data  => metarx_data,

			rollback  => meta_rllbk,
			commit    => meta_cmmt,
			overflow  => meta_ovfl,

			dst_clk   => tx_clk,
			dst_irdy  => meta_irdy,
			dst_trdy  => acktx_trdy,
			dst_data  => meta_data);

		-- wait_fifo_latency : process (acktx_frm, tx_clk)
		-- 	variable q : unsigned(0 to 2-1);
		-- begin
		-- 	if rising_edge(tx_clk) then
		-- 		if acktx_frm='0' then
		-- 			q := (others => '0');
		-- 		else
		-- 			q(0) := acktx_frm;
		-- 			q := q rol 1;
		-- 		end if;
		-- 	end if;
		-- 	tx_frm <= acktx_frm and q(0);
		-- end process;

		acktx_e : entity hdl4fpga.sio_mux
		port map (
			mux_data => ackrply_data,
			sio_clk  => tx_clk,
			sio_frm  => tx_frm,
			sio_irdy => ack_irdy,
			sio_trdy => ack_trdy,
			so_end   => acktx_end,
			so_data  => ack_data);

		ack_irdy   <= acktx_trdy when meta_irdy='0' else '0';
		acktx_irdy <= ack_trdy   when meta_irdy='0' else meta_irdy;
		acktx_data <= ack_data   when meta_irdy='0' else meta_data;


	end block;

	artibiter_b : block

		signal req  : std_logic_vector(0 to 2-1);
		signal gnt  : std_logic_vector(0 to 2-1);

	begin

		req <= acktx_frm & si_frm;
		arbiter_e : entity hdl4fpga.arbiter
		port map (
			clk => tx_clk,
			req => req,
			gnt => gnt);

		tp(5 to 6) <= gnt;
		tx_frm  <= wirebus(acktx_frm  & si_frm,  gnt);
		tx_irdy <= wirebus(acktx_irdy & si_irdy, gnt);
		-- tx_end  <= wirebus(acktx_end  & si_end,  gnt);
		tx_data <= wirebus(acktx_data & si_data, gnt);
		-- GHDL bug : translate_signal_target_array_aggr: cannot handle IIR_KIND_CHOICE_BY_EXPRESSION
        -- GHDL release: 5.0.1 (tarball) [Dunoon edition]
        -- Compiled with GNAT Version: 14.2.1 20250301
        -- Target: x86_64-pc-linux-gnu
		-- (0 => acktx_trdy, 1 => si_trdy) <= gnt and (gnt'range => tx_trdy);
		acktx_trdy <= gnt(0) and tx_trdy;
		si_trdy    <= gnt(1) and tx_trdy;

	end block;

end;
