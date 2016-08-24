	for i in sclk_phases sclk_edges data_phases data_edges cmd_phases bank_size addr_size word_size line_size byte_size data_gear ; do
		e=`echo $i | tr '[:lower:]' '[:upper:]'` 
		sed -i.bak s/$i/$e/g $1
	done
