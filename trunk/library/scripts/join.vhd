function split (
	constant arg : std_logic_vector)
	return %byte%_vector is
	variable dat : unsigned(arg'length-1 downto 0);
	variable val : %byte%_vector(arg'length/%byte%'length-1 downto 0);
begin
	dat := unsigned(arg);
	for i in val'reverse_range loop
		val(i) := std_logic_vector(dat(%byte%'range));
		dat := dat srl val(val'left)'length;
	end loop;
	return val;
end;

function join (
	constant arg : %byte%_vector)
	return std_logic_vector is
	variable dat : %byte%_vector(arg'length-1 downto 0);
	variable val : std_logic_vector(arg'length*arg(arg'left)'length-1 downto 0);
begin
	dat := unsigned(arg);
	for i in dat'range loop
		val := val sll arg(arg'left)'length;
		val(arg(arg'left)'range) := dat(i);
	end loop;
	return val;
end;
