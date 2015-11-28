--
--  BananaCore - A processor written in VHDL
--
--  Created by Rogiel Sulzbach.
--  Copyright (c) 2014-2015 Rogiel Sulzbach. All rights reserved.
--

library ieee;  
use ieee.std_logic_1164.all;  

library BananaCore;
use BananaCore.Core.all;
use BananaCore.RegisterPackage.all;

entity RegisterEntity is  
  port(
		-- the processor main clock
		clock: in BananaCore.Core.Clock;
		
		-- data bus
		data: inout RegisterData;
		
		-- register enabler
		enable: in std_logic;
		
		-- register operation
		operation: in RegisterOperation
	);  
end RegisterEntity;  

architecture RegisterImpl of RegisterEntity is 

signal storage: RegisterData;

begin  
	process (clock) begin  
		if (clock'event and clock='1') then 
			if enable = '1' then
				case operation is
					when OP_REG_GET =>
						data <= storage;
					when OP_REG_SET =>
						storage <= data;
				end case;
			else
				data <= (others => 'Z');
			end if;
		end if;	
	end process;  
end RegisterImpl; 
