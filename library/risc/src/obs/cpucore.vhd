library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.aux_parts.all;
use work.aux_functions.all;
use work.cpu_parts.all;
use work.isa.all;

entity cpucore is
 	generic (
 		dwidth : natural := 32;
 		cwidth : natural := 16);
 	port (
 		rst   : in  std_ulogic;
 		clk   : in  std_ulogic;
 		caddr : out std_ulogic_vector(dwidth-1 downto 0);
 		code  : in  std_ulogic_vector(0 to cwidth-1));

end;

architecture pipeLine of cpuCore is
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
 	signal instrWB  : std_ulogic_vector(code'range);

	-- Fetch Stage --

	signal ip_load : std_ulogic;

	signal selDisp12 : std_ulogic;
	
	signal pcdisp_low_ena: std_ulogic;
	signal pcdisp_high_ena : std_ulogic;
	signal pctrgt_high_ena : std_ulogic;
	signal pctrgt_low_cout : std_ulogic;
	signal pctrgt_high_inc : std_ulogic;
	signal pctrgt_high_cin : std_ulogic;
	signal pcdisp_to_0 : std_ulogic;
	
	-- Decode Stage --

	signal dec_t_bit_d : std_ulogic;
	signal dec_alu_fun_d : std_ulogic;

	-- Execute Stage --

	constant rdval_addrr  : std_ulogic_vector(2 downto 0) := "000";
	constant rdval_subrr  : std_ulogic_vector(2 downto 0) := "001";
	constant rdval_addri  : std_ulogic_vector(2 downto 0) := "010";
	constant rdval_logic  : std_ulogic_vector(2 downto 0) := "011";
	constant rdval_shtrot : std_ulogic_vector(2 downto 0) := "111";


	constant logic_or  : std_ulogic_vector := "00";
	constant logic_and : std_ulogic_vector := "01";
	constant logic_xor : std_ulogic_vector := "11";

	signal exe_sel_logic_op_q : std_ulogic_vector(1 downto 0);

	constant logic_rr : std_ulogic := '1';
	constant logic_ri : std_ulogic := '0';

	signal exe_sel_logic_reg_imm_q : std_ulogic;
	signal exe_sel_arth_sht_q : std_ulogic;
	signal exe_sht_disp_q : std_ulogic_vector(5 downto 0);

	-- Execute Stage --

	signal mem_t_bit_d : std_ulogic;
	signal mem_sel_rdval_q : std_ulogic_vector(2 downto 0);
	signal mem_data_rw_q : std_ulogic;

begin
 	stages: block
		signal ip_ena : std_ulogic := '1';
 		signal ip : std_ulogic_vector (caddr'range);

		signal dec_sign_extn_d : dword;
		signal dec_rs1val_d : dword;
		signal dec_rs2val_d : dword;
		signal dec_pctrgt : dword;

		signal exe_sign_extn_q : dword;
		signal exe_rs1val_q : dword;
		signal exe_rs2val_q : dword;
		signal exe_alu_logic_d : dword;
		signal exe_alu_shtrot_d : dword;
		signal exe_datain_d : dword;

		signal mem_alu_logic_q : dword;
		signal mem_alu_shtrot_q : dword;

		signal mem_addi_lhalf_q : lhalf;
		signal mem_addi_lhalf_co_q : std_ulogic;
		signal mem_addi_hhalf_c0_q : hhalf;
		signal mem_addi_hhalf_c1_q : hhalf;
		signal mem_addi_co0_q : std_ulogic;
		signal mem_addi_co1_q : std_ulogic;

		signal mem_sum_lhalf_q : lhalf;
		signal mem_sum_lhalf_co_q : std_ulogic;
		signal mem_sum_hhalf_c0_q : hhalf;
		signal mem_sum_hhalf_c1_q : hhalf;
		signal mem_sum_co0_q : std_ulogic;
		signal mem_sum_co1_q : std_ulogic;

		signal mem_sub_lhalf_q : lhalf;
		signal mem_sub_lhalf_bo_q : std_ulogic;
		signal mem_sub_hhalf_b0_q : hhalf;
		signal mem_sub_hhalf_b1_q : hhalf;
		signal mem_sub_bo0_q : std_ulogic;
		signal mem_sub_bo1_q : std_ulogic;

		signal mem_dataout_d : dword;
		signal mem_rdval_d : dword;

		signal mem_datain_q : dword;
 	begin
		caddr <= ip;

 		decode: block
			alias ip_lhalf is ip(lhalf'range);
			alias ip_hhalf is ip(hhalf'range);
			
			function extn_sign (val : std_ulogic_vector; n : natural)
				return std_ulogic_vector is
			begin
				return (0 to n-val'length-1 => val(val'left));
			end;
			
 			alias disp8  : std_ulogic_vector ( 7 downto 0) is instrDec(im8Fld);
	 		alias disp12 : std_ulogic_vector (11 downto 0) is instrDec(im12Fld);
			alias sign_extn is dec_sign_extn_d; 

			signal pctrgt : dword;
			signal pcdisp : dword;
			signal pcdisp_cy : std_ulogic;
			signal sign_extn_high : hhalf;
			
			alias sign_extn_lhalf is dec_sign_extn_d(lhalf'range);
			alias sign_extn_hhalf is dec_sign_extn_d(hhalf'range);
			alias pcdisp_lhalf is pcdisp(lhalf'range);
			alias pcdisp_hhalf is pcdisp(hhalf'range);
			alias pctrgt_lhalf is pctrgt(lhalf'range);
			alias pctrgt_hhalf is pctrgt(hhalf'range);

 			alias rs1Id is instrDec(rs1Fld);
 			alias rs2Id is instrDec(rs2Fld);
 			alias rdId  is instrDec(rs2Fld);

			alias rs1val is dec_rs1val_d;
			alias rs2val is dec_rs2val_d;
			alias rdval  is mem_rdval_d;

			alias t_bit_din  is mem_t_bit_d;
			alias t_bit_dout is dec_t_bit_d;

			signal immWd  : dword;
			signal wrenaReg : std_ulogic := '1';

			signal t_flg_we : std_ulogic;
			signal t_flg_id : std_ulogic_vector(ridFld);

 		begin
		
			with pcdisp_to_0 select
				sign_extn <= 
					extn_sign(disp12, sign_extn'length) & disp12 when '1',
		 			extn_sign(disp8,  sign_extn'length) & disp8  when others;

			pcdisp_low_ffd : ffdArray 
				generic map ((lhalf'range => '0'))
				port map (rst, clk, pcdisp_lhalf, sign_extn_lhalf, ena => pcdisp_low_ena);
			
			with pcdisp_to_0 select
				sign_extn_high <= 
					sign_extn_hhalf when '0',
					(others => '0') when '1',
					(others => '-') when  others;

			pcdisp_high_ffd : ffdArray 
				generic map ((lhalf'range => '0'))
				port map (rst, clk, pcdisp_hhalf, sign_extn_high, ena => pcdisp_high_ena);
			
			pctrgt_low_ffd : syncUAdder
				generic map ((lhalf'range => '0'), '0')
				port map (rst, clk, pctrgt_lhalf, ip_lhalf, pcdisp_lhalf, cout => pctrgt_low_cout);

			pctrgt_high_ffd : syncUAdder
				generic map ((hhalf'range => '0'), '0')
				port map (rst, clk, pctrgt_hhalf, ip_hhalf, pcdisp_hhalf, cin => pctrgt_high_cin, ena => pctrgt_high_ena);

			pc : pc32
				generic map (N => dwidth, M => 1)
				port map (rst, clk,
					ena => ip_ena,
					selData(0) => ip_load,
					data   => pctrgt,
					datap2 => pctrgt,
					q => ip);


			t_flg_we  <= wrEnaReg;
			t_flg_id  <= rdId;

			flagFile : block
				signal t_storage : std_ulogic_vector (0 to 15) 
					:= (15 => '1', others => '0');
			begin
				process (rst,clk)
				begin
					if rising_edge(clk) then
						if t_flg_we='1' then
							t_storage(to_integer(unsigned(t_flg_id))) <= t_bit_din;
						end if;
					end if;
				end process;
				t_bit_dout <= t_storage(to_integer(unsigned(t_flg_id)));
			end block;

			registerFile1 : dpram
				generic map (ridLen, dword'length)
				port map (
					clk   => clk,
					we    => '1',
					wAddr => rdId,
					rAddr => rs1Id,
					dout  => rs1val,
					din   => rdval);

			registerFile2 : dpram 
				generic map (ridLen, dword'length)
				port map (
					clk   => clk,
					we    => '1',
					wAddr => rdId,
					rAddr => rs2Id,
					dout  => rs2val,
					din   => rdval);

		end block;

		sign_extn_register : ffdArray
			generic map ((dword'range => '0'))
			port map (rst,clk, exe_sign_extn_q, dec_sign_extn_d);

		rs1val_register : ffdArray 
			generic map ((dword'range => '0'))
			port map (rst, clk, exe_rs1val_q, dec_rs1val_d);
			
		rs2val_register : ffdArray 
			generic map ((dword'range => '0'))
			port map (rst, clk, exe_rs2val_q, dec_rs2val_d);
			
		execute: block
			alias sign_extn is exe_sign_extn_q;
			alias sign_extn_low is exe_sign_extn_q(lhalf'range);
			alias sign_extn_high is exe_sign_extn_q(hhalf'range);

			alias rs1val  is exe_rs1val_q;
			alias rs1val_low  is exe_rs1val_q(lhalf'range);
			alias rs1val_high is exe_rs1val_q(hhalf'range);

			alias rs2val  is exe_rs2val_q;
			alias rs2val_low  is exe_rs2val_q(lhalf'range);
			alias rs2val_high is exe_rs2val_q(hhalf'range);

			alias addi_lhalf is mem_addi_lhalf_q;
			alias addi_hhalf_c0 is mem_addi_hhalf_c0_q;
			alias addi_hhalf_c1 is mem_addi_hhalf_c1_q;
			alias addi_lhalf_co is mem_addi_lhalf_co_q;
			alias addi_co0 is  mem_addi_co0_q;
			alias addi_co1 is  mem_addi_co1_q;

			alias sum_lhalf is mem_sum_lhalf_q;
			alias sum_hhalf_c0 is mem_sum_hhalf_c0_q;
			alias sum_hhalf_c1 is mem_sum_hhalf_c1_q;
			alias sum_lhalf_co is mem_sum_lhalf_co_q;
			alias sum_co0 is  mem_sum_co0_q;
			alias sum_co1 is  mem_sum_co1_q;

			alias sub_lhalf is mem_sub_lhalf_q;
			alias sub_hhalf_b0 is mem_sub_hhalf_b0_q;
			alias sub_hhalf_b1 is mem_sub_hhalf_b1_q;
			alias sub_lhalf_bo is mem_sub_lhalf_bo_q;
			alias sub_bo0 is  mem_sub_bo0_q;
			alias sub_bo1 is  mem_sub_bo1_q;

			alias logic is exe_alu_logic_d;
			signal logic_reg_reg : dword;
			signal logic_reg_imm : dword;

			alias arth_sht is exe_sel_arth_sht_q;
			alias disp_sht is exe_sht_disp_q;
			alias shtrot_d is exe_alu_shtrot_d;

		begin

			with exe_sel_logic_op_q select
				logic_reg_reg <= 
					rs1val or  rs2val when logic_or,
					rs1val and rs2val when logic_and,
					rs1val xor rs2val when logic_xor,
					(others => '-') when others;

			with exe_sel_logic_op_q select
				logic_reg_imm <= 
					rs1val or  sign_extn when logic_or,
					rs1val and sign_extn when logic_and,
					rs1val xor sign_extn when logic_xor,
					(others => '-') when others;

			with exe_sel_logic_reg_imm_q select
				logic <=
					logic_reg_reg when logic_rr,
					logic_reg_imm when logic_ri,
					(others => '-') when others;

			alu_addi_lhalf : syncUAdder
				generic map ((lhalf'range => '0'), '0')
				port map (rst, clk, addi_lhalf, rs1val_low, sign_extn_low, addi_lhalf_co);
			alu_addi_hhalf_c0 : syncUAdder
				generic map ((hhalf'range => '0'), '0')
				port map (rst, clk, addi_hhalf_c0, rs1val_high, sign_extn_high, addi_co0, cin => '0');
			alu_addi_hhalf_c1: syncUAdder
				generic map ((hhalf'range => '0'), '0')
				port map (rst, clk, addi_hhalf_c1, rs1val_high, sign_extn_high, addi_co1, cin => '1');

			alu_add_lhalf : syncUAdder
				generic map ((lhalf'range => '0'), '0')
				port map (rst, clk, sum_lhalf, rs1val_low, rs2val_low, sum_lhalf_co);
			alu_add_hhalf_c0 : syncUAdder
				generic map ((hhalf'range => '0'), '0')
				port map (rst, clk, sum_hhalf_c0, rs1val_high, rs2val_high, sum_co0, cin => '0');
			alu_add_hhalf_c1: syncUAdder
				generic map ((hhalf'range => '0'), '0')
				port map (rst, clk, sum_hhalf_c1, rs1val_high, rs2val_high, sum_co1, cin => '1');

			alu_sub_lhalf: syncUSub
				generic map ((lhalf'range => '0'), '0')
				port map (rst, clk, sub_lhalf, rs1val_low, rs2val_low, sub_lhalf_bo);

			alu_sub_hhalf_c0: syncUSub
				generic map ((hhalf'range => '0'), '0')
				port map (rst, clk, sub_hhalf_b0, rs1val_high, rs2val_high, sub_bo0, bin => '0');
			alu_sub_hhalf_c1 : syncUSub
				generic map ((hhalf'range => '0'), '0')
				port map (rst, clk, sub_hhalf_b1, rs1val_high, rs2val_high, sub_bo1, bin => '1');

			alu_shtrot: shtrot
				generic map (dword'length, 6) -- log2(dword'length)+1);
				port map ('1', arth_sht, disp_sht, rs1val, shtrot_d);

		end block;

		alu_logic_register : ffdArray 
			generic map ((dword'range => '0'))
			port map (rst, clk, mem_alu_logic_q, exe_alu_logic_d);
			
		alu_shtrot_register : ffdArray 
			generic map ((dword'range => '0'))
			port map (rst, clk, mem_alu_shtrot_q, exe_alu_shtrot_d);
			
		datain_register : ffdArray 
			generic map ((dword'range => '0'))
			port map (rst, clk, mem_datain_q, exe_datain_d);
			
		mem : block
			alias logic is mem_alu_logic_q;
			alias logic_lhalf is mem_alu_logic_q(lhalf'range);
			alias logic_hhalf is mem_alu_logic_q(hhalf'range);

			alias shtrot is mem_alu_shtrot_q;
			alias shtrot_lhalf is mem_alu_shtrot_q(lhalf'range);
			alias shtrot_hhalf is mem_alu_shtrot_q(hhalf'range);

			alias addi_lhalf is mem_addi_lhalf_q;
			alias addi_hhalf_c0 is mem_addi_hhalf_c0_q;
			alias addi_hhalf_c1 is mem_addi_hhalf_c1_q;
			alias addi_lhalf_co is mem_addi_lhalf_co_q;
			alias addi_co0 is  mem_addi_co0_q;
			alias addi_co1 is  mem_addi_co1_q;

			alias sum_lhalf is mem_sum_lhalf_q;
			alias sum_lhalf_co is mem_sum_lhalf_co_q;
			alias sum_hhalf_c0 is mem_sum_hhalf_c0_q;
			alias sum_hhalf_c1 is mem_sum_hhalf_c1_q;
			alias sum_co0 is mem_sum_co0_q;
			alias sum_co1 is mem_sum_co1_q;

			alias sub_lhalf is mem_sub_lhalf_q;
			alias sub_hhalf_b0 is mem_sub_hhalf_b0_q;
			alias sub_hhalf_b1 is mem_sub_hhalf_b1_q;
			alias sub_lhalf_bo is mem_sub_lhalf_bo_q;
			alias sub_bo0 is  mem_sub_bo0_q;
			alias sub_bo1 is  mem_sub_bo1_q;

			alias rdval is mem_rdval_d;
			alias rdval_lhalf is mem_rdval_d(lhalf'range);
			alias rdval_hhalf is mem_rdval_d(hhalf'range);
			alias t_bit is mem_t_bit_d;


			signal sum_hhalf : hhalf;
			signal sub_hhalf : hhalf;
			signal addi_hhalf : hhalf;

			signal sel_rdval_lhalf : std_ulogic_vector(2 downto 0);
			signal sel_rdval_hhalf : std_ulogic_vector(2 downto 0);
			signal sel_rdval_t_bit : std_ulogic_vector(2 downto 0);

			signal sum_t_bit : std_ulogic;
			signal sub_t_bit : std_ulogic;
			signal addi_t_bit : std_ulogic;

			alias datain is mem_datain_q;
			signal dataout : dword;
			alias dataout_lhalf is dataout(lhalf'range);
			alias dataout_hhalf is dataout(hhalf'range);
			alias data_write_address is mem_addi_lhalf_q;
			alias data_read_address is mem_addi_lhalf_q;
			alias data_rdval  is mem_addi_lhalf_q;

		begin
			sel_rdval_lhalf <= mem_sel_rdval_q;
			sel_rdval_hhalf <= mem_sel_rdval_q;
			sel_rdval_t_bit <= mem_sel_rdval_q;

			with sel_rdval_lhalf select
				rdval_lhalf <= 
					addi_lhalf    when rdval_addri,
					sum_lhalf     when rdval_addrr,
					sub_lhalf     when rdval_subrr,
					logic_lhalf   when rdval_logic,
					shtrot_lhalf  when rdval_shtrot,
					dataout_lhalf when rdval_load,
					(others => '-') when others;

			with sel_rdval_hhalf select
				rdval_hhalf <= 
					addi_hhalf    when rdval_addri,
					sum_hhalf     when rdval_addrr,
					sub_hhalf     when rdval_subrr,
					logic_hhalf   when rdval_logic,
					shtrot_hhalf  when rdval_shtrot,
					dataout_hhalf when rdval_load,
					(others => '-') when others;

			with sum_lhalf_co select
				sum_hhalf <=
					sum_hhalf_c1 when '1',
					sum_hhalf_c0 when '0',
					(others => '-') when others;

			with sub_lhalf_bo select
				sub_hhalf <=
					sub_hhalf_b1 when '1',
					sub_hhalf_b0 when '0',
					(others => '-') when others;

			with addi_lhalf_co select
				addi_hhalf <=
					addi_hhalf_c1 when '1',
					addi_hhalf_c0 when '0',
					(others => '-') when others;

			with addi_lhalf_co select
				addi_t_bit <=
					addi_co1 when '1',
					addi_co0 when '0',
					'-' when others;

			with sum_lhalf_co select
				sum_t_bit <=
					sum_co1 when '1',
					sum_co0 when '0',
					'-' when others;

			with sub_lhalf_bo select
				sub_t_bit <=
					sub_bo1 when '1',
					sub_bo0 when '0',
					'-' when others;

			with sel_aluout_t_bit select
				t_bit <= 
					addi_t_bit when rdval_addri,
					sum_t_bit  when rdval_addrr,
					sub_t_bit  when rdval_subrr,
					'-' when others;

			mem : dpram
				generic map (ridLen, dword'length)
				port map (
					clk   => clk,
					we    => mem_data_rw_q,
					wAddr => data_write_address,
					rAddr => data_read_address,
					dout  => data_out,
					din   => data_in);

		end block;

		write_back: block 
		begin
		end block;

 	end block;

 	ctrlUnit: block
		signal dec_null_q : std_ulogic;
		signal dec_brt_d  : std_ulogic;
		signal dec_jinc_d : std_ulogic;
		signal dec_opc_alu_d : std_ulogic;
		signal dec_opc_addi_d : std_ulogic;

		signal exe_brt_q : std_ulogic;
		signal exe_jinc_q : std_ulogic;
		signal exe_opc_addi_q : std_ulogic;

 	begin

		instrDec_comp : ffdArray 
			generic map ((code'range => '0'))
			port map (rst, clk, instrDec, code);

 		dec: block
 			alias opc is instrDec(opcFld);
 			alias rs1 is instrDec(rs1Fld);
 			alias rs2 is instrDec(rs2Fld);
 			alias fun is instrDec(funFld);

			alias t_bit is dec_t_bit_d;

		 	signal isJral : std_ulogic;
		 	signal isJal  : std_ulogic;
		 	signal isJimm : std_ulogic;
		 	signal isJmp  : std_ulogic;

 		begin

			dec_opc_alu_d <= SetIf(opc=alu);
 			dec_brt_d  <= SetIf(opc=brt);
			dec_jinc_d <= SetIf(opc=jal or opc=jral);
			
			isJimm <= SetIf(opc=jal or opc=brt);
 			isJal  <= SetIf(opc=jal);
 			isJral <= SetIf(opc=jral);
			isJmp  <= SetIf(opc=brt or opc=jral or opc=jal);

			selDisp12 <= isJal;

			branch_ctrl: process (rst,clk)
				variable pctrgt_low_cy : std_ulogic;
			begin
				if rst='1' then
					pcdisp_low_ena  <= '1';
					pcdisp_high_ena <= '1';
					pctrgt_high_ena <= '0';
					pctrgt_low_cy   := '0';
					ip_load <= '0';
				elsif rising_edge(clk) then
					pcdisp_low_ena  <= not isJimm;
					pcdisp_high_ena <= not isJimm and pcdisp_low_ena;
					pcdisp_to_0 <= pcdisp_low_ena and not pcdisp_high_ena;
					pctrgt_high_inc <= pctrgt_high_ena;

					if pcdisp_high_ena='0' then
						pctrgt_high_ena <= '1';
					elsif pctrgt_high_ena='1' then
						if pctrgt_low_cy='0' then
							pctrgt_high_ena <= '0';
						end if;
						pctrgt_low_cy := '0';
					end if;

					if pcdisp_high_ena='0' and pcdisp_low_ena='1' then
						pctrgt_low_cy := pctrgt_low_cout;
					end if;
					
					ip_load <= '0';
					if dec_null_q /= '1' then
						if dec_jinc_d = '1' then
							ip_load <= '1';
						end if;
						if dec_brt_d = '1' then
							ip_load <= t_bit;
						end if;
					end if;
					
				end if;				
			end process;
			pctrgt_high_cin <= pctrgt_low_cout or pctrgt_high_inc;

			logic_decode: process (rst,clk)
			begin
				if rst='1' then
					exe_sel_logic_op_q <= (others => '0');
				elsif rising_edge(clk) then
					case opc is
					when alu =>
						exe_sel_logic_reg_imm_q <= logic_rr;
						case fun is
						when alu_or  =>
							exe_sel_logic_op_q <= logic_or;
						when alu_and =>
							exe_sel_logic_op_q <= logic_and;
						when alu_xor =>
							exe_sel_logic_op_q <= logic_xor;
						when alu_asri =>
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
				end if;
			end process;

		end block;
		
		exe_instr_register : ffdArray 
			generic map ((code'range => '0'))
			port map (rst, clk, instrExe, instrDec);

		exe: block
 			alias opc is instrExe(opcFld);
 			alias rs1 is instrExe(rs1Fld);
 			alias rs2 is instrExe(rs2Fld);
 			alias fun is instrExe(funFld);
		begin
			exe_sel_arth_sht_q <= fun(alu_arth_sht_bit_num);
			exe_sht_disp_q <= fun(alu_dirn_sht_bit_num ) & fun(alu_dirn_sht_bit_num) & rs2;
			decode: process (clk)
			begin
				if rising_edge(clk) then
					if rst='1' then
						exe_jinc_q <= '0';
						exe_brt_q  <= '0';
						mem_sel_rdval_q <= (others => '0');
					else
						exe_jinc_q <= dec_jinc_d;
						exe_brt_q  <= dec_brt_d;
						case opc is
						when lb|lh|lw =>
							mem_data_rw_q <= '0';
						when sb|sh|sw =>
							mem_data_rw_q <= '1';
						when others =>
							mem_data_rw_q <= '-';
						end case;
						case opc is
						when alu =>
							case fun is
							when alu_add =>
								mem_sel_rdval_q <= rdval_addrr;
							when alu_sub =>
								mem_sel_rdval_q <= rdval_subrr;
							when alu_or|alu_and|alu_xor =>
								mem_sel_rdval_q <= aluout_logic;
							when alu_asri|alu_lsri|alu_lsli =>
								mem_sel_rdval_q <= rdval_shtrot;
							when others =>
								mem_sel_rdval_q <= (others => '-');
							end case;
						when addi =>
							mem_sel_rdval_q <= rdval_addri;
						when others =>
							mem_sel_rdval_q <= (others => '-');
						end case;
					end if;
				end if;
			end process;
 		end block;

		mem_instr_register : ffdArray 
			generic map ((code'range => '0'))
			port map (rst, clk, instrMem, instrExe);

		mem: block
 			alias opc is instrMem(opcFld);
 			alias fun is instrMem(funFld);
		begin
		end block;

 	end block;
end;
