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
use hdl4fpga.usbpkg.all;

entity usbdevrqst is
	 generic (
		descriptor : string);
	port (
		tp        : out std_logic_vector(1 to 32) := (others => '0');
		clk       : in  std_logic;
		cken      : in  std_logic;

		dev_addr  : out std_logic_vector(0 to 7-1);
		dev_cfgd  : out std_logic;
		rqst_req  : in  bit;
		rqst_rdy  : buffer bit;

		rxpidv    : in  std_logic := '-';
		rxpid     : in  std_logic_vector(4-1 downto 0) := (others => '0');
		rxbs      : in  std_logic := '-';
		rxd       : in  std_logic := '-';

		in_req    : in  bit;
		in_rdy    : buffer  bit;
		ack_req   : in  bit;
		ack_rdy   : buffer  bit;
		phyerr    : in  std_logic;
		tkerr     : in  std_logic;
		crcerr    : in  std_logic;
		txen      : out std_logic;
		txbs      : in  std_logic;
		txd       : out std_logic);

	type requests is (
		-- get_status,
		-- clear_status,
		-- set_feature,
		set_address,
		get_descriptor,
		-- set_descriptor,
		-- get_configuration,
		set_configuration);
		-- get_interface,
		-- set_interface,
		-- synch_frame);

	type bit_requests is array(requests) of bit;
	type requestid_vector is array(requests) of std_logic_vector(4-1 downto 0);
	constant request_ids : requestid_vector := (
		-- get_status        => x"0",
		-- clear_status      => x"1",
		-- set_feature       => x"3",
		set_address       => x"5",
		get_descriptor    => x"6",
		-- set_descriptor    => x"7",
		-- get_configuration => x"8",
		set_configuration => x"9");
		-- get_interface     => x"a",
		-- set_interface     => x"b",
		-- synch_frame       => x"c");

	type decriptor_types is (
		device, 
		config, 
		str   , 
		interface, 
		endpoint);
	type decriptortypes_vector is array(decriptor_types) of std_logic_vector(8-1 downto 0);
end;

architecture def of usbdevrqst is

	signal requesttype : std_logic_vector( 8-1 downto 0);
	signal request   : std_logic_vector( 8-1 downto 0);
	signal value     : std_logic_vector(16-1 downto 0);
	signal index     : std_logic_vector(16-1 downto 0);
	signal length    : unsigned(16-1 downto 0);

	signal rqst_rdys : bit_requests;
	signal rqst_reqs : bit_requests;

	alias setaddress_rdy    is rqst_rdys(set_address);
	alias setaddress_req    is rqst_reqs(set_address);
	alias getdescriptor_rdy is rqst_rdys(get_descriptor);
	alias getdescriptor_req is rqst_reqs(get_descriptor);
	alias setconfiguration_rdy is rqst_rdys(set_configuration);
	alias setconfiguration_req is rqst_reqs(set_configuration);

	signal descriptor_txen : std_logic;
	signal descriptor_txd  : std_logic;
	signal rqstdata_req    : bit;
	signal rqstdata_rdy    : bit;
	signal reply_rdy       : bit;
	signal reply_req       : bit;

begin

	setup_p : process (cken, clk)
		type states is (s_idle, s_data, s_reply);
		variable state : states;
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (rqst_req xor rqst_rdy)='1' then
					case state is
					when s_idle =>
						if (rqst_rdy xor rqst_req)='1' then
							rqstdata_req <= not rqstdata_rdy;
							state := s_data;
						end if;
					when s_data =>
						if rxpidv='0' then
							if (rqstdata_req xor rqstdata_rdy)='0' then
								reply_req <= not reply_rdy;
								state := s_reply;
							end if;
						end if;
					when s_reply =>
						if (reply_rdy xor reply_req)='0' then
							rqst_rdy <= rqst_req;
						end if;
					end case;
				else
					state := s_idle;
				end if;
			end if;
		end if;
	end process;

	rqstdata_p : process (reply_req, clk)
		type states is (s_idle, s_data);
		variable state : states;
		variable data : unsigned(0 to 64+2*8-1);
		variable shr  : unsigned(data'range);
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (rqst_req xor rqst_rdy)='1' then
					case state is
					when s_idle =>
						if (rqstdata_req xor rqstdata_rdy)='1' then
							if rxpidv='1'then
								state := s_data;
							end if;
						end if;
					when s_data =>
						if rxpidv='0' then
							rqstdata_rdy <= rqstdata_req;
							state := s_idle;
						end if;
					end case;
				else
					state := s_idle;
				end if;

				if (rqstdata_req xor rqstdata_rdy)='1' then
					if rxpidv='1' then
						if rxbs='0' then
							data(0) := rxd;
							data := data rol 1;
						end if;
					end if;
				elsif (phyerr or crcerr)='0' then
					shr := data;
					requesttype <= reverse(std_logic_vector(shr(0 to requesttype'length-1)));
					shr := shr rol requesttype'length;
					request <= reverse(std_logic_vector(shr(0 to request'length-1)));
					shr := shr rol request'length;
					value   <= reverse(std_logic_vector(shr(0 to value'length-1)));
					shr := shr rol value'length;
					index   <= reverse(std_logic_vector(shr(0 to index'length-1)));
					shr := shr rol index'length;
					length  <= unsigned(reverse(std_logic_vector(shr(0 to length'length-1))));
					shr := shr rol length'length;
				end if;
			end if;
		end if;
	end process;

	request_p : process (rqst_req, clk)
		type states is (s_idle, s_rqst);
		variable state : states;
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (rqst_req xor rqst_rdy)='1' then
					case state is
					when s_idle =>
						if (reply_rdy xor reply_req)='1' then
							for i in request_ids'range loop
								if request(4-1 downto 0)=request_ids(i) then
									rqst_reqs(i) <= not rqst_rdys(i);
									state := s_rqst;
									exit;
								end if;
								if i=request_ids'right then
									reply_rdy <= reply_req;
								end if;
								assert i/=request_ids'right report requests'image(i) severity error;
							end loop;
						end if;
					when s_rqst =>
						for i in request_ids'range loop
							if (rqst_rdys(i) xor rqst_reqs(i))='1' then
								exit;
							end if;
							if i=request_ids'right then
								reply_rdy <= reply_req;
								state := s_idle;
							end if;
						end loop;
					end case;
				else
					state := s_idle;
				end if;
			end if;
		end if;
	end process;

	setaddress_p : process (setaddress_rdy, clk)
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (setaddress_rdy xor setaddress_req)='1' then
					dev_addr <= reverse(value(dev_addr'reverse_range));
					setaddress_rdy <= setaddress_req;
				end if;
			end if;
		end if;
	end process;

	despcriptor_b : block
		
		constant sections             : string           := description_section(descriptor);
		constant layout               : string           := section_layout(sections);
		constant section_content      : std_logic_vector := layout**".content";

		constant layout_table         : string           := section_table(layout**".table");
		constant layout_table_content : std_logic_vector := layout_table**".content";

		constant descriptors_length   : string           := layout_table**".length";
		constant descriptors_offset   : string           := layout_table**".offset";

		signal layout_table_addr      : std_logic_vector(0 to layout_table**".address"-1);
		signal layout_table_data      : std_logic_vector(descriptors_offset**".left" to descriptors_length**".right");
		signal descriptor_addr        : std_logic_vector(descriptors_offset**".left" to descriptors_offset**".right");
		signal descriptor_data        : std_logic_vector(0 to 0);

		alias descriptor_offset is layout_table_data(descriptors_offset**".left" to descriptors_offset**".right");
		alias descriptor_length is layout_table_data(descriptors_length**".left" to descriptors_length**".right");

	begin

		decode_b : block
			constant decode_tab : string := description_decode(sections);
			constant wValue_tab : std_logic_vector := decode_tab**".wValue";
			constant wIndex_tab : std_logic_vector := decode_tab**".wIndex";
			constant mask_tab   : std_logic_vector := decode_tab**".mask";
		begin
    		process(value, Index)
    			constant wMask : std_logic_vector(0 to 16-1) := x"0300";
    		begin
    			layout_table_addr <= (others => '-');
    			for i in mask_tab'range loop
    				if ((wValue_tab(i*16 to (i+1)*16-1) xor value) and wMask)=(0 to 16-1 => '0') then
    					if mask_tab(i)='1' then
    						if ((wIndex_tab(i*16 to (i+1)*16-1)) xor index)=(0 to 16-1 => '0') then
    							layout_table_addr <= std_logic_vector(to_unsigned(i, layout_table_addr'length));
    							exit;
    						end if;
    					else
    						layout_table_addr <= std_logic_vector(to_unsigned(i, layout_table_addr'length));
    						exit;
    					end if;
    				end if;
    			end loop;
    		end process;
		end block;

		meta_e : entity hdl4fpga.rom
		generic map (
			bitrom => layout_table_content)
		port map (
			addr => layout_table_addr,
			data => layout_table_data);

		data_e : entity hdl4fpga.rom
		generic map (
			bitrom => section_content)
		port map (
			addr => descriptor_addr,  
			data => descriptor_data);

		getdescriptor_p : process (getdescriptor_rdy, clk)
			type states is (s_idle, s_data);
			variable state : states;

			-- variable descriptor_cntr : unsigned(descriptors_length**".left" to descriptors_length**".right");
			variable descriptor_cntr : unsigned(0 to descriptor_length'length);
		begin
			if rising_edge(clk) then
				if cken='1' then
					if (getdescriptor_rdy xor getdescriptor_req)='1' then
						case state is
						when s_idle => 
							if shift_right(descriptor_cntr, 3) > length  then
								descriptor_cntr := shift_left(resize(length, descriptor_cntr'length),3);
							else
								descriptor_cntr := resize(unsigned(descriptor_length), descriptor_cntr'length);
							end if;
							descriptor_cntr := descriptor_cntr-1;
							descriptor_addr <= descriptor_offset;
						when s_data =>
							if descriptor_cntr(0)='0' then
								if txbs='0' then
									descriptor_cntr := descriptor_cntr - 1;
									descriptor_addr <= std_logic_vector(unsigned(descriptor_addr) + 1); --ghdl
								end if;
							elsif (in_rdy xor in_req)='1' then
								state := s_idle;
							elsif (ack_rdy xor ack_req)='1' then
								getdescriptor_rdy <= getdescriptor_req;
								state := s_idle;
							end if;
							in_rdy  <= in_req;
							ack_rdy <= ack_req;
						end case;
					else
						descriptor_cntr := (others=> '1');
						state := s_idle;
					end if;
					descriptor_txen <= not descriptor_cntr(descriptor_cntr'left);
				end if;
			end if;
		end process;
		descriptor_txd <= descriptor_data(0);
	end block;

	setconfiguration_p : process (setconfiguration_rdy, clk)
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (setaddress_rdy xor setaddress_req)='1' then
					dev_cfgd <= '0';
				elsif (setconfiguration_rdy xor setconfiguration_req)='1' then
					dev_cfgd <= '1';
					setconfiguration_rdy <= setconfiguration_req;
				end if;
			end if;
		end if;
	end process;

	(txen, txd) <= 
		std_logic_vector'(descriptor_txen, descriptor_txd) when request(4-1 downto 0)=request_ids(get_descriptor) else
		std_logic_vector'('0', '-');

	tp(1) <= to_stdulogic(rqst_reqs(set_address));
	tp(2) <= to_stdulogic(rqst_rdys(set_address));
	tp(3) <= to_stdulogic(rqst_reqs(get_descriptor));
	tp(4) <= to_stdulogic(rqst_rdys(get_descriptor));

end;
