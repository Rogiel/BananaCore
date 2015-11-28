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

-- The {EntityName} entity
entity {EntityName} is
	port(
		-- the processor main clock 
 		clock: in BananaCore.Core.Clock;

		-- enables the instruction
		enable: in std_logic;

		-- the first register to operate on (argument 0)
		arg0: in RegisterAddress;

		-- the first register to operate on (argument 1)
		arg1: in RegisterAddress;

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
		-- the processor register address bus
		register_address: out RegisterAddress;
		
		-- the processor register data bus
		register_data: inout RegisterData;
		
		-- the processor register operation signal
		register_operation: out RegisterOperation;
		
		-- the processor register enable signal
		register_enable: out std_logic
	);
end {EntityName};

architecture {EntityName}Impl of {EntityName} is
begin
	process (clock) begin
		if clock'event and clock = '1' then
			
			-- TODO implement instruction here
			
		end if;
	end process;

end {EntityName}Impl;