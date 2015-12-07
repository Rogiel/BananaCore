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
use BananaCore.Memory.all;
use BananaCore.RegisterPackage.all;

-- The JumpInstructionExecutor entity
entity JumpInstructionExecutor is
	port(
		-- the processor main clock
 		clock: in BananaCore.Core.Clock;

		-- enables the instruction
		enable: in std_logic;

		-- the first register to operate on (argument 0)
		arg0_address: in MemoryAddress;

		-- a bus indicating if the instruction is ready or not
		instruction_ready: out std_logic := '0';

		------------------------------------------
		-- MEMORY BUS
		------------------------------------------
		-- the address to read/write memory from/to
 		memory_address: out MemoryAddress := (others => '0');

 		-- the memory being read to
		memory_data_read: in MemoryData;

 		-- the memory being written to
		memory_data_write: out MemoryData := (others => '0');

 		-- the operation to perform on the memory
 		memory_operation: out MemoryOperation := MEMORY_OP_DISABLED;

		-- a flag indicating if a memory operation should be performed
 		memory_enable: out std_logic := '0';

		-- a flag indicating if a memory operation has completed
 		memory_ready: in std_logic;

		------------------------------------------
		-- REGISTER BUS
		------------------------------------------
		-- the processor register address bus
		register_address: out RegisterAddress := (others => '0');

		-- the processor register data bus
		register_data_read: in RegisterData;

		-- the processor register data bus
		register_data_write: out RegisterData := (others => '0');

		-- the processor register operation signal
		register_operation: out RegisterOperation := OP_REG_DISABLED;

		-- the processor register enable signal
		register_enable: out std_logic := '0';

		-- a flag indicating if a register operation has completed
		register_ready: in std_logic;

		------------------------------------------
		-- PROGRAM COUNTER
		------------------------------------------
		-- the program counter new value
		program_counter: out MemoryAddress;

		-- the program counter set flag
		program_counter_set: out std_logic := '0';

		------------------------------------------
		-- IO ports
		------------------------------------------
		-- io port: port0
		port0: in MemoryData;

		-- io port: port1
		port1: out MemoryData := (others => '0')
	);
end JumpInstructionExecutor;

architecture JumpInstructionExecutorImpl of JumpInstructionExecutor is

	type state_type is (
		execute,
		complete
	);
	signal state: state_type := execute;

begin
	process (clock) begin
		if clock'event and clock = '1' then
			if enable = '1' then

				case state is
					when execute =>
						program_counter <= arg0_address;
						program_counter_set <= '1';
						instruction_ready <= '1';

						state <= complete;
					when complete =>
						program_counter_set <= '0';
						state <= complete;
				end case;

			else
				instruction_ready <= '0';
				state <= execute;
			end if;
		end if;
	end process;

end JumpInstructionExecutorImpl;
