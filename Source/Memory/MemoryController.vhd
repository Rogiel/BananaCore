--
--  BananaCore - A processor written in VHDL
--
--  Created by Rogiel Sulzbach.
--  Copyright (c) 2014-2015 Rogiel Sulzbach. All rights reserved.
--

library ieee;
use ieee.numeric_bit.all;
use ieee.std_logic_1164.all;

library BananaCore;
use BananaCore.Core.all;
package Memory is
	-- Represents a memory operation
	type MemoryOperation is (
		-- Writes to the memory
		OP_WRITE,
		
		-- Reads the memory
		OP_READ
	);
		
	-- Represents a memory address
	subtype MemoryAddress is unsigned(DataWidth-1 downto 0);
	
	-- Represents a data
	subtype MemoryData is std_logic_vector(7 downto 0);
end package Memory;

library ieee;
use ieee.numeric_bit.all;

library BananaCore;
use BananaCore.Memory.all;
use BananaCore.Core.all;
use BananaCore.MemoryBank;

-- A gateway that controls access to the raw processor memory
entity MemoryController is
	port(
		-- the processor main clock
		clock: in BananaCore.Core.Clock;
	
		-- the address to read/write memory from/to
		address: in MemoryAddress;
		
		-- the memory being read/written to
		memory_data: inout MemoryData;
		
		-- the operation to perform on the memory
		operation: in MemoryOperation
	);
	
end MemoryController;

architecture MemoryControllerImpl of MemoryController is
	-- a delimiter that sets whenever the memory returned should switch to being IO
	constant IO_MAPPING_DELIMITER : MemoryAddress := "11111111111111111111111100000000";
	
	-- the memory bank selector (enables the memory bank)
	signal memory_bank_selector : bit;
begin
	memory_bank: MemoryBank
	generic map(Size => 256 * 1024)
	port map(
		clock => clock,
		address => address,
		memory_data => memory_data,
		selector => memory_bank_selector,
		operation => operation
	);

	process (clock) begin
		if clock'event and clock = '1' then
			
			if address <= IO_MAPPING_DELIMITER then
				memory_bank_selector <= '1';
			else
				memory_bank_selector <= '0';
			end if;
			
		end if;
	end process;

end MemoryControllerImpl;