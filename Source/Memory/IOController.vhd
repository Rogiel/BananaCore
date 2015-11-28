--
--  BananaCore - A processor written in VHDL
--
--  Created by Rogiel Sulzbach.
--  Copyright (c) 2014-2015 Rogiel Sulzbach. All rights reserved.
--

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library BananaCore;
use BananaCore.Memory.all;
use BananaCore.Core.Clock;

-- Implements a low level memory instance
entity IOController is
	port(
		-- the processor main clock
		clock: in Clock;
	
		-- the address to read/write memory from/to
		address: in MemoryAddress;
		
		-- the memory being read/written to
		memory_data: inout MemoryData;
		
		-- enables the memory
		selector: in bit;
				
		-- the operation to perform on the memory
		operation: in MemoryOperation;
		
		-- a flag indicating that a operation has completed
		ready: inout std_logic;
		
		-- io port: port0
		port0: in MemoryData;
		
		-- io port: port1
		port1: out MemoryData
	);
	
end IOController;

architecture IOControllerImpl of IOController is
begin process (clock) begin
	if clock'event and clock = '1' then
		if selector = '1' then
			case operation is
				when OP_READ  => 
					memory_data <= port0;
					ready <= '1';
				when OP_WRITE => 
					port1 <= memory_data;
					ready <= '1';
			end case;
		else
			memory_data <= (others => 'Z');
			ready <= 'Z';
		end if;
	end if;
end process;
	

end IOControllerImpl;