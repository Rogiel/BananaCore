--
--  BananaCore - A processor written in VHDL
--
--  Created by Rogiel Sulzbach.
--  Copyright (c) 2014-2015 Rogiel Sulzbach. All rights reserved.
--


library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library BananaCore;

use BananaCore.Instruction.DecodedInstruction;
use BananaCore.InstructionDecoder;
use BananaCore.Instruction.all;
use BananaCore.Core.all;
use BananaCore.Memory.all;
use BananaCore.RegisterPackage.all;

use BananaCore.LoadInstructionExecutor;
use BananaCore.StoreInstructionExecutor;

use BananaCore.AddInstructionExecutor;
use BananaCore.SubtractInstructionExecutor;
use BananaCore.MultiplyInstructionExecutor;
use BananaCore.DivideInstructionExecutor;

use BananaCore.BitwiseAndInstructionExecutor;
use BananaCore.BitwiseOrInstructionExecutor;
use BananaCore.BitwiseNandInstructionExecutor;
use BananaCore.BitwiseNorInstructionExecutor;
use BananaCore.BitwiseXorInstructionExecutor;
use BananaCore.BitwiseNotInstructionExecutor;

use BananaCore.GreaterThanInstructionExecutor;
use BananaCore.GreaterOrEqualThanInstructionExecutor;
use BananaCore.LessThanInstructionExecutor;
use BananaCore.LessOrEqualThanInstructionExecutor;
use BananaCore.EqualInstructionExecutor;
use BananaCore.NotEqualInstructionExecutor;

use BananaCore.JumpInstructionExecutor;
use BananaCore.JumpIfCarryInstructionExecutor;

use BananaCore.HaltInstructionExecutor;
use BananaCore.ResetInstructionExecutor;

-- Decodes a instruction bit stream into a organized and easy to use instruction record
entity InstructionController is
	port(
		-- the processor main clock 
 		clock: in BananaCore.Core.Clock;
		
		------------------------------------------
		-- MEMORY BUS
		------------------------------------------
		
		-- the address to read/write memory from/to 
 		memory_address: inout MemoryAddress;
 		 
 		-- the memory being read/written to 
		memory_data: inout MemoryData;
 		 
 		-- the operation to perform on the memory 
 		memory_operation: inout MemoryOperation;
		
		-- a flag indicating if a memory operation has completed
 		memory_ready: inout std_logic;
		
		------------------------------------------
		-- REGISTER BUS
		------------------------------------------
		
		-- the processor memory address bus
		register_address: inout RegisterAddress;
		
		-- the processor memory data bus
		register_data: inout RegisterData;
		
		-- the processor memory operation signal
		register_operation: inout RegisterOperation;
		
		-- the processor memory operation signal
		register_enable: inout std_logic
	);
	
end InstructionController;

architecture InstructionControllerImpl of InstructionController is
	signal instruction_data: std_logic_vector(0 to 23);
	signal current_instruction: DecodedInstruction;
	
	signal program_counter: integer;

	type state_type is (
		read_memory0,
		wait_memory0,
		read_memory1,
		wait_memory1,
		read_memory2,
		wait_memory2,
		
		decode_instruction,
		-- wait_decode_instruction,
		
		execute,
		wait_execute
	);
	signal state: state_type := read_memory0;
	
	signal instruction_enabler: std_logic_vector(0 to 255);
	signal instruction_ready: std_logic;
	
begin
	-- IMPLEMENTATION NOTE: here, we could very easily (and handly) implement a pipeline.
	-- While the instruction is being executed we could already start loading the next memory addresses.
	-- Though we have to be sure that no other instruction is accessing the memory bus at the same time.

--	load_instruction_executor: LoadInstructionExecutor port map(
-- 		clock => clock,
--		
--		enable => instruction_enabler(0),
--		arg0 => current_instruction.reg0,
--		arg1 => current_instruction.reg1,
--		instruction_ready => instruction_ready,
--		
-- 		memory_address => memory_address,
--		memory_data => memory_data,
-- 		memory_operation => memory_operation,
-- 		memory_ready => memory_ready,
--		
--		register_address => register_address,
--		register_data => register_data,
--		register_operation => register_operation,
--		register_enable => register_enable
--	);
--	
	store_instruction_executor: StoreInstructionExecutor port map(
 		clock => clock,
		
		enable => instruction_enabler(1),
		arg0_address => current_instruction.reg0,
		arg1_address => current_instruction.reg1,
		arg2_address => current_instruction.address,
		instruction_ready => instruction_ready,
		
 		memory_address => memory_address,
		memory_data => memory_data,
 		memory_operation => memory_operation,
 		memory_ready => memory_ready,
		
		register_address => register_address,
		register_data => register_data,
		register_operation => register_operation,
		register_enable => register_enable
	);
	
	add_instruction_executor: AddInstructionExecutor port map(
 		clock => clock,
		
		enable => instruction_enabler(2),
		arg0_address => current_instruction.reg0,
		arg1_address => current_instruction.reg1,
		instruction_ready => instruction_ready,
		
 		memory_address => memory_address,
		memory_data => memory_data,
 		memory_operation => memory_operation,
 		memory_ready => memory_ready,
		
		register_address => register_address,
		register_data => register_data,
		register_operation => register_operation,
		register_enable => register_enable
	);
	
	process(clock) begin 
		if clock'event and clock = '1' then
			case state is
				when read_memory0 =>
					memory_address <= integer_to_memory_address(program_counter);
					memory_operation <= OP_READ;
					state <= wait_memory0;
				when wait_memory0 =>
					if memory_ready = '1' then
						instruction_data(0 to 7) <= memory_data;
						state <= read_memory1;
					else 
						state <= wait_memory0;
					end if;
					
				when read_memory1 =>
					memory_address <= integer_to_memory_address(program_counter + 1);
					memory_operation <= OP_READ;
					state <= wait_memory1;
				when wait_memory1 =>
					if memory_ready = '1' then
						instruction_data(8 to 15) <= memory_data;
						state <= read_memory2;
					else 
						state <= wait_memory1;
					end if;
					
				when read_memory2 =>
					memory_address <= integer_to_memory_address(program_counter + 2);
					memory_operation <= OP_READ;
					state <= wait_memory2;
				when wait_memory2 =>
					if memory_ready = '1' then
						instruction_data(16 to 23) <= memory_data;
						state <= decode_instruction;
					else 
						state <= wait_memory2;
					end if;
					
				when decode_instruction =>
					-- TODO
					state <= execute;

					case instruction_data(0 to 7) is 
						when "00000000" =>
							current_instruction.opcode <= LOAD;
							current_instruction.size <= 4;
							
							current_instruction.reg0 <= unsigned(instruction_data(8 to 11));
							current_instruction.reg1 <= unsigned(instruction_data(12 to 15));
							
							-- FIXME need to increase buffer
							
						when "00000001" =>
							current_instruction.opcode <= STORE;
							current_instruction.size <= 4;
							
							current_instruction.reg0 <= (unsigned(instruction_data(8 to 11)));
							current_instruction.reg1 <= (unsigned(instruction_data(12 to 15)));
							
						when "00010000" =>
							current_instruction.opcode <= ADD;
							current_instruction.size <= 2;
							
							current_instruction.reg0 <= (unsigned(instruction_data(8 to 11)));
							current_instruction.reg1 <= (unsigned(instruction_data(12 to 15)));
							
						when "00010001" =>
							current_instruction.opcode <= SUBTRACT;
							current_instruction.size <= 2;
							
							current_instruction.reg0 <= (unsigned(instruction_data(8 to 11)));
							current_instruction.reg1 <= (unsigned(instruction_data(12 to 15)));
							
						when "00010010" =>
							current_instruction.opcode <= MULTIPLY;
							current_instruction.size <= 2;
							
							current_instruction.reg0 <= (unsigned(instruction_data(8 to 11)));
							current_instruction.reg1 <= (unsigned(instruction_data(12 to 15)));
							
						when "00010011" =>
							current_instruction.opcode <= DIVIDE;
							current_instruction.size <= 2;
							
							current_instruction.reg0 <= (unsigned(instruction_data(8 to 11)));
							current_instruction.reg1 <= (unsigned(instruction_data(12 to 15)));
							
						when "01000000" =>
							current_instruction.opcode <= BITWISE_AND;
							current_instruction.size <= 2;
							
							current_instruction.reg0 <= (unsigned(instruction_data(8 to 11)));
							current_instruction.reg1 <= (unsigned(instruction_data(12 to 15)));
						when "01000001" =>
							current_instruction.opcode <= BITWISE_OR;
							current_instruction.size <= 2;
							
							current_instruction.reg0 <= (unsigned(instruction_data(8 to 11)));
							current_instruction.reg1 <= (unsigned(instruction_data(12 to 15)));
						when "01000010" =>
							current_instruction.opcode <= BITWISE_NAND;
							current_instruction.size <= 2;
							
							current_instruction.reg0 <= (unsigned(instruction_data(8 to 11)));
							current_instruction.reg1 <= (unsigned(instruction_data(12 to 15)));
						when "01000011" =>
							current_instruction.opcode <= BITWISE_NOR;
							current_instruction.size <= 2;
							
							current_instruction.reg0 <= (unsigned(instruction_data(8 to 11)));
							current_instruction.reg1 <= (unsigned(instruction_data(12 to 15)));
						when "01000100" =>
							current_instruction.opcode <= BITWISE_XOR;
							current_instruction.size <= 2;
							
							current_instruction.reg0 <= (unsigned(instruction_data(8 to 11)));
							current_instruction.reg1 <= (unsigned(instruction_data(12 to 15)));
						when "01000101" =>
							current_instruction.opcode <= BITWISE_NOT;
							current_instruction.size <= 2;
							
							current_instruction.reg0 <= (unsigned(instruction_data(8 to 11)));
							current_instruction.reg1 <= (unsigned(instruction_data(12 to 15)));
							
						when "00110000" =>
							current_instruction.opcode <= GREATER_THAN;
							current_instruction.size <= 2;
							
							current_instruction.reg0 <= (unsigned(instruction_data(8 to 11)));
							current_instruction.reg1 <= (unsigned(instruction_data(12 to 15)));
						when "00110001" =>
							current_instruction.opcode <= GREATER_OR_EQUAL_THAN;
							current_instruction.size <= 2;
							
							current_instruction.reg0 <= (unsigned(instruction_data(8 to 11)));
							current_instruction.reg1 <= (unsigned(instruction_data(12 to 15)));
						when "00110010" =>
							current_instruction.opcode <= LESS_THAN;
							current_instruction.size <= 2;
							
							current_instruction.reg0 <= (unsigned(instruction_data(8 to 11)));
							current_instruction.reg1 <= (unsigned(instruction_data(12 to 15)));
						when "00110011" =>
							current_instruction.opcode <= LESS_OR_EQUAL_THAN;
							current_instruction.size <= 2;
							
							current_instruction.reg0 <= (unsigned(instruction_data(8 to 11)));
							current_instruction.reg1 <= (unsigned(instruction_data(12 to 15)));
						when "00110100" =>
							current_instruction.opcode <= EQUAL;
							current_instruction.size <= 2;
							
							current_instruction.reg0 <= (unsigned(instruction_data(8 to 11)));
							current_instruction.reg1 <= (unsigned(instruction_data(12 to 15)));
						when "00110101" =>
							current_instruction.opcode <= NOT_EQUAL;
							current_instruction.size <= 2;
							
							current_instruction.reg0 <= (unsigned(instruction_data(8 to 11)));
							current_instruction.reg1 <= (unsigned(instruction_data(12 to 15)));
							
						when "00100000" =>
							current_instruction.opcode <= JUMP;
							current_instruction.size <= 3;
							
							current_instruction.address <= bits_to_memory_address(instruction_data(8 to 23));
							
						when "00100010" =>
							current_instruction.opcode <= JUMP_IF_CARRY;
							current_instruction.size <= 3;
							
						when others =>
							current_instruction.opcode <= HALT;
							current_instruction.size <= 1;
					end case;
				when execute =>
					program_counter <= program_counter + current_instruction.size;
					
					case current_instruction.opcode is
						when LOAD => instruction_enabler <= (0 => '1', others => '0');
						when STORE => instruction_enabler <= (1 => '1', others => '0');
						when ADD => instruction_enabler <= (2 => '1', others => '0');
						
						when others => 
							instruction_enabler <= (others => '0');
					end case;
					
					-- TODO
					state <= wait_execute;
				
				when wait_execute =>
					--	TODO
					if instruction_ready = '1' then
						-- disable all executors
						instruction_enabler <= (others => '0');
						
						-- start reading next instruction
						state <= read_memory0;
					else
						-- keep waiting...
						state <= wait_execute;
					end if;
					
			end case;
		end if; 
	end process;
end InstructionControllerImpl;
