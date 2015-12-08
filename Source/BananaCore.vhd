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
	
	-- Represents a data
	subtype IOPortData is std_logic_vector(DataWidth-1 downto 0);
end package Core;


library ieee;
use ieee.numeric_bit.all;
use ieee.std_logic_1164.all;

library BananaCore;

use BananaCore.InstructionController;
use BananaCore.Instruction.DecodedInstruction;

use BananaCore.Core.all;

use BananaCore.Memory.all;
use BananaCore.MemoryController;

use BananaCore.RegisterPackage.all;
use BananaCore.RegisterController;

use BananaCore.Numeric.Word;
use BananaCore.RegisterEntity;

-- Implements the processor entry point
entity BananaCore is
	port(
		clock: in Clock;

		-- io port: port0
		port0: in IOPortData;

		-- io port: port1
		port1: out IOPortData
	);
end BananaCore;

architecture BananaCoreImpl of BananaCore is
	------------------------------------------
	-- MEMORY BUS
	------------------------------------------

	-- the processor memory address bus
	signal memory_address: MemoryAddress;

	-- the processor memory data bus
 	signal memory_data_read: MemoryData;

	-- the processor memory data bus
 	signal memory_data_write: MemoryData;

	-- the processor memory operation signal
 	signal memory_operation: MemoryOperation;

	-- a signal that indicates if a memory operation should be performed
	signal memory_enable: std_logic;

	-- a signal that indicates if a memory operation has completed
	signal memory_ready: std_logic;

	attribute keep: boolean;
	attribute keep of memory_address: signal is true;
	attribute keep of memory_data_read: signal is true;
	attribute keep of memory_data_write: signal is true;
	attribute keep of memory_operation: signal is true;
	attribute keep of memory_enable: signal is true;
	attribute keep of memory_ready: signal is true;

	------------------------------------------
	-- REGISTER BUS
	------------------------------------------

	-- the processor register address bus
	signal register_address: RegisterAddress;

	-- the processor register data bus
 	signal register_data_read: RegisterData;

	-- the processor register data bus
 	signal register_data_write: RegisterData;

	-- the processor register operation signal
 	signal register_operation: RegisterOperation;

	-- the processor register operation signal
	signal register_enable: std_logic;
	signal register_ready: std_logic;

	attribute keep of register_address: signal is true;
	attribute keep of register_data_read: signal is true;
	attribute keep of register_data_write: signal is true;
	attribute keep of register_operation: signal is true;
	attribute keep of register_enable: signal is true;
	attribute keep of register_ready: signal is true;

begin

	memory_controller: MemoryController
	port map(
		clock => clock,
		address => memory_address,
		memory_data_read => memory_data_read,
		memory_data_write => memory_data_write,
		operation => memory_operation,
		enable => memory_enable,
		ready => memory_ready
	);

	register_controller: RegisterController
	port map(
		clock => clock,
		address => register_address,
		data_read => register_data_read,
		data_write => register_data_write,
		operation => register_operation,
		enable => register_enable,
		ready => register_ready
	);

	instruction_controller: InstructionController
	port map(
		clock => clock,
		memory_address => memory_address,
		memory_data_read => memory_data_read,
		memory_data_write => memory_data_write,
		memory_operation => memory_operation,
		memory_enable => memory_enable,
		memory_ready => memory_ready,

		register_address => register_address,
		register_data_read => register_data_read,
		register_data_write => register_data_write,
		register_operation => register_operation,
		register_enable => register_enable,
		register_ready => register_ready,

		port0 => port0,
		port1 => port1
	);

end BananaCoreImpl;
