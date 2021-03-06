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

-- The ReadIoInstructionExecutor entity
entity ReadIoInstructionExecutor is
	port(
		-- the processor main clock
 		clock: in BananaCore.Core.Clock;

		-- enables the instruction
		enable: in std_logic;

		-- the first register to operate on (argument 0)
		arg0_address: in RegisterAddress;

		-- the first register to operate on (argument 1)
		arg1_address: in RegisterAddress;

		-- a bus indicating if the instruction is ready or not
		instruction_ready: out std_logic;

		------------------------------------------
		-- MEMORY BUS
		------------------------------------------
		-- the address to read/write memory from/to
 		memory_address: out MemoryAddress;

 		-- the memory being read to
		memory_data_read: in MemoryData;

 		-- the memory being written to
		memory_data_write: out MemoryData;

 		-- the operation to perform on the memory
 		memory_operation: out MemoryOperation;

		-- a flag indicating if a memory operation should be performed
 		memory_enable: out std_logic := '0';

		-- a flag indicating if a memory operation has completed
 		memory_ready: in std_logic;

		------------------------------------------
		-- REGISTER BUS
		------------------------------------------
		-- the processor register address bus
		register_address: out RegisterAddress;

		-- the processor register data bus
		register_data_read: in RegisterData;

		-- the processor register data bus
		register_data_write: out RegisterData;

		-- the processor register operation signal
		register_operation: out RegisterOperation;

		-- the processor register enable signal
		register_enable: out std_logic := '0';

		-- a flag indicating if a register operation has completed
		register_ready: in std_logic;

		------------------------------------------
		-- IO ports
		------------------------------------------
		-- io port: port0
		port0: in IOPortData
	);
end ReadIoInstructionExecutor;

architecture ReadIoInstructionExecutorImpl of ReadIoInstructionExecutor is

	type state_type is (
		execute,
		store_result,
		complete
	);
	signal state: state_type := execute;

	signal arg0: RegisterData;
	signal arg1: RegisterData;
	signal result: RegisterData;

begin
	process (clock) begin
		if clock'event and clock = '1' then
			if enable = '1' then

				case state is
					when execute =>
						result <= port0;
						state <= store_result;

					when store_result =>
						register_address <= arg0_address;
						register_operation <= OP_REG_SET;
						register_data_write <= result;
						register_enable <= '1';

						state <= complete;

					when complete =>
						if register_ready = '1' then
							instruction_ready <= '1';
						end if;
					
						state <= complete;
				end case;

			else
				register_enable <= '0';
				register_operation <= OP_REG_GET;
				
				instruction_ready <= '0';
				state <= execute;
			end if;
		end if;
	end process;

end ReadIoInstructionExecutorImpl;
