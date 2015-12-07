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

-- The StoreInstructionExecutor entity
entity StoreInstructionExecutor is
	port(
		-- the processor main clock
 		clock: in BananaCore.Core.Clock;

		-- enables the instruction
		enable: in std_logic;

		-- the first register to operate on (argument 0)
		arg0_address: in RegisterAddress;

		-- the first register to operate on (argument 1)
		arg1_address: in RegisterAddress;

		-- the address to operate on (argument 2)
		arg2_address: in MemoryAddress;

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
		-- IO ports
		------------------------------------------
		-- io port: port0
		port0: in MemoryData;

		-- io port: port1
		port1: out MemoryData := (others => '0')
	);
end StoreInstructionExecutor;

architecture StoreInstructionExecutorImpl of StoreInstructionExecutor is

	type state_type is (
		fetch_arg1,
		store_arg1,

		store_result0,
		wait_result0,

		store_result1,
		wait_result1,

		complete
	);
	signal state: state_type := fetch_arg1;

	signal arg0: RegisterData;
	signal arg1: RegisterData;
	signal result: RegisterData;

begin
	process (clock) begin
		if clock'event and clock = '1' then
			if enable = '1' then

				case state is
					when fetch_arg1 =>
						register_address <= arg1_address;
						register_operation <= OP_REG_GET;
						register_enable <= '1';
						state <= store_arg1;

					when store_arg1 =>
						arg1 <= register_data_read;
						state <= store_result0;

						register_enable <= '0';

					when store_result0 =>
						memory_address <= arg2_address;
						memory_operation <= MEMORY_OP_WRITE;
						memory_data_write <= result(7 downto 0);
						memory_enable <= '1';

						state <= wait_result0;

					when wait_result0 =>
						if memory_ready = '1' then
							state <= wait_result0;
							memory_enable <= '0';
						else
							state <= store_result0;
						end if;

					when store_result1 =>
						memory_address <= arg2_address;
						memory_operation <= MEMORY_OP_WRITE;
						memory_data_write <= result(7 downto 0);
						memory_enable <= '1';

						state <= wait_result1;

					when wait_result1 =>
						if memory_ready = '1' then
							state <= complete;
							memory_enable <= '0';
						else
							state <= store_result0;
						end if;

					when complete =>
						instruction_ready <= '1';
						state <= complete;
				end case;

			else
				instruction_ready <= '0';
				state <= fetch_arg1;
			end if;
		end if;
	end process;

end StoreInstructionExecutorImpl;
