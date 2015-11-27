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
	
	function integer_to_memory_address(address : integer) return MemoryAddress;
	function bits_to_memory_address(address : std_logic_vector(DataWidth-1 downto 0)) return MemoryAddress;
end package Memory;

package body Memory is
	function integer_to_memory_address(address : integer)
	return MemoryAddress is begin
		return to_unsigned(address, DataWidth);
	end integer_to_memory_address;
	
	function bits_to_memory_address(address : std_logic_vector(DataWidth-1 downto 0))
	return MemoryAddress is begin
		return to_unsigned(to_integer(unsigned(address)), DataWidth);
	end bits_to_memory_address;
end Memory;

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_1164.std_logic;

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
		operation: in MemoryOperation;
		
		-- a flag indicating that a operation has completed
		ready: out std_logic
	);
	
end MemoryController;

architecture MemoryControllerImpl of MemoryController is
	-- a delimiter that sets whenever the memory returned should switch to being IO
	constant IO_MAPPING_DELIMITER : MemoryAddress := "1111111100000000";
	
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
		operation => operation,
		ready => ready
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