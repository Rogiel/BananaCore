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

-- The JumpIfCarryInstructionExecutor entity
entity JumpIfCarryInstructionExecutor is
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
		program_counter_set: out std_logic := '0'
	);
end JumpIfCarryInstructionExecutor;

architecture JumpIfCarryInstructionExecutorImpl of JumpIfCarryInstructionExecutor is

	type state_type is (
		fetch_control_register,
		store_control_register,

		execute,
		complete
	);
	signal state: state_type := fetch_control_register;

	signal arg0: RegisterData;

begin
	process (clock) begin
		if clock'event and clock = '1' then
			if enable = '1' then

				case state is
					when fetch_control_register =>
						instruction_ready <= '0';

						register_address <= SpecialRegister;
						register_operation <= OP_REG_GET;
						register_enable <= '1';
						state <= store_control_register;

					when store_control_register =>
						if register_ready = '1' then
							arg0 <= register_data_read;
							register_enable <= '0';
							state <= execute;
						else
							state <= store_control_register;
						end if;

					when execute =>
						if arg0(CarryBit) = '1' then
							program_counter <= arg0_address;
							program_counter_set <= '1';
						end if;

						state <= complete;

					when complete =>
						instruction_ready <= '1';
						state <= complete;
				end case;

			else
				instruction_ready <= '0';
				program_counter_set <= '0';
				state <= fetch_control_register;
			end if;
		end if;
	end process;

end JumpIfCarryInstructionExecutorImpl;
