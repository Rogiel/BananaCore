--
--  BananaCore - A processor written in VHDL
--
--  Created by Rogiel Sulzbach.
--  Copyright (c) 2014-2015 Rogiel Sulzbach. All rights reserved.
--

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_1164.std_logic;

library BananaCore;
use BananaCore.Memory.all;
use BananaCore.Core.all;
use BananaCore.RegisterPackage.all;
use BananaCore.RegisterEntity;

-- A gateway that controls access to the register bus
entity LoadInstructionExecutor is
	port(
		-- the processor main clock 
 		clock: in BananaCore.Core.Clock;
		
		------------------------------------------
		-- MEMORY BUS
		------------------------------------------
		-- the address to read/write memory from/to 
 		memory_address: out MemoryAddress;
 		 
 		-- the memory being read/written to 
		memory_data: inout MemoryData;
 		 
 		-- the operation to perform on the memory 
 		memory_operation: out MemoryOperation;
		
		-- a flag indicating if a memory operation has completed
 		memory_ready: in std_logic;
		
		------------------------------------------
		-- REGISTER BUS
		------------------------------------------
		-- the processor memory address bus
		register_address: out RegisterAddress;
		
		-- the processor memory data bus
		register_data: inout RegisterData;
		
		-- the processor memory operation signal
		register_operation: out RegisterOperation;
		
		-- the processor memory operation signal
		register_enable: out std_logic
	);
end LoadInstructionExecutor;

architecture LoadInstructionExecutorImpl of LoadInstructionExecutor is
begin
	process (clock) begin
		if clock'event and clock = '1' then
			
			
			
		end if;
	end process;

end LoadInstructionExecutorImpl;