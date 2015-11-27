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
package Core is
	-- Declares the processor native data width
	constant DataWidth : integer := 16;

	-- Represents the clock type
	subtype Clock is bit;
end package Core;


library ieee;
use ieee.numeric_bit.all;
use ieee.std_logic_1164.all;

library BananaCore;

use BananaCore.InstructionController;
use BananaCore.Instruction.DecodedInstruction;

use BananaCore.ClockController;
use BananaCore.Core.all;

use BananaCore.Memory.all;
use BananaCore.MemoryController;

use BananaCore.Numeric.Word;

use BananaCore.ULA;

use BananaCore.RegisterEntity;

-- Implements the processor entry point
entity BananaCore is
	generic(
		-- the data width to be used within the processor
		DataWidth: integer := 32
	);
	port(
		clock: in Clock;
	
		-- io port: port0
		port0: inout bit_vector(DataWidth-1 downto 0);
		
		-- io port: port1
		port1: inout bit_vector(DataWidth-1 downto 0);
		
		-- io port: port2
		port2: inout bit_vector(DataWidth-1 downto 0)
	);
end BananaCore;

architecture BananaCoreImpl of BananaCore is
	-- the processor memory address bus
	signal memory_address: MemoryAddress;
	
	-- the processor memory data bus
 	signal memory_data: MemoryData;
	
	-- the processor memory operation signal
 	signal memory_operation: MemoryOperation;
	
	-- a signal that indicates if a memory operation has completed
	signal memory_ready: std_logic;
	
begin
	
	memory_controller: MemoryController
	port map(
		clock => clock,
		address => memory_address,
		memory_data => memory_data,
		operation => memory_operation,
		ready => memory_ready
	);
	
	instruction_controller: InstructionController
	port map(
		clock => clock,
		memory_address => memory_address,
		memory_data => memory_data,
		memory_operation => memory_operation,
		memory_ready => memory_ready
	);

end BananaCoreImpl;
