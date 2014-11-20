library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library corelib;

use work.aux_parts.all;
use work.aux_functions.all;
use work.cpu_parts.all;
use work.isa.all;

entity cpucore is
 	generic (
 		dwidth : natural := 32;
 		cwidth : natural := 16);
 	port (
 		xtal  : in  std_ulogic;


		switches : in std_ulogic_vector(7 downto 0);
		buttons : in std_ulogic_vector(3 downto 0);
		leds : out std_ulogic_vector(7 downto 0);
		anodes : out std_ulogic_vector(3 downto 0);
		segment_a : out std_ulogic;
		segment_b : out std_ulogic;
		segment_c : out std_ulogic;
		segment_d : out std_ulogic;
		segment_e : out std_ulogic;
		segment_f : out std_ulogic;
		segment_g : out std_ulogic;
		segment_dp : out std_ulogic);	

	attribute loc : string;

	-------------------------------------------
	-- Xilinx/Digilent SPARTAN-3 Starter Kit --
	-------------------------------------------

	attribute loc of xtal : signal is "T9";

	attribute loc of switches : signal is "K13 K14 J13 J14 H13 H14 G12 F12";
	attribute loc of buttons : signal is "L14 L13 M14 M13";
	attribute loc of leds : signal is  "P11 P12 N12 P13 N14 L12 P14 K12";
	attribute loc of anodes : signal is  "E13 F14 G14 D14";
	attribute loc of segment_a : signal is "E14";
	attribute loc of segment_b : signal is "G13";
	attribute loc of segment_c : signal is "N15";
	attribute loc of segment_d : signal is "P15";
	attribute loc of segment_e : signal is "R16";
	attribute loc of segment_f : signal is "F13";
	attribute loc of segment_g : signal is "N16";
	attribute loc of segment_dp : signal is "P16";

	------------------------------------
	-- Digilent/NEXYS2 SPARTAN-3E Kit --
	------------------------------------

--	attribute loc of rst : signal is "H13";
--	attribute loc of xtal : signal is "B8";
--	attribute loc of step : signal is "E18";
--
--	attribute loc of switches : signal is "R17 N17 L13 L14 K17 K18 H18 G18";
--	attribute loc of buttons : signal is "B18 D18 E18 H13";
--	attribute loc of leds : signal is  "P4 E4 P16 E16 K14 K15 J15 J14";
--	attribute loc of anodes : signal is  "F15 C18 H17 F17";
--	attribute loc of segment_a : signal is "L18";
--	attribute loc of segment_b : signal is "F18";
--	attribute loc of segment_c : signal is "D17";
--	attribute loc of segment_d : signal is "D16";
--	attribute loc of segment_e : signal is "G14";
--	attribute loc of segment_f : signal is "J17";
--	attribute loc of segment_g : signal is "H14";
--	attribute loc of segment_dp : signal is "C17";
	
end;

architecture pipeLine of cpuCore is

	-----------------------------
	-- BEGIN DEBUG DECLARATION --
	-----------------------------
	
	signal DEBUG_sht_disp_d : std_ulogic_vector(5 downto 0);

	---------------------------
	-- END DEBUG DECLARATION --
	---------------------------
	
	signal rst  : std_ulogic;
	signal step : std_ulogic;
	signal code : std_ulogic_vector(0 to cwidth-1);
	signal clk  : std_ulogic;
	
	signal display_data : std_ulogic_vector(0 to 15);
	
	subtype dword is std_ulogic_vector(dwidth-1   downto 0);
	subtype hhalf is std_ulogic_vector(dwidth-1   downto dwidth/2);
	subtype lhalf is std_ulogic_vector(dwidth/2-1 downto 0);

 	-----------------------------
 	-- Instrunction Registers  --
 	-----------------------------

	signal instrIft : std_ulogic_vector(code'range);
 	signal instrDec : std_ulogic_vector(code'range);
 	signal instrExe : std_ulogic_vector(code'range);
 	signal instrMem : std_ulogic_vector(code'range);

	-- Fetch Stage --

	signal ift_null_q : std_ulogic;
 	signal isJal  : std_ulogic;
 	signal isJimm : std_ulogic;
 	signal isJcnd : std_ulogic;

	signal ip_load_d : std_ulogic;
	signal ip_ena_d : std_ulogic := '1';

	signal selDisp12 : std_ulogic;
	
	signal pcdisp_high_ena_q : std_ulogic;
	signal pctrgt_high_ena_q : std_ulogic;
	signal pctrgt_low_cout_q : std_ulogic;
	signal pctrgt_high_cin_d : std_ulogic;
	signal pctrgt_high_inc_q : std_ulogic;
	signal pcdisp_high_to_0_d : std_ulogic;
	
	-- Decode Stage --

	signal dec_null_q : std_ulogic;
	signal dec_t_bit_rd_d : std_ulogic;
	signal dec_reg_ena_d : std_ulogic;
	signal dec_flg_ena_d : std_ulogic;

	constant alu_integer_add  : std_ulogic_vector(1 downto 0) := "00";
	constant alu_integer_sub  : std_ulogic_vector(1 downto 0) := "01";
	constant alu_integer_addi : std_ulogic_vector(1 downto 0) := "10";

	-- Execute Stage --

	signal exe_sel_alu_integer_q : std_ulogic_vector(1 downto 0);
	signal exe_sht_disp_rs2_q : std_ulogic;
	signal exe_null_q : std_ulogic;

	constant aluout_integer : std_ulogic_vector(2 downto 0) := "000";
	constant aluout_logic   : std_ulogic_vector(2 downto 0) := "001";
	constant aluout_shift   : std_ulogic_vector(2 downto 0) := "010";
	constant aluout_rs2val  : std_ulogic_vector(2 downto 0) := "011";
	constant aluout_rrf     : std_ulogic_vector(2 downto 0) := "100";

	constant rdval_aluout : std_ulogic_vector(0 downto 0) := "0";
	constant rdval_load   : std_ulogic_vector(0 downto 0) := "1";

	constant logic_or  : std_ulogic_vector := "00";
	constant logic_and : std_ulogic_vector := "01";
	constant logic_xor : std_ulogic_vector := "11";

	signal exe_sel_logic_op_q : std_ulogic_vector(1 downto 0);

	constant logic_rr : std_ulogic := '1';
	constant logic_ri : std_ulogic := '0';

	signal exe_sel_logic_reg_imm_q : std_ulogic;
	signal exe_sel_arth_sht_q : std_ulogic;

	signal exe_rs1_val_fwd_q : std_ulogic;
	signal exe_rs2_val_fwd_q : std_ulogic;
	signal mem_rs1_val_fwd_q : std_ulogic;
	signal mem_rs2_val_fwd_q : std_ulogic;

	-- Memory Stage --

	signal mem_null_q : std_ulogic;
	signal mem_sel_rdval_q  : std_ulogic_vector(0 downto 0);
	signal mem_sel_aluout_q : std_ulogic_vector(2 downto 0);
	signal mem_data_rw_d : std_ulogic;
	signal mem_rrf_ena_d : std_ulogic;

begin
	rst  <= buttons(3);
	step <= buttons(2);
	process (xtal)
		variable charge : natural range 0 to 2**16-1;
	begin
		if rising_edge(xtal) then
			if step='1' then
				if charge < 2**16-1 then
					charge := charge + 1;
				else 
					clk <= '1';
				end if;
			else
				if charge > 0 then
					charge := charge - 1;
				else 
					clk <= '0';
				end if;
			end if;
		end if;
	end process;
	
	display: entity corelib.iodev_bcd
		port map (
			clock => xtal,
			data  => display_data,
			segment_a  => segment_a,
			segment_b  => segment_b,
			segment_c  => segment_c,
			segment_d  => segment_d,
			segment_e  => segment_e,
			segment_f  => segment_f,
			segment_g  => segment_g,
			segment_dp => segment_dp,
			display_turnon => anodes);

 	stages: block
 		signal ip : std_ulogic_vector (dwidth-1 downto 0);

		signal dec_sign_extn_d : dword;
		signal dec_rs1val_d : dword;
		signal dec_rs2val_d : dword;
		signal dec_tyv_word_dout_d : std_ulogic_vector(0 to 2**ridlen-1);

		signal exe_t_bit_q : std_ulogic;
		signal exe_tyv_word_dout_q : std_ulogic_vector(0 to 2**ridlen-1);
		signal exe_sign_extn_q : dword;
		signal exe_rs1val_q : dword;
		signal exe_rs2val_q : dword;
		signal exe_rs2val_d : dword;
		signal exe_alu_logic_d : dword;
		signal exe_alu_logic_t_bit_d : std_ulogic;
		signal exe_alu_rotate_d : dword;
		signal exe_alu_sht_mask_d : dword;
		signal exe_alu_sht_sign_d : std_ulogic;
		signal exe_alu_sht_dir_d : std_ulogic;
		signal exe_dataout_d : dword;
		signal exe_alu_integer_lhalf_d : lhalf;
		signal exe_alu_integer_hhalf_c0_d : hhalf;
		signal exe_alu_integer_hhalf_c1_d : hhalf;
		signal exe_alu_integer_co_d : std_ulogic;
		signal exe_alu_integer_c0_d : std_ulogic;
		signal exe_alu_integer_c1_d : std_ulogic;

		signal exe_addr_lhalf_d : lhalf;
		signal exe_addr_lhalf_co_d : std_ulogic;

		signal mem_t_bit_q : std_ulogic;
		signal mem_tyv_word_dout_q : std_ulogic_vector(0 to 2**ridlen-1);
		signal mem_t_bit_d : std_ulogic;
		signal mem_tyv_word_din_d : std_ulogic_vector(0 to 2**ridlen-1);
		signal mem_alu_logic_q : dword;
		signal mem_alu_logic_t_bit_q : std_ulogic;
		signal mem_alu_shift_d : dword;
		signal mem_alu_rotate_q : dword;
		signal mem_alu_sht_sign_q : std_ulogic;
		signal mem_alu_sht_mask_q : dword;
		signal mem_alu_sht_dir_q : std_ulogic;

		signal mem_rdval_d : dword;
		signal mem_rs2val_q : dword;
		signal mem_addr_lhalf_q : lhalf;
		signal mem_addr_lhalf_co_q : std_ulogic;

		signal mem_alu_integer_lhalf_q : lhalf;
		signal mem_alu_integer_hhalf_c0_q : hhalf;
		signal mem_alu_integer_hhalf_c1_q : hhalf;
		signal mem_alu_integer_co_q : std_ulogic;
		signal mem_alu_integer_c0_q : std_ulogic;
		signal mem_alu_integer_c1_q : std_ulogic;
		signal mem_aluout_d : dword;

		signal mem_datain_d : dword;
		
 	begin

		DEBUG: block
		
			function mux_half (arg1 : dword; arg2 : std_ulogic) 
				return lhalf is
			begin
				case arg2 is
				when '1' =>
					return arg1(hhalf'range);
				when others =>
					return arg1(lhalf'range);
				end case;
			end;
			signal mux_sel : std_ulogic;
		begin
			mux_sel <= switches(7) xor buttons(0);
			with switches(3 downto 0) select
				display_data <=
--					instrIft when "0000",
					instrDec when "0001",
					instrExe when "0010",
					instrMem when "0011",
					mux_half(ip,           mux_sel) when "0100",
					mux_half(exe_rs1val_q, mux_sel) when "0101",
					mux_half(exe_rs2val_q, mux_sel) when "0110",			
					mux_half(mem_aluout_d, mux_sel) when "0111",
					mux_half(mem_alu_sht_mask_q, mux_sel) when "1000",
					mux_half(exe_alu_sht_mask_d, mux_sel) when "1001",
					(0 to 9 => '0') & DEBUG_sht_disp_d when "1010",
					(others => '-') when others;
					
			with switches(3 downto 0) select
				leds(0) <= 
					'0'     when "0000"|"0001"|"0010"|"0011",
					mux_sel when others;
			
		end block;
			
		fetch: block
			function extn_sign (val : std_ulogic_vector; n : natural)
				return std_ulogic_vector is
			begin
				return (0 to n-val'length-1 => val(val'left));
			end;
			
			alias imm8  : std_ulogic_vector(7 downto 0) is instrDec(im8Fld);
			alias imm12 : std_ulogic_vector(11 downto 0) is instrDec(im12Fld);
			signal pcdisp_hhalf_q : hhalf;
			signal pctrgt_low_cy : std_ulogic;
			signal pctrgt_d : dword;
			
			signal pctrgt_q : dword;

			signal pctrgt_low_cout_d : std_ulogic;
		begin
			pc : pc32
			generic map (N => dwidth, M => 1)
			port map (rst, clk,
				ena => ip_ena_d,
				enaSel => ip_ena_d,
				selData(0) => ip_load_d,
				data   => pctrgt_q,
				datap2 => pctrgt_q,
				q => ip);

			with selDisp12 select
			dec_sign_extn_d <= 
				extn_sign(imm12, dec_sign_extn_d'length) & imm12 when '1',
	 			extn_sign(imm8, dec_sign_extn_d'length) & imm8 when others;

			pctrgt_low_ffd : unsigned_adder
			port map (
				pctrgt_d(lhalf'range),
				ip(lhalf'range),
				dec_sign_extn_d(lhalf'range),
				cout => pctrgt_low_cout_d);

			pctrgt_high_ffd : unsigned_adder
			port map (
				pctrgt_d(hhalf'range),
				ip(hhalf'range),
				pcdisp_hhalf_q,
				cin => pctrgt_high_cin_d);

			registers: process (clk)
			begin
				if rising_edge(clk) then
					if pcdisp_high_ena_q='1' then
						case pcdisp_high_to_0_d is
						when '0' => 
							pcdisp_hhalf_q <= dec_sign_extn_d(hhalf'range);
						when '1' =>
							pcdisp_hhalf_q <= (others => '0');
						when others =>
							pcdisp_hhalf_q <= (others => '-');
						end case;
					end if;

					pctrgt_low_cout_q <= pctrgt_low_cout_d;

					pctrgt_q(lhalf'range) <= pctrgt_d(lhalf'range);
					if pctrgt_high_ena_q='1' then
						pctrgt_q(hhalf'range) <= pctrgt_d(hhalf'range);
					end if;
				end if;
			end process;
			pctrgt_high_cin_d <= pctrgt_low_cout_q or pctrgt_high_inc_q;

			ip_load_d <= SetIf((isJal='1' or (isJcnd='1'and dec_t_bit_rd_d='1')) and pcdisp_high_ena_q='1');
			pcdisp_high_to_0_d <= not ((isJimm or isJcnd) and pcdisp_high_ena_q) and pctrgt_high_inc_q;
			process (rst,clk)
			begin
				if rst='1' then
					pcdisp_high_ena_q  <= '1';
					pctrgt_high_ena_q  <= '0';
					pctrgt_high_inc_q  <= '1';
					pctrgt_low_cy <= '0';
				elsif rising_edge(clk) then
					if ip_load_d='1' and ip_ena_d='1' then
						pctrgt_low_cy <= '0';
						pcdisp_high_ena_q  <= '0';
						pctrgt_high_ena_q  <= '1';
						pctrgt_high_inc_q  <= '0';
					else
						if pctrgt_high_inc_q='0' then
							pctrgt_high_inc_q <= '1';
							pctrgt_low_cy <= pctrgt_low_cout_q;
						end if;
						if pctrgt_high_inc_q='0' then
							pctrgt_high_inc_q <= '1';
						end if;
						if pctrgt_high_inc_q='1' then
							pcdisp_high_ena_q <= '1';
							if pctrgt_low_cy='0' then
								pctrgt_high_ena_q <= '0';
							end if;
						end if;
						if pcdisp_high_ena_q='1' then
							pctrgt_high_ena_q <= '0';
						end if;
					end if;
				end if;				
			end process;

			instr : spram
			generic map (
				M => 10,
				N => 16)
			port map (
				clk  => clk,
				addr => ip(9 downto 0),
				dout => code);

		end block;

 		decode: block
			signal tyv_word_ena : std_ulogic;
			signal tyv_word_rs : std_ulogic_vector(ridFld);
			signal tyv_word_dout : std_ulogic_vector(0 to 2**ridlen-1);
			signal tyv_word_rd : std_ulogic_vector(ridFld);
			signal tyv_word_din : std_ulogic_vector(0 to 2**ridlen-1);
			signal tyv_bit_rd : std_ulogic_vector(ridFld);

			signal t_bit_ena : std_ulogic;
			signal t_bit_din : std_ulogic;
			signal t_bit_dout : std_ulogic;

			signal y_bit_ena : std_ulogic;
			signal y_bit_din : std_ulogic;
			signal y_bit_dout : std_ulogic;

			signal v_bit_ena : std_ulogic;
			signal v_bit_din : std_ulogic;
			signal v_bit_dout : std_ulogic;
 		begin
		
			tyv_word_rs <= instrDec(rs2Fld);
			tyv_word_rd <= instrMem(rdFld);
			tyv_word_din <= mem_tyv_word_din_d;
			tyv_word_ena <= mem_rrf_ena_d;

			tyv_bit_rd <= instrMem(rdFld);
			t_bit_ena <= dec_flg_ena_d;
			t_bit_din <= mem_t_bit_d;

			flagFile : block
				signal t_storage : std_ulogic_vector (0 to 15);
				signal y_storage : std_ulogic_vector (0 to 15);
				signal v_storage : std_ulogic_vector (0 to 15);
			begin
				process (clk)
				begin
					if rising_edge(clk) then
						if tyv_word_ena='1' then
							case tyv_word_rd is
							when t_register =>
								t_storage <= tyv_word_din;
							when y_register =>
								y_storage <= tyv_word_din;
							when v_register =>
								v_storage <= tyv_word_din;
							when others =>
								null;
							end case;
						else 
							if t_bit_ena='1' then
								t_storage(to_integer(unsigned(tyv_bit_rd))) <= t_bit_din;
							end if;
							if y_bit_ena='1' then
								y_storage(to_integer(unsigned(tyv_bit_rd))) <= y_bit_din;
							end if;
							if v_bit_ena='1' then
								v_storage(to_integer(unsigned(tyv_bit_rd))) <= v_bit_din;
							end if;
						end if;
					end if;
				end process;
				t_bit_dout <= t_storage(to_integer(unsigned(tyv_bit_rd)));
				tyv_word_dout <= t_storage;
			end block;
			
			dec_t_bit_rd_d <= t_bit_dout;
			dec_tyv_word_dout_d <= tyv_word_dout;

			registerFile1 : dpram
			generic map (ridLen, dword'length)
			port map (
				clk   => clk,
				we    => dec_reg_ena_d,
				wAddr => instrMem(rdFld),
				din   => mem_rdval_d,
				rAddr => instrDec(rs1Fld),
				dout  => dec_rs1val_d);

			registerFile2 : dpram 
			generic map (ridLen, dword'length)
			port map (
				clk   => clk,
				we    => dec_reg_ena_d,
				wAddr => instrMem(rdFld),
				din   => mem_rdval_d,
				rAddr => instrDec(rs2Fld),
				dout  => dec_rs2val_d);

		end block;

		dec_exe_register: process (clk)
		begin
			if rising_edge(clk) then
				exe_sign_extn_q <= dec_sign_extn_d;
				exe_t_bit_q <= dec_t_bit_rd_d;
				exe_tyv_word_dout_q <= dec_tyv_word_dout_d;
				exe_rs1val_q <= dec_rs1val_d;
				exe_rs2val_q <= dec_rs2val_d;
			end if;
		end process;
			
		execute: block
			alias exe_addr_imm_q is instrExe(funFld);

			signal rs1_val_d : dword;
			signal rs2_val_d : dword;

			signal logic_reg_reg_d : dword;
			signal logic_reg_imm_d : dword;

			signal add_reg_reg_lhalf_d : hhalf;
			signal sub_reg_reg_lhalf_d : hhalf;
			signal add_reg_imm_lhalf_d : hhalf;

			signal add_reg_reg_hhalf_c0_d : hhalf;
			signal sub_reg_reg_hhalf_b0_d : hhalf;
			signal add_reg_imm_hhalf_c0_d : hhalf;

			signal add_reg_reg_hhalf_c1_d : hhalf;
			signal sub_reg_reg_hhalf_b1_d : hhalf;
			signal add_reg_imm_hhalf_c1_d : hhalf;

			signal add_reg_reg_co_d : std_ulogic;
			signal sub_reg_reg_bo_d : std_ulogic;
			signal add_reg_imm_co_d : std_ulogic;

			signal add_reg_reg_c0_d : std_ulogic;
			signal sub_reg_reg_b0_d : std_ulogic;
			signal add_reg_imm_c0_d : std_ulogic;

			signal add_reg_reg_c1_d : std_ulogic;
			signal sub_reg_reg_b1_d : std_ulogic;
			signal add_reg_imm_c1_d : std_ulogic;

			signal sht_disp_d : std_ulogic_vector(5 downto 0);
			signal sht_extn_d : std_ulogic;

		begin

			rs1_val_d <= 
				mem_rdval_d when exe_rs1_val_fwd_q='1' else
				mem_rdval_q when mem_rs1_val_fwd_q='1' else
				exe_rs1val_q when '0',
				(others => '-') when others;

			rs2_val_d <= 
				mem_rdval_d when exe_rs2_val_fwd_q='1' else
				mem_rdval_q when mem_rs2_val_fwd_q='1' else
				exe_rs2val_q;
			exe_rs2val_d <= rs2_val_d;
			
			with exe_sht_disp_rs2_q select
			sht_disp_d <= 
				rs2_val_d(5 downto 0)  when '1',
				InstrExe(funFld)(alu_dirn_sht_bit_num) &
				InstrExe(funFld)(alu_dirn_sht_bit_num) &
				InstrExe(rs2Fld) when '0',
				(others => '-') when others;
			exe_alu_sht_dir_d <= sht_disp_d(sht_disp_d'left);

			exe_dataout_d <= rs1_val_d;

			with exe_sel_logic_reg_imm_q select
			exe_alu_logic_d <=
				logic_reg_reg_d when logic_rr,
				logic_reg_imm_d when logic_ri,
				(others => '-') when others;

			exe_alu_logic_t_bit_d <= '1' when exe_alu_logic_d=(exe_alu_logic_d'range => '0') else '0';

			with exe_sel_logic_op_q select
			logic_reg_reg_d <= 
				rs1_val_d or  rs2_val_d when logic_or,
				rs1_val_d and rs2_val_d when logic_and,
				rs1_val_d xor rs2_val_d when logic_xor,
				(others => '-') when others;

			with exe_sel_logic_op_q select
			logic_reg_imm_d <= 
				rs1_val_d or  exe_sign_extn_q when logic_or,
				rs1_val_d and exe_sign_extn_q when logic_and,
				rs1_val_d xor exe_sign_extn_q when logic_xor,
				(others => '-') when others;

			alu_rotate: barrel
			generic map (dword'length, 5) -- log2(dword'length);
			port map (
				sht => sht_disp_d(sht_disp_d'left-1 downto 0), 
				din => rs1_val_d, 
				dout => exe_alu_rotate_d);

			with exe_sel_arth_sht_q  select
			exe_alu_sht_sign_d <= 
				sht_extn_d and sht_disp_d(sht_disp_d'left) when '1',
				'0' when others;

			sht_extn_d <= rs1_val_d(rs1_val_d'left);

--			with select
--			shift_extension <=
--				rs1_val_d(rs1_val_d'left-BYTE_LENGHT*0) when "00",
--				rs1_val_d(rs1_val_d'left-BYTE_LENGHT*1) when "01",
--				rs1_val_d(rs1_val_d'left-BYTE_LENGHT*2) when "10",
--				rs1_val_d(rs1_val_d'left-BYTE_LENGHT*3) when "11";
			DEBUG_sht_disp_d <= sht_disp_d;

			alu_shift_mask: shift_mask
			generic map (dword'length, 6) -- log2(dword'length)+1
			port map (
				sht  => sht_disp_d,
				mout => exe_alu_sht_mask_d);

			alu_mem_lhalf : unsigned_adder
			port map (
				exe_addr_lhalf_d(lhalf'range),
				rs2_val_d(lhalf'range),
				exe_addr_imm_q, exe_addr_lhalf_co_d);

			with exe_sel_alu_integer_q select
			exe_alu_integer_lhalf_d <= 
				add_reg_reg_lhalf_d when alu_integer_add,
				sub_reg_reg_lhalf_d when alu_integer_sub,
				add_reg_imm_lhalf_d when alu_integer_addi,
				(others => '-') when others;
 
			with exe_sel_alu_integer_q select
			exe_alu_integer_hhalf_c0_d <= 
				add_reg_reg_hhalf_c0_d when alu_integer_add,
				sub_reg_reg_hhalf_b0_d when alu_integer_sub,
				add_reg_imm_hhalf_c0_d when alu_integer_addi,
				(others => '-') when others;
 
			with exe_sel_alu_integer_q select
			exe_alu_integer_hhalf_c1_d <= 
				add_reg_reg_hhalf_c1_d when alu_integer_add,
				sub_reg_reg_hhalf_b1_d when alu_integer_sub,
				add_reg_imm_hhalf_c1_d when alu_integer_addi,
				(others => '-') when others;
 
			with exe_sel_alu_integer_q select
			exe_alu_integer_co_d <= 
				add_reg_reg_co_d when alu_integer_add,
				sub_reg_reg_bo_d when alu_integer_sub,
				add_reg_imm_co_d when alu_integer_addi,
				'-' when others;
 
			with exe_sel_alu_integer_q select
			exe_alu_integer_c0_d <= 
				add_reg_reg_c0_d when alu_integer_add,
				sub_reg_reg_b0_d when alu_integer_sub,
				add_reg_imm_c0_d when alu_integer_addi,
				'-' when others;
 
			with exe_sel_alu_integer_q select
			exe_alu_integer_c1_d <= 
				add_reg_reg_c1_d when alu_integer_add,
				sub_reg_reg_b1_d when alu_integer_sub,
				add_reg_imm_c1_d when alu_integer_addi,
				'-' when others;
 
			alu_add_reg_imm_lhalf : unsigned_adder
			port map (
				add_reg_imm_lhalf_d,
				rs1_val_d(lhalf'range),
				exe_sign_extn_q(lhalf'range),
				add_reg_imm_co_d);

			alu_add_reg_imm_hhalf_c0 : unsigned_adder
			port map (
				add_reg_imm_hhalf_c0_d,
				rs1_val_d(hhalf'range),
				exe_sign_extn_q(hhalf'range),
				add_reg_imm_c0_d,
				cin => '0');

			alu_add_reg_imm_hhalf_c1: unsigned_adder
			port map (
				add_reg_imm_hhalf_c1_d,
				rs1_val_d(hhalf'range),
				exe_sign_extn_q(hhalf'range),
				add_reg_imm_c1_d,
				cin => '1');

			alu_add_reg_reg_lhalf : unsigned_adder
			port map (
				add_reg_reg_lhalf_d,
				rs1_val_d(lhalf'range),
				rs2_val_d(lhalf'range),
				add_reg_reg_co_d);

			alu_add_reg_reg_hhalf_c0 : unsigned_adder
			port map (
				add_reg_reg_hhalf_c0_d,
				rs1_val_d(hhalf'range),
				rs2_val_d(hhalf'range),
				add_reg_reg_c0_d,
				cin => '0');

			alu_add_reg_reg_hhalf_c1: unsigned_adder
			port map (
				add_reg_reg_hhalf_c1_d,
				rs1_val_d(hhalf'range),
				rs2_val_d(hhalf'range),
				add_reg_reg_c1_d,
				cin => '1');

			alu_sub_reg_reg_lhalf: unsigned_subtracter
			port map (
				sub_reg_reg_lhalf_d,
				rs1_val_d(lhalf'range),
				rs2_val_d(lhalf'range),
				sub_reg_reg_bo_d);

			alu_sub_hhalf_c0: unsigned_subtracter
			port map (
				sub_reg_reg_hhalf_b0_d,
				rs1_val_d(hhalf'range),
				rs2_val_d(hhalf'range),
				sub_reg_reg_b0_d,
				bin => '0');

			alu_sub_hhalf_c1 : unsigned_subtracter
			port map (
				sub_reg_reg_hhalf_b1_d,
				rs1_val_d(hhalf'range),
				rs2_val_d(hhalf'range),
				sub_reg_reg_b1_d,
				bin => '1');

		end block;

		exe_mem_register: process (clk)
		begin
			if rising_edge(clk) then
				mem_rs2val_q <= exe_rs2val_d;

				mem_t_bit_q <= exe_t_bit_q;
				mem_tyv_word_dout_q <= mem_tyv_word_dout_q;

				mem_alu_logic_q <= exe_alu_logic_d;
				mem_alu_logic_t_bit_q <= exe_alu_logic_t_bit_d;

				mem_alu_rotate_q <= exe_alu_rotate_d;
				mem_alu_sht_mask_q <= exe_alu_sht_mask_d;
				mem_alu_sht_sign_q <= exe_alu_sht_sign_d;
				mem_alu_sht_dir_q <= exe_alu_sht_dir_d;

				mem_addr_lhalf_q <= exe_addr_lhalf_d;
				mem_addr_lhalf_co_q <= exe_addr_lhalf_co_d;
				mem_alu_integer_lhalf_q <= exe_alu_integer_lhalf_d;
				mem_alu_integer_hhalf_c0_q <= exe_alu_integer_hhalf_c0_d;
				mem_alu_integer_hhalf_c1_q <= exe_alu_integer_hhalf_c1_d;
				mem_alu_integer_co_q <= exe_alu_integer_co_d;
				mem_alu_integer_c0_q <= exe_alu_integer_c0_d;
				mem_alu_integer_c1_q <= exe_alu_integer_c1_d;
			end if;
		end process;

		mem : block
			signal alu_integer_hhalf_d : hhalf;
			signal alu_integer_cout_d : std_ulogic;
			signal alu_integer_t_bit_d : std_ulogic;
			signal alu_sht_bit_d : std_ulogic;

			signal sel_aluout_lhalf : std_ulogic_vector(2 downto 0);
			signal sel_aluout_hhalf : std_ulogic_vector(2 downto 0);
			signal sel_aluout_t_bit : std_ulogic_vector(2 downto 0);

		begin
			sel_aluout_lhalf <= mem_sel_aluout_q;
			sel_aluout_hhalf <= mem_sel_aluout_q;
			sel_aluout_t_bit <= mem_sel_aluout_q;

			mem_tyv_word_din_d <= mem_rs2val_q(lhalf'range);

			with mem_sel_rdval_q select
			mem_rdval_d <=
				mem_datain_d when rdval_load,
				mem_aluout_d when rdval_aluout,
				(others => '-') when others;
				
			with sel_aluout_lhalf select
			mem_aluout_d(lhalf'range) <= 
				mem_alu_integer_lhalf_q when aluout_integer,
				mem_alu_logic_q(lhalf'range) when aluout_logic,
				mem_alu_shift_d(lhalf'range) when aluout_shift,
				mem_rs2val_q(lhalf'range) when aluout_rs2val,
				mem_tyv_word_dout_q  when aluout_rrf,
				(others => '-') when others;

			with sel_aluout_hhalf select
			mem_aluout_d(hhalf'range) <= 
				alu_integer_hhalf_d when aluout_integer,
				mem_alu_logic_q(hhalf'range) when aluout_logic,
				mem_alu_shift_d(hhalf'range) when aluout_shift,
				mem_rs2val_q(hhalf'range) when aluout_rs2val,
				(others => '-') when others;

			process (clk)
			begin
				if rising_edge(clk) then
					mem_aluout_q <= mem_aluout_d;
				end if;
			end process;

			with mem_alu_integer_co_q select
			alu_integer_hhalf_d <=
				mem_alu_integer_hhalf_c1_q when '1',
				mem_alu_integer_hhalf_c0_q when '0',
				(others => '-') when others;

			with mem_alu_integer_co_q select
			alu_integer_cout_d <=
				mem_alu_integer_c1_q when '1',
				mem_alu_integer_c0_q when '0',
				'-' when others;

			alu_shift: for i in mem_alu_shift_d'range generate
				with mem_alu_sht_mask_q(i) select
				mem_alu_shift_d(i) <= 
					mem_alu_rotate_q(i)  when '1',
					mem_alu_sht_sign_q   when '0',
					'-' when others;
			end generate;

			with sel_aluout_t_bit select
			mem_t_bit_d <= 
				alu_integer_t_bit_d when aluout_integer,
				mem_t_bit_q when aluout_rs2val,
				alu_sht_bit_d when aluout_shift,
				mem_alu_logic_t_bit_q when aluout_logic,
				'-' when others;

			with mem_alu_sht_dir_q select
			alu_sht_bit_d <=
				mem_alu_rotate_q(mem_alu_rotate_q'left) when '1',
				mem_alu_rotate_q(mem_alu_rotate_q'right) when '0',
				'-' when others;

			datamem : spram
			generic map (10, dword'length, TRUE)
			port map (
				clk  => clk,
				we   => mem_data_rw_d,
				addr => mem_addr_lhalf_q(9 downto 0),
				dout => mem_datain_d,
				din  => exe_dataout_d);

		end block;

 	end block;

 	ctrlUnit: block
		signal ift_null_d : std_ulogic;

 		alias  dec_rs1_q is instrDec(rs1Fld);
 		alias  dec_rs2_q is instrDec(rs2Fld);
 		alias  dec_opc_q is instrDec(opcFld);
 		alias  dec_fun_q is instrDec(funFld);
		signal dec_null_d : std_ulogic;
		signal dec_imm_hzrd_d : std_ulogic;
		signal dec_alu_imm_hzrd_d : std_ulogic;
		
 		alias  exe_rd_q is instrExe(rdFld);

		signal exe_rrf_q : std_ulogic;
		signal exe_opc_hzrd_q : std_ulogic;
		signal exe_rs1_hzrd_d : std_ulogic;
		signal exe_rs2_hzrd_d : std_ulogic;
		signal exe_nop_q : std_ulogic;
		signal exe_null_d : std_ulogic;

		signal mem_rrf_q : std_ulogic;
 		alias  mem_rd_q is instrMem(rdFld);
		signal mem_opc_hzrd_q : std_ulogic;
		signal mem_rs1_hzrd_d : std_ulogic;
		signal mem_rs2_hzrd_d : std_ulogic;
		signal mem_reg_ena_q : std_ulogic;
		signal mem_flg_ena_q : std_ulogic;
		signal mem_null_d : std_ulogic;
 	begin
		DEBUG: block
		begin
			leds(1 downto 1) <= (others => '0');
			with switches(3 downto 0) select
				leds(7) <=
					dec_null_q when "0001",
					exe_null_q when "0010",
					mem_null_q when "0011",
					'0' when others;

			with switches(3 downto 0) select
				leds(6) <=
					dec_alu_imm_hzrd_d when "0001",
					exe_opc_hzrd_q     when "0010",
					'0' when others;

			with switches(3 downto 0) select
				leds(5) <=
					dec_imm_hzrd_d when "0001",
				    exe_rs1_hzrd_d when "0010",
					mem_rs1_hzrd_d when "0011",
					'0' when others;
					
			with switches(3 downto 0) select
				leds(4) <=
					dec_alu_imm_hzrd_d when "0001",
				    exe_rs2_hzrd_d     when "0010",
					mem_rs2_hzrd_d    when "0011",
				    '0' when others;
					
			with switches(3 downto 0) select
				leds(3) <=
				    exe_rs1_hzrd_d     when "0010",
				    '0' when others;
					
			with switches(3 downto 0) select
				leds(2) <=
				    exe_rs2_hzrd_d     when "0010",
				    '0' when others;

		end block;

		with dec_opc_q select
			dec_imm_hzrd_d <=
				dec_alu_imm_hzrd_d when alu,
				'1' when cpi|addi|ori|li,
				'0' when others;
				
		with dec_fun_q select
			dec_alu_imm_hzrd_d <=
				'1' when alu_asri|alu_lsri|alu_lsli,
				'0' when others;
				
		---------------------
		-- Fowarding logic --
		---------------------

		exe_rs1_hzrd_d <= SetIf(dec_rs1_q=exe_rd_q);
		exe_rs2_hzrd_d <= SetIf(dec_rs2_q=exe_rd_q);
		mem_rs1_hzrd_d <= SetIf(dec_rs1_q=mem_rd_q);
		mem_rs2_hzrd_d <= SetIf(dec_rs2_q=mem_rd_q);

		process (clk)
		begin
			if rising_edge(clk) then 
				case dec_opc_q is
				when alu|st|addi|ori|brt =>
					exe_opc_hzrd_q <= '1';
				when others =>
					exe_opc_hzrd_q <= '0';
				end case;
				mem_opc_hzrd_q <= exe_opc_hzrd_q;
				
		
				mem_rs1_val_fwd_q <= mem_rs1_hzrd_d and not mem_null_q;
				mem_rs2_val_fwd_q <= mem_rs2_hzrd_d and not mem_null_q and not dec_imm_hzrd_d;

				exe_rs1_val_fwd_q <= exe_rs1_hzrd_d and not exe_nop_q and not exe_null_q;
				exe_rs2_val_fwd_q <= exe_rs2_hzrd_d and not exe_nop_q and not exe_null_q and not dec_imm_hzrd_d;
			end if;

		end process;

		-------------------------
		-- End Fowarding logic --
		-------------------------


		ip_ena_d <= '1';

		exe_null_d <= SetIf(dec_null_q='1' or (isJimm='1' or (ip_load_d='0' and pcdisp_high_ena_q='0')));
		mem_null_d <= SetIf(exe_null_q='1' or exe_nop_q='1');

		process(rst,clk)
		begin
			if rst='1' then
				dec_null_q <= '1';
				exe_null_q <= '1';
				mem_null_q <= '1';
			elsif rising_edge(clk) then
				dec_null_q <= '0';
				exe_null_q <= exe_null_d;
				mem_null_q <= mem_null_d;
			end if;
		end process;
		
		instrIft <= code;
		process(clk)
		begin
			if rising_edge(clk) then
				if not (pcdisp_high_ena_q='1' and (isJal='1' or (isJcnd='1'and dec_t_bit_rd_d='1'))) and ip_ena_d='1' then
					instrDec <= instrIft;
				end if;
				instrExe <= instrDec;
				instrMem <= instrExe;
			end if;
		end process;

 		dec: block
 			alias opc is instrDec(opcFld);
 			alias rs1 is instrDec(rs1Fld);
 			alias rs2 is instrDec(rs2Fld);
 			alias fun is instrDec(funFld);

 		begin
			isJimm <= SetIf(opc=jal or opc=brt);
 			isJal  <= SetIf(opc=jal);
			isJcnd <= SetIf(opc=brt);

			selDisp12 <= SetIf(isJal='1');
					
			process (clk)
			begin
				if rising_edge(clk) then
					exe_nop_q <= SetIf(
				  		opc=(opc'range =>'0') and
						rs1=(rs1'range =>'0') and
						rs2=(rs2'range =>'0') and
						fun=(fun'range =>'0'));

					case fun is
					when alu_lsht|alu_asht =>
						exe_sht_disp_rs2_q <= '1';
					when others =>
						exe_sht_disp_rs2_q <= '0';
					end case;

					case opc is
					when alu =>
						case fun is
						when alu_add =>
							exe_sel_alu_integer_q <= alu_integer_add;
						when alu_sub =>
							exe_sel_alu_integer_q <= alu_integer_sub;
						when others =>
							exe_sel_alu_integer_q <= (others => '-');
						end case;
					when addi =>
						exe_sel_alu_integer_q <= alu_integer_addi;
					when others =>
						exe_sel_alu_integer_q <= (others => '-');
					end case;

					case opc is
					when alu =>
						case fun is
						when alu_or  =>
							exe_sel_logic_reg_imm_q <= logic_rr;
							exe_sel_logic_op_q <= logic_or;
						when alu_and =>
							exe_sel_logic_reg_imm_q <= logic_rr;
							exe_sel_logic_op_q <= logic_and;
						when alu_xor =>
							exe_sel_logic_reg_imm_q <= logic_rr;
							exe_sel_logic_op_q <= logic_xor;
						when others  =>
							exe_sel_logic_reg_imm_q <= '-';
							exe_sel_logic_op_q <= (others => '-');
						end case;
					when ori  =>
						exe_sel_logic_reg_imm_q <= logic_ri;
						exe_sel_logic_op_q <= logic_or;
					when others =>
						exe_sel_logic_reg_imm_q <= '-';
						exe_sel_logic_op_q <= (others => '-');
					end case;

					case opc is
					when rrf =>
						exe_rrf_q <= '1';
					when others =>
						exe_rrf_q <= '0';
					end case;

				end if;
			end process;

		end block;
		
		exe: block
 			alias opc is instrExe(opcFld);
 			alias rs1 is instrExe(rs1Fld);
 			alias rs2 is instrExe(rs2Fld);
 			alias fun is instrExe(funFld);
		begin
			exe_sel_arth_sht_q <= fun(alu_arth_sht_bit_num);

			with opc select
				mem_data_rw_d <=
					SetIf(exe_null_q='1') when st,
					'0' when others;

			process (clk)
			begin
				if rising_edge(clk) then
					case opc is
					when alu|addi|ld =>
						mem_flg_ena_q <= '1';
					when others =>
						mem_flg_ena_q <= '0';
					end case;

					case opc is
					when alu|addi|ld =>
						mem_reg_ena_q <= '1';
					when others =>
						mem_reg_ena_q <= '0';
					end case;

					case opc is
					when alu|addi|ld =>
						mem_reg_ena_q <= '1';
					when others =>
						mem_reg_ena_q <= '0';
					end case;

					case opc is
					when alu|addi =>
						mem_sel_rdval_q <= rdval_aluout;
					when ld =>
						mem_sel_rdval_q <= rdval_load;
					when others =>
						mem_sel_rdval_q <= (others => '-');
					end case;

					case opc is
					when alu =>
						case fun is
						when alu_mov =>
							mem_sel_aluout_q <= aluout_rs2val;
						when alu_add|alu_sub =>
							mem_sel_aluout_q <= aluout_integer;
						when alu_or|alu_and|alu_xor =>
							mem_sel_aluout_q <= aluout_logic;
						when alu_asri|alu_lsri|alu_lsli =>
							mem_sel_aluout_q <= aluout_shift;
						when others =>
							mem_sel_aluout_q <= (others => '-');
						end case;
					when addi =>
						mem_sel_aluout_q <= aluout_integer;
					when rrf =>
						mem_sel_aluout_q <= aluout_rrf;
					when others =>
						mem_sel_aluout_q <= (others => '-');
					end case;

					mem_rrf_q <= exe_rrf_q and fun(rrf_rw_bit_num);
				end if;
			end process;
 		end block;

		mem: block
 			alias opc is instrMem(opcFld);
 			alias fun is instrMem(funFld);
		begin
			dec_reg_ena_d <= not mem_null_q and mem_reg_ena_q;
			dec_flg_ena_d <= not mem_null_q and mem_flg_ena_q;
			mem_rrf_ena_d <= not mem_null_q and mem_rrf_q;
		end block;
 	end block;
end;
