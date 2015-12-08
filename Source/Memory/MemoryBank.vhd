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
		
		-- a flag indicating that a operation should be performed
		enable: in std_logic;
		
		-- a flag indicating that a operation has completed
		ready: out std_logic := '0'
	);
	
end MemoryBank;

architecture MemoryBankImpl of MemoryBank is

	type MemoryBankStorage is array (0 to Size-1) of MemoryData;
   signal storage : MemoryBankStorage := (
		"00000011",
"00000000",
"00000000",
"00100001",
"00000000",
"00000000",
"00000000",
"00100010",
"00000000",
"00000001",
"00000000",
"00100011",
"00000000",
"00000001",
"00010010",
"00100000",
"00000000",
"00000010",
"00001110",
"00010001",
"00000011",
"00000000",
"00000000",
"00001110",
"00110101",
"00000001",
"00100010",
"00000000",
"00001110",
"00000010",
"00100000",
"00100000",
"00000000",
"00000000",

--	
--		-- LOAD
--		"00000000",
--		"00100000",
--		"00000000",
--		"00001000",
--		
--		--LOAD
--		"00000000",
--		"00100001",
--		"00000000",
--		"00000000",
--		
--		--LOAD
--		"00000000",
--		"00100010",
--		"00000000",
--		"00000001",
--		
--		--LOAD
--		"00000000",
--		"00100011",
--		"00000000",
--		"00000001",
--		
--		-- MULTIPLY
--		"00010010",
--		"00100000",
--		
--		-- LOAD
--		"00000000",
--		"00000010",
--		"00001110",
--		"00010001",
--		
--		-- SUBTRACT
--		"00000011",
--		"00000000",
--		
--		-- LOAD
--		"00000000",
--		"00001110",
--		
--		-- COMPARE !=
--		"00110101",
--		"00000001",
--		
--		-- JUMP IF CARRY
--		"00100010",
--		"00000000",
--		"00010000",
--		
--		-- WRITE IO
--		"00000010",
--		"00100000",
--				
--		-- WRITE IO
--		"00000010",
--		"00100000",
--		
--		-- HALT
--		"11111110",
		
		others => "00000000"
	);

begin process (clock) begin
	if clock'event and clock = '1' then
		if enable = '1' then
			case operation is
				when MEMORY_OP_READ  => 
					memory_data_read <= storage(to_integer(address));
					ready <= '1';
				when MEMORY_OP_WRITE => 
					storage(to_integer(address)) <= memory_data_write;
					ready <= '1';
			end case;
		else
			ready <= '0';
		end if;
	end if;
end process;
	

end MemoryBankImpl;