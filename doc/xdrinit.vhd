	process (xdr_init_clk)
		variable row : s_row;
	begin
		if rising_edge(xdr_init_clk) then
			.......
				if xdr_timer_rdy='1' then
					xdr_init_pc  <= row.state_n;
					xdr_init_rst <= to_sout(row.output).rst;
					xdr_init_rdy <= to_sout(row.output).rdy;
					xdr_init_wlr <= to_sout(row.output).wlr;
					xdr_init_odt <= to_sout(row.output).odt;
					.....
				else
					xdr_init_cs  <= ddr_nop.cs;
					xdr_init_ras <= ddr_nop.ras;
					xdr_init_cas <= ddr_nop.cas;
					xdr_init_we  <= ddr_nop.we;
					xdr_timer_id <= row.tid;
				end if;
				xdr_mr_addr <= row.mr;
			else
				......
			end if;
		end if;
	end process;
