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

-- The MultiplyInstructionExecutor entity
entity MultiplyInstructionExecutor is
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
		register_enable: out std_logic;

		------------------------------------------
		-- IO ports
		------------------------------------------
		-- io port: port0
		port0: in MemoryData;

		-- io port: port1
		port1: out MemoryData
	);
end MultiplyInstructionExecutor;

architecture MultiplyInstructionExecutorImpl of MultiplyInstructionExecutor is

	type state_type is (
		fetch_arg0,
		store_arg0,

		fetch_arg1,
		store_arg1,

		execute,
		store_result,
		complete
	);
	signal state: state_type := fetch_arg0;

	signal arg0: RegisterData;
	signal arg1: RegisterData;
	signal result: RegisterData;

begin
	process (clock) begin
		if clock'event and clock = '1' then
			if enable = '1' then

				case state is
					when fetch_arg0 =>
						instruction_ready <= '0';

						register_address <= arg0_address;
						register_operation <= OP_REG_GET;
						register_enable <= '1';
						state <= store_arg0;

					when store_arg0 =>
						arg0 <= register_data_read;
						state <= fetch_arg1;

					when fetch_arg1 =>
						register_address <= arg1_address;
						register_operation <= OP_REG_GET;
						register_enable <= '1';
						state <= store_arg1;

					when store_arg1 =>
						arg1 <= register_data_read;
						state <= execute;

						register_enable <= '0';

					when execute =>
						-- TODO implement instruction here
						state <= store_result;

					when store_result =>
						register_address <= AccumulatorRegister;
						register_operation <= OP_REG_SET;
						register_data_write <= result;
						register_enable <= '1';

						instruction_ready <= '1';
						state <= complete;

					when complete =>
						state <= complete;
				end case;

			else
				instruction_ready <= '0';
				state <= fetch_arg0;
			end if;
		end if;
	end process;

end MultiplyInstructionExecutorImpl;