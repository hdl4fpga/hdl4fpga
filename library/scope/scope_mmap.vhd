library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;

entity scopeio_mmap is
	port (
		in_clk       : in  std_logic;
		in_ena       : in  std_logic;
		in_data      : in  std_logic_vector;

		trigger_edge    : out std_logic;
		trigger_level   : out std_logic_vector;
		trigger_channel : out std_logic_vector;

		hzaxis_data  : out std_logic_vector;
		vtaxis_data  : out std_logic_vector);
end;

architecture beh of scopeio_downsampler is
	signal dev_ena :
begin

	process (in_clk)
	begin
		if rising_edge(in_clk) then
			if in_ena='1' then
				if ptr(0) /= '1' then
					data(in_data'range) := in_data;
					data := data rol in_data'length;
					ptr := ptr + 1;
				else
					dev_id <= data(devid'range);
					data   := data ror devid'length;
					reg_id <= data(regid'range);
				end if;
			else
				ptr := (others => '0');
			end if;
		end if;
	end process;
	dev_ena <= demux(dev_id, ptr(0));
	reg_ena <= demux(reg_id, ptr(0)); 

	regfile_b : block 
		constant max_rid : natural := rid_channel+1;

		type rgtr_param record
			regid  : natural;
			offset : natural;
			size   : natural;
		end record;

		type rparam_vector array (natural range <>) of rgtr_param;

		constant rgtr_tgrlevel   : natural := 0;
		constant rgtr_tgrchannel : natural := 1;

		constant rgtr_map : regmap_vector := (		-- Map Descritpion
			(rgtr_tgrlevel,   10),
			(rgtr_tgrchannel,  5));

		signal value : std_logic_vector(0 to 64-1);
	begin

		cp_p : process (in_clk)
			variable aux : unsigned(value'range);
		begin
			if rising_edge(in_clk) then
				aux := unsigned(value);
				if in_ena='1' then
					aux(in_data'range) := unsigned(in_data);
					aux := aux sll in_data'length;
				end if;
				value <= std_logic_vector(aux);
			end if;
		end process;

		process (in_clk)
		begin
			if rising_edge(in_clk) then
				if in_ena='0' then
					ptr := (others => '0');
				else
					ptr := ptr + in_data'length;
				end if;
			end if;
		end process;

		process (in_clk)
			variable len : unsigned;
		begin
			if rising_edge(in_clk) then
				if in_ena='0' then
					reg_state := regS_id;
				elsif ptr(0)='1' then
					case reg_state is
					when regS_id =>
						len := (others => '0');
						reg_id <= value(reg_id'range);
						reg_state := regS_size;
					when regS_size =>
						len := unsigned(value(cntr'range));
						reg_state := regS_data;
					when regS_data =>
						if len=(len'range => '0') then
							len := (others => '0');
							reg_state := regS_id;
							reg_val <= value(reg'range);
						else
							len := len - 1;
							reg_state := regS_data;
						end if;
					end case;
				end if;
			end if;
		end process;
 
		process (in_clk)
			variable aux : unsigned(rgtr'range);
		begin
			if rising_edge(in_clk) then
				aux := unsigned(rgtr);
				if then
					for i in rgtr_map'range loop
						if i=to_integer(unsigned(reg_id)) then
							aux(0 to rgtr_map(i).len-1) := unsigned(value(0 to rgtr_map(i).len-1));
						end if;
						aux := aux rol rgtr_map(i).size;
					end loop;
				end if;
				rtgr <= std_logic_vector(aux);
			end if;
		end process;

		rgtr_g : for rid in rgtr_map'range generate


			signal  rgtr : std_logic_vector(0 to rgtr_map(i).size-1);
		begin

			(rgtr_slice'range) <= rgtr;

		end generate;
	end block;

			if pll_rdy='1' then
				for i in 0 to inputs-1 loop
					if i=to_integer(unsigned(scope_channel(channel_select'range))) then
						case scope_cmd(3 downto 0) is
						when "0000" =>
							channel_scale  <= byte2word(channel_scale, 
											  scope_data(vt_scale'range),
											  reverse(std_logic_vector(to_unsigned(2**i, inputs))));
							channel_decas  <= byte2word(channel_decas, 
											  vt_scales(to_integer(unsigned(scope_data(vt_scale'range)))).deca,
											  reverse(std_logic_vector(to_unsigned(2**i, inputs))));
							channel_select <= std_logic_vector(to_unsigned(i, channel_select'length));

							vt_scale       <= scope_data(vt_scale'range);
						when "0001" =>
							channel_offset <= byte2word(channel_offset, std_logic_vector(resize(signed(scope_data), vt_size)), reverse(std_logic_vector(to_unsigned(2**i, inputs))));
							vt_pos   <= std_logic_vector(resize(signed(scope_data), vt_pos'length));
						when others =>
						end case;
					end if;
				end loop;

				case scope_cmd(3 downto 0) is
				when "0010" =>
					trigger_level   <= std_logic_vector(resize(signed(scope_data), vt_size));
					trigger_channel <= std_logic_vector(resize(unsigned(scope_channel and x"7f"),trigger_channel'length));
					trigger_edge    <= scope_channel(scope_channel'left);
				when "0011" =>
					hz_scale        <= scope_data(hz_scale'range);
					time_deca       <= hz_scales(to_integer(unsigned(scope_data(hz_scale'range)))).deca;
					g_hzscale       <= hz_scales(to_integer(unsigned(scope_data(hz_scale'range)))).scale;
				when others =>
				end case;
			end if;
		end if;
	end process;
	process (input_clk)
	begin
		if rising_edge(input_clk) then
			output_ena <= cntr(cntr'left) and input_ena;
			if input_ena='1' then
				if cntr(cntr'left)='1' then
					cntr <= signed(factor_data);
				else
					cntr <= cntr - 1;
				end if;
			end if;
		end if;
	end process;

	lat_e : entity hdl4fpga.align
	generic map (
		n => input_data'length,
		d => (input_data'range => 1)
	port map (
		clk => clk,
		di  => input_data,
		do  => output_data);
end;
