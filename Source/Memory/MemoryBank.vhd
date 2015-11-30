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
entity MemoryBank is
	generic(
		-- the number of bits available in the memory
		Size: integer
	);
	port(
		-- the processor main clock
		clock: in Clock;
	
		-- the address to read/write memory from/to
		address: in MemoryAddress;
		
		-- the memory being read/written to
		memory_data_read: out MemoryData;
				
		-- the memory being read/written to
		memory_data_write: in MemoryData;
				
		-- the operation to perform on the memory
		operation: in std_logic;
		
		-- a flag indicating that a operation has completed
		ready: inout std_logic
	);
	
end MemoryBank;

architecture MemoryBankImpl of MemoryBank is

	type MemoryBankStorage is array (0 to Size-1) of MemoryData;
   signal storage : MemoryBankStorage;

begin process (clock) begin
	if clock'event and clock = '1' then
		case operation is
			when MEMORY_OP_READ  => 
				memory_data_read <= storage(to_integer(address));
				ready <= '1';
			when MEMORY_OP_WRITE => 
				storage(to_integer(address)) <= memory_data_write;
				ready <= '1';
		end case;
	end if;
end process;
	

end MemoryBankImpl;