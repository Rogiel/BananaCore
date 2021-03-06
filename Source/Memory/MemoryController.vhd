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
	subtype MemoryOperation is std_logic;

	-- Represents a memory address
	subtype MemoryAddress is unsigned(DataWidth-1 downto 0);
	
	-- Represents a data
	subtype MemoryData is std_logic_vector(7 downto 0);
	
	-- Declares the write operation constant
	constant MEMORY_OP_WRITE : MemoryOperation := '1';
	
	-- Declares the read operation constant
	constant MEMORY_OP_READ : MemoryOperation := '0';
	
	-- Declares the read operation constant
	constant MEMORY_OP_DISABLED : MemoryOperation := 'Z';
	
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
		memory_data_write: in MemoryData;
		
		-- the memory being read/written to
		memory_data_read: out MemoryData;
		
		-- the operation to perform on the memory
		operation: in std_logic;
		
		-- a flag indicating that a operation should be performed
		enable: in std_logic;
		
		-- a flag indicating that a operation has completed
		ready: out std_logic
	);
	
end MemoryController;

architecture MemoryControllerImpl of MemoryController is
--	-- a delimiter that sets whenever the memory returned should switch to being IO
--	constant IO_MAPPING_DELIMITER : MemoryAddress := "1111111111111110";
--	
--	-- the memory bank selector (enables the memory bank)
--	signal memory_bank_selector : bit := '0';
--	signal io_selector : bit := '0';

begin
	memory_bank: MemoryBank
	generic map(Size => 512)
	port map(
		clock => clock,
		address => address,
		memory_data_read => memory_data_read,
		memory_data_write => memory_data_write,
		operation => operation,
		enable => enable,
		ready => ready
	);
--	
--	io_controller: IOController
--	port map(
--		clock => clock,
--		address => address,
--		memory_data => memory_data,
--		selector => io_selector,
--		operation => operation,
--		ready => ready,
--		
--		port0 => port0,
--		port1 => port1
--	);

end MemoryControllerImpl;