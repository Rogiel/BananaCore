--
--  BananaCore - A processor written in VHDL
--
--  Created by Rogiel Sulzbach.
--  Copyright (c) 2014-2015 Rogiel Sulzbach. All rights reserved.
--


library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.NUMERIC_STD.all;

library BananaCore;

use BananaCore.Instruction.DecodedInstruction;
use BananaCore.InstructionDecoder;
use BananaCore.Instruction.all;
use BananaCore.Core.all;
use BananaCore.Memory.all;
use BananaCore.RegisterPackage.all;

use BananaCore.LoadInstructionExecutor;
use BananaCore.StoreInstructionExecutor;

use BananaCore.WriteIoInstructionExecutor;
use BananaCore.ReadIoInstructionExecutor;

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
 		memory_address: out MemoryAddress;

 		-- the memory being read to
		memory_data_read: in MemoryData;

 		-- the memory being written to
		memory_data_write: out MemoryData;

 		-- the operation to perform on the memory
 		memory_operation: out MemoryOperation;

		-- a flag indicating if a memory operation should be performed
 		memory_enable: out std_logic;

		-- a flag indicating if a memory operation has completed
 		memory_ready: in std_logic;

		------------------------------------------
		-- REGISTER BUS
		------------------------------------------

		-- the processor memory address bus
		register_address: out RegisterAddress;

		-- the processor memory data bus
		register_data_read: in RegisterData;

		-- the processor memory data bus
		register_data_write: out RegisterData;

		-- the processor memory operation signal
		register_operation: out RegisterOperation;

		-- the processor memory operation signal
		register_enable: out std_logic;

		-- a flag indicating if a register operation has completed
		register_ready: in std_logic;

		------------------------------------------
		-- IO PORTS
		------------------------------------------
		-- io port: port0
		port0: in IOPortData;

		-- io port: port1
		port1: out IOPortData
	);

end InstructionController;

architecture InstructionControllerImpl of InstructionController is
	signal instruction_data: std_logic_vector(0 to 31);
	signal current_instruction: DecodedInstruction;

	signal program_counter: MemoryAddress := integer_to_memory_address(0);

	type state_type is (
		read_memory0,
		wait_memory0,
		read_memory1,
		wait_memory1,
		read_memory2,
		wait_memory2,
		read_memory3,
		wait_memory3,

		decode_instruction,
		-- wait_decode_instruction,

		execute,
		wait_execute
	);
	signal state: state_type := read_memory0;

	signal instruction_enabler: std_logic_vector(0 to 255);
	signal instruction_ready: std_logic_vector(0 to 255);

	signal memory_address_local: MemoryAddress;
	signal memory_data_write_local: MemoryData;
	signal memory_operation_local: MemoryOperation;
	signal memory_enable_local: std_logic;
	signal memory_ready_local: std_logic;
	signal register_address_local: RegisterAddress;
	signal register_data_local: RegisterData;
	signal register_operation_local: RegisterOperation;
	signal register_enable_local: std_logic;

	attribute keep: boolean;
	attribute keep of instruction_ready: signal is true;
	attribute keep of instruction_data: signal is true;
	attribute keep of current_instruction: signal is true;

	attribute keep of state: signal is true;

	-- [[[cog
	--content = [line.rstrip('\n') for line in open('instructions.txt')]
	--for line in content:
	--	cog.outl("signal memory_address_{0}: MemoryAddress;".format(line.lower()))
	--	cog.outl("signal memory_enable_{0}: std_logic;".format(line.lower()))
	--	cog.outl("signal memory_data_write_{0}: MemoryData;".format(line.lower()))
	--	cog.outl("signal memory_operation_{0}: MemoryOperation;".format(line.lower()))
	--	cog.outl("signal register_address_{0}: RegisterAddress;".format(line.lower()))
	--	cog.outl("signal register_data_write_{0}: RegisterData;".format(line.lower()))
	--	cog.outl("signal register_operation_{0}: RegisterOperation := OP_REG_DISABLED;".format(line.lower()))
	--	cog.outl("signal register_enable_{0}: std_logic;".format(line.lower()))
	-- 	cog.outl();
	--]]]
	signal memory_address_load: MemoryAddress;
	signal memory_enable_load: std_logic;
	signal memory_data_write_load: MemoryData;
	signal memory_operation_load: MemoryOperation;
	signal register_address_load: RegisterAddress;
	signal register_data_write_load: RegisterData;
	signal register_operation_load: RegisterOperation := OP_REG_DISABLED;
	signal register_enable_load: std_logic;
	signal port1_load: MemoryData;

	signal memory_address_store: MemoryAddress;
	signal memory_enable_store: std_logic;
	signal memory_data_write_store: MemoryData;
	signal memory_operation_store: MemoryOperation;
	signal register_address_store: RegisterAddress;
	signal register_data_write_store: RegisterData;
	signal register_operation_store: RegisterOperation := OP_REG_DISABLED;
	signal register_enable_store: std_logic;
	signal port1_store: MemoryData;

	signal memory_address_writeio: MemoryAddress;
	signal memory_enable_writeio: std_logic;
	signal memory_data_write_writeio: MemoryData;
	signal memory_operation_writeio: MemoryOperation;
	signal register_address_writeio: RegisterAddress;
	signal register_data_write_writeio: RegisterData;
	signal register_operation_writeio: RegisterOperation := OP_REG_DISABLED;
	signal register_enable_writeio: std_logic;
	signal port1_writeio: MemoryData;

	signal memory_address_readio: MemoryAddress;
	signal memory_enable_readio: std_logic;
	signal memory_data_write_readio: MemoryData;
	signal memory_operation_readio: MemoryOperation;
	signal register_address_readio: RegisterAddress;
	signal register_data_write_readio: RegisterData;
	signal register_operation_readio: RegisterOperation := OP_REG_DISABLED;
	signal register_enable_readio: std_logic;
	signal port1_readio: MemoryData;

	signal memory_address_add: MemoryAddress;
	signal memory_enable_add: std_logic;
	signal memory_data_write_add: MemoryData;
	signal memory_operation_add: MemoryOperation;
	signal register_address_add: RegisterAddress;
	signal register_data_write_add: RegisterData;
	signal register_operation_add: RegisterOperation := OP_REG_DISABLED;
	signal register_enable_add: std_logic;
	signal port1_add: MemoryData;

	signal memory_address_subtract: MemoryAddress;
	signal memory_enable_subtract: std_logic;
	signal memory_data_write_subtract: MemoryData;
	signal memory_operation_subtract: MemoryOperation;
	signal register_address_subtract: RegisterAddress;
	signal register_data_write_subtract: RegisterData;
	signal register_operation_subtract: RegisterOperation := OP_REG_DISABLED;
	signal register_enable_subtract: std_logic;
	signal port1_subtract: MemoryData;

	signal memory_address_multiply: MemoryAddress;
	signal memory_enable_multiply: std_logic;
	signal memory_data_write_multiply: MemoryData;
	signal memory_operation_multiply: MemoryOperation;
	signal register_address_multiply: RegisterAddress;
	signal register_data_write_multiply: RegisterData;
	signal register_operation_multiply: RegisterOperation := OP_REG_DISABLED;
	signal register_enable_multiply: std_logic;
	signal port1_multiply: MemoryData;

	signal memory_address_divide: MemoryAddress;
	signal memory_enable_divide: std_logic;
	signal memory_data_write_divide: MemoryData;
	signal memory_operation_divide: MemoryOperation;
	signal register_address_divide: RegisterAddress;
	signal register_data_write_divide: RegisterData;
	signal register_operation_divide: RegisterOperation := OP_REG_DISABLED;
	signal register_enable_divide: std_logic;
	signal port1_divide: MemoryData;

	signal memory_address_bitwiseand: MemoryAddress;
	signal memory_enable_bitwiseand: std_logic;
	signal memory_data_write_bitwiseand: MemoryData;
	signal memory_operation_bitwiseand: MemoryOperation;
	signal register_address_bitwiseand: RegisterAddress;
	signal register_data_write_bitwiseand: RegisterData;
	signal register_operation_bitwiseand: RegisterOperation := OP_REG_DISABLED;
	signal register_enable_bitwiseand: std_logic;
	signal port1_bitwiseand: MemoryData;

	signal memory_address_bitwiseor: MemoryAddress;
	signal memory_enable_bitwiseor: std_logic;
	signal memory_data_write_bitwiseor: MemoryData;
	signal memory_operation_bitwiseor: MemoryOperation;
	signal register_address_bitwiseor: RegisterAddress;
	signal register_data_write_bitwiseor: RegisterData;
	signal register_operation_bitwiseor: RegisterOperation := OP_REG_DISABLED;
	signal register_enable_bitwiseor: std_logic;
	signal port1_bitwiseor: MemoryData;

	signal memory_address_bitwisenand: MemoryAddress;
	signal memory_enable_bitwisenand: std_logic;
	signal memory_data_write_bitwisenand: MemoryData;
	signal memory_operation_bitwisenand: MemoryOperation;
	signal register_address_bitwisenand: RegisterAddress;
	signal register_data_write_bitwisenand: RegisterData;
	signal register_operation_bitwisenand: RegisterOperation := OP_REG_DISABLED;
	signal register_enable_bitwisenand: std_logic;
	signal port1_bitwisenand: MemoryData;

	signal memory_address_bitwisenor: MemoryAddress;
	signal memory_enable_bitwisenor: std_logic;
	signal memory_data_write_bitwisenor: MemoryData;
	signal memory_operation_bitwisenor: MemoryOperation;
	signal register_address_bitwisenor: RegisterAddress;
	signal register_data_write_bitwisenor: RegisterData;
	signal register_operation_bitwisenor: RegisterOperation := OP_REG_DISABLED;
	signal register_enable_bitwisenor: std_logic;
	signal port1_bitwisenor: MemoryData;

	signal memory_address_bitwisexor: MemoryAddress;
	signal memory_enable_bitwisexor: std_logic;
	signal memory_data_write_bitwisexor: MemoryData;
	signal memory_operation_bitwisexor: MemoryOperation;
	signal register_address_bitwisexor: RegisterAddress;
	signal register_data_write_bitwisexor: RegisterData;
	signal register_operation_bitwisexor: RegisterOperation := OP_REG_DISABLED;
	signal register_enable_bitwisexor: std_logic;
	signal port1_bitwisexor: MemoryData;

	signal memory_address_bitwisenot: MemoryAddress;
	signal memory_enable_bitwisenot: std_logic;
	signal memory_data_write_bitwisenot: MemoryData;
	signal memory_operation_bitwisenot: MemoryOperation;
	signal register_address_bitwisenot: RegisterAddress;
	signal register_data_write_bitwisenot: RegisterData;
	signal register_operation_bitwisenot: RegisterOperation := OP_REG_DISABLED;
	signal register_enable_bitwisenot: std_logic;
	signal port1_bitwisenot: MemoryData;

	signal memory_address_greaterthan: MemoryAddress;
	signal memory_enable_greaterthan: std_logic;
	signal memory_data_write_greaterthan: MemoryData;
	signal memory_operation_greaterthan: MemoryOperation;
	signal register_address_greaterthan: RegisterAddress;
	signal register_data_write_greaterthan: RegisterData;
	signal register_operation_greaterthan: RegisterOperation := OP_REG_DISABLED;
	signal register_enable_greaterthan: std_logic;
	signal port1_greaterthan: MemoryData;

	signal memory_address_greaterorequalthan: MemoryAddress;
	signal memory_enable_greaterorequalthan: std_logic;
	signal memory_data_write_greaterorequalthan: MemoryData;
	signal memory_operation_greaterorequalthan: MemoryOperation;
	signal register_address_greaterorequalthan: RegisterAddress;
	signal register_data_write_greaterorequalthan: RegisterData;
	signal register_operation_greaterorequalthan: RegisterOperation := OP_REG_DISABLED;
	signal register_enable_greaterorequalthan: std_logic;
	signal port1_greaterorequalthan: MemoryData;

	signal memory_address_lessthan: MemoryAddress;
	signal memory_enable_lessthan: std_logic;
	signal memory_data_write_lessthan: MemoryData;
	signal memory_operation_lessthan: MemoryOperation;
	signal register_address_lessthan: RegisterAddress;
	signal register_data_write_lessthan: RegisterData;
	signal register_operation_lessthan: RegisterOperation := OP_REG_DISABLED;
	signal register_enable_lessthan: std_logic;
	signal port1_lessthan: MemoryData;

	signal memory_address_lessorequalthan: MemoryAddress;
	signal memory_enable_lessorequalthan: std_logic;
	signal memory_data_write_lessorequalthan: MemoryData;
	signal memory_operation_lessorequalthan: MemoryOperation;
	signal register_address_lessorequalthan: RegisterAddress;
	signal register_data_write_lessorequalthan: RegisterData;
	signal register_operation_lessorequalthan: RegisterOperation := OP_REG_DISABLED;
	signal register_enable_lessorequalthan: std_logic;
	signal port1_lessorequalthan: MemoryData;

	signal memory_address_equal: MemoryAddress;
	signal memory_enable_equal: std_logic;
	signal memory_data_write_equal: MemoryData;
	signal memory_operation_equal: MemoryOperation;
	signal register_address_equal: RegisterAddress;
	signal register_data_write_equal: RegisterData;
	signal register_operation_equal: RegisterOperation := OP_REG_DISABLED;
	signal register_enable_equal: std_logic;
	signal port1_equal: MemoryData;

	signal memory_address_notequal: MemoryAddress;
	signal memory_enable_notequal: std_logic;
	signal memory_data_write_notequal: MemoryData;
	signal memory_operation_notequal: MemoryOperation;
	signal register_address_notequal: RegisterAddress;
	signal register_data_write_notequal: RegisterData;
	signal register_operation_notequal: RegisterOperation := OP_REG_DISABLED;
	signal register_enable_notequal: std_logic;
	signal port1_notequal: MemoryData;

	signal memory_address_jump: MemoryAddress;
	signal memory_enable_jump: std_logic;
	signal memory_data_write_jump: MemoryData;
	signal memory_operation_jump: MemoryOperation;
	signal register_address_jump: RegisterAddress;
	signal register_data_write_jump: RegisterData;
	signal register_operation_jump: RegisterOperation := OP_REG_DISABLED;
	signal register_enable_jump: std_logic;
	signal port1_jump: MemoryData;

	signal memory_address_jumpifcarry: MemoryAddress;
	signal memory_enable_jumpifcarry: std_logic;
	signal memory_data_write_jumpifcarry: MemoryData;
	signal memory_operation_jumpifcarry: MemoryOperation;
	signal register_address_jumpifcarry: RegisterAddress;
	signal register_data_write_jumpifcarry: RegisterData;
	signal register_operation_jumpifcarry: RegisterOperation := OP_REG_DISABLED;
	signal register_enable_jumpifcarry: std_logic;
	signal port1_jumpifcarry: MemoryData;

	signal memory_address_halt: MemoryAddress;
	signal memory_enable_halt: std_logic;
	signal memory_data_write_halt: MemoryData;
	signal memory_operation_halt: MemoryOperation;
	signal register_address_halt: RegisterAddress;
	signal register_data_write_halt: RegisterData;
	signal register_operation_halt: RegisterOperation := OP_REG_DISABLED;
	signal register_enable_halt: std_logic;
	signal port1_halt: MemoryData;

	signal memory_address_reset: MemoryAddress;
	signal memory_enable_reset: std_logic;
	signal memory_data_write_reset: MemoryData;
	signal memory_operation_reset: MemoryOperation;
	signal register_address_reset: RegisterAddress;
	signal register_data_write_reset: RegisterData;
	signal register_operation_reset: RegisterOperation := OP_REG_DISABLED;
	signal register_enable_reset: std_logic;
	signal port1_reset: MemoryData;

	-- [[[end]]]

	signal mux_disabled : std_logic := '1';

	signal jump_program_counter : MemoryAddress;
	signal jump_program_counter_set : std_logic;

	signal jump_if_carry_program_counter : MemoryAddress;
	signal jump_if_carry_program_counter_set : std_logic;

begin
	-- IMPLEMENTATION NOTE: here, we could very easily (and handly) implement a pipeline.
	-- While the instruction is being executed we could already start loading the next memory addresses.
	-- Though we have to be sure that no other instruction is accessing the memory bus at the same time.

	memory_address <=
	memory_address_local when mux_disabled = '1' else
	-- [[[cog
	--content = [line.rstrip('\n') for line in open('instructions.txt')]
	--counter=0;
	--for line in content[:-1]:
	-- 	cog.outl("\tmemory_address_{0} when instruction_enabler({1}) = '1' else".format(line.lower(), counter));
	--	counter = counter + 1
	--cog.outl("\tmemory_address_{0} when instruction_enabler({1}) = '1';".format(content[-1].lower(), counter));
	--]]]
	memory_address_load when instruction_enabler(0) = '1' else
	memory_address_store when instruction_enabler(1) = '1' else
	memory_address_writeio when instruction_enabler(2) = '1' else
	memory_address_readio when instruction_enabler(3) = '1' else
	memory_address_add when instruction_enabler(4) = '1' else
	memory_address_subtract when instruction_enabler(5) = '1' else
	memory_address_multiply when instruction_enabler(6) = '1' else
	memory_address_divide when instruction_enabler(7) = '1' else
	memory_address_bitwiseand when instruction_enabler(8) = '1' else
	memory_address_bitwiseor when instruction_enabler(9) = '1' else
	memory_address_bitwisenand when instruction_enabler(10) = '1' else
	memory_address_bitwisenor when instruction_enabler(11) = '1' else
	memory_address_bitwisexor when instruction_enabler(12) = '1' else
	memory_address_bitwisenot when instruction_enabler(13) = '1' else
	memory_address_greaterthan when instruction_enabler(14) = '1' else
	memory_address_greaterorequalthan when instruction_enabler(15) = '1' else
	memory_address_lessthan when instruction_enabler(16) = '1' else
	memory_address_lessorequalthan when instruction_enabler(17) = '1' else
	memory_address_equal when instruction_enabler(18) = '1' else
	memory_address_notequal when instruction_enabler(19) = '1' else
	memory_address_jump when instruction_enabler(20) = '1' else
	memory_address_jumpifcarry when instruction_enabler(21) = '1' else
	memory_address_halt when instruction_enabler(22) = '1' else
	memory_address_reset when instruction_enabler(23) = '1';
	-- [[[end]]]

	memory_data_write <=
	memory_data_write_local when mux_disabled = '1' else
	-- [[[cog
	--content = [line.rstrip('\n') for line in open('instructions.txt')]
	--counter=0;
	--for line in content[:-1]:
	-- 	cog.outl("\tmemory_data_write_{0} when instruction_enabler({1}) = '1' else".format(line.lower(), counter));
	--	counter = counter + 1
	--cog.outl("\tmemory_data_write_{0} when instruction_enabler({1}) = '1';".format(content[-1].lower(), counter));
	--]]]
	memory_data_write_load when instruction_enabler(0) = '1' else
	memory_data_write_store when instruction_enabler(1) = '1' else
	memory_data_write_writeio when instruction_enabler(2) = '1' else
	memory_data_write_readio when instruction_enabler(3) = '1' else
	memory_data_write_add when instruction_enabler(4) = '1' else
	memory_data_write_subtract when instruction_enabler(5) = '1' else
	memory_data_write_multiply when instruction_enabler(6) = '1' else
	memory_data_write_divide when instruction_enabler(7) = '1' else
	memory_data_write_bitwiseand when instruction_enabler(8) = '1' else
	memory_data_write_bitwiseor when instruction_enabler(9) = '1' else
	memory_data_write_bitwisenand when instruction_enabler(10) = '1' else
	memory_data_write_bitwisenor when instruction_enabler(11) = '1' else
	memory_data_write_bitwisexor when instruction_enabler(12) = '1' else
	memory_data_write_bitwisenot when instruction_enabler(13) = '1' else
	memory_data_write_greaterthan when instruction_enabler(14) = '1' else
	memory_data_write_greaterorequalthan when instruction_enabler(15) = '1' else
	memory_data_write_lessthan when instruction_enabler(16) = '1' else
	memory_data_write_lessorequalthan when instruction_enabler(17) = '1' else
	memory_data_write_equal when instruction_enabler(18) = '1' else
	memory_data_write_notequal when instruction_enabler(19) = '1' else
	memory_data_write_jump when instruction_enabler(20) = '1' else
	memory_data_write_jumpifcarry when instruction_enabler(21) = '1' else
	memory_data_write_halt when instruction_enabler(22) = '1' else
	memory_data_write_reset when instruction_enabler(23) = '1';
	-- [[[end]]]

	memory_operation <=
	memory_operation_local when mux_disabled = '1' else
	-- [[[cog
	--content = [line.rstrip('\n') for line in open('instructions.txt')]
	--counter=0;
	--for line in content[:-1]:
	-- 	cog.outl("\tmemory_operation_{0} when instruction_enabler({1}) = '1' else".format(line.lower(), counter));
	--	counter = counter + 1
	--cog.outl("\tmemory_operation_{0} when instruction_enabler({1}) = '1';".format(content[-1].lower(), counter));
	--]]]
	memory_operation_load when instruction_enabler(0) = '1' else
	memory_operation_store when instruction_enabler(1) = '1' else
	memory_operation_writeio when instruction_enabler(2) = '1' else
	memory_operation_readio when instruction_enabler(3) = '1' else
	memory_operation_add when instruction_enabler(4) = '1' else
	memory_operation_subtract when instruction_enabler(5) = '1' else
	memory_operation_multiply when instruction_enabler(6) = '1' else
	memory_operation_divide when instruction_enabler(7) = '1' else
	memory_operation_bitwiseand when instruction_enabler(8) = '1' else
	memory_operation_bitwiseor when instruction_enabler(9) = '1' else
	memory_operation_bitwisenand when instruction_enabler(10) = '1' else
	memory_operation_bitwisenor when instruction_enabler(11) = '1' else
	memory_operation_bitwisexor when instruction_enabler(12) = '1' else
	memory_operation_bitwisenot when instruction_enabler(13) = '1' else
	memory_operation_greaterthan when instruction_enabler(14) = '1' else
	memory_operation_greaterorequalthan when instruction_enabler(15) = '1' else
	memory_operation_lessthan when instruction_enabler(16) = '1' else
	memory_operation_lessorequalthan when instruction_enabler(17) = '1' else
	memory_operation_equal when instruction_enabler(18) = '1' else
	memory_operation_notequal when instruction_enabler(19) = '1' else
	memory_operation_jump when instruction_enabler(20) = '1' else
	memory_operation_jumpifcarry when instruction_enabler(21) = '1' else
	memory_operation_halt when instruction_enabler(22) = '1' else
	memory_operation_reset when instruction_enabler(23) = '1';
	-- [[[end]]]


	memory_enable <=
	memory_enable_local when mux_disabled = '1' else
	-- [[[cog
	--content = [line.rstrip('\n') for line in open('instructions.txt')]
	--counter=0;
	--for line in content[:-1]:
	-- 	cog.outl("\tmemory_enable_{0} when instruction_enabler({1}) = '1' else".format(line.lower(), counter));
	--	counter = counter + 1
	--cog.outl("\tmemory_enable_{0} when instruction_enabler({1}) = '1';".format(content[-1].lower(), counter));
	--]]]
	memory_enable_load when instruction_enabler(0) = '1' else
	memory_enable_store when instruction_enabler(1) = '1' else
	memory_enable_writeio when instruction_enabler(2) = '1' else
	memory_enable_readio when instruction_enabler(3) = '1' else
	memory_enable_add when instruction_enabler(4) = '1' else
	memory_enable_subtract when instruction_enabler(5) = '1' else
	memory_enable_multiply when instruction_enabler(6) = '1' else
	memory_enable_divide when instruction_enabler(7) = '1' else
	memory_enable_bitwiseand when instruction_enabler(8) = '1' else
	memory_enable_bitwiseor when instruction_enabler(9) = '1' else
	memory_enable_bitwisenand when instruction_enabler(10) = '1' else
	memory_enable_bitwisenor when instruction_enabler(11) = '1' else
	memory_enable_bitwisexor when instruction_enabler(12) = '1' else
	memory_enable_bitwisenot when instruction_enabler(13) = '1' else
	memory_enable_greaterthan when instruction_enabler(14) = '1' else
	memory_enable_greaterorequalthan when instruction_enabler(15) = '1' else
	memory_enable_lessthan when instruction_enabler(16) = '1' else
	memory_enable_lessorequalthan when instruction_enabler(17) = '1' else
	memory_enable_equal when instruction_enabler(18) = '1' else
	memory_enable_notequal when instruction_enabler(19) = '1' else
	memory_enable_jump when instruction_enabler(20) = '1' else
	memory_enable_jumpifcarry when instruction_enabler(21) = '1' else
	memory_enable_halt when instruction_enabler(22) = '1' else
	memory_enable_reset when instruction_enabler(23) = '1';
	-- [[[end]]]

	register_data_write <=
	register_data_local when mux_disabled = '1' else
	-- [[[cog
	--content = [line.rstrip('\n') for line in open('instructions.txt')]
	--counter=0;
	--for line in content[:-1]:
	-- 	cog.outl("\tregister_data_write_{0} when instruction_enabler({1}) = '1' else".format(line.lower(), counter));
	--	counter = counter + 1
	--cog.outl("\tregister_data_write_{0} when instruction_enabler({1}) = '1';".format(content[-1].lower(), counter));
	--]]]
	register_data_write_load when instruction_enabler(0) = '1' else
	register_data_write_store when instruction_enabler(1) = '1' else
	register_data_write_writeio when instruction_enabler(2) = '1' else
	register_data_write_readio when instruction_enabler(3) = '1' else
	register_data_write_add when instruction_enabler(4) = '1' else
	register_data_write_subtract when instruction_enabler(5) = '1' else
	register_data_write_multiply when instruction_enabler(6) = '1' else
	register_data_write_divide when instruction_enabler(7) = '1' else
	register_data_write_bitwiseand when instruction_enabler(8) = '1' else
	register_data_write_bitwiseor when instruction_enabler(9) = '1' else
	register_data_write_bitwisenand when instruction_enabler(10) = '1' else
	register_data_write_bitwisenor when instruction_enabler(11) = '1' else
	register_data_write_bitwisexor when instruction_enabler(12) = '1' else
	register_data_write_bitwisenot when instruction_enabler(13) = '1' else
	register_data_write_greaterthan when instruction_enabler(14) = '1' else
	register_data_write_greaterorequalthan when instruction_enabler(15) = '1' else
	register_data_write_lessthan when instruction_enabler(16) = '1' else
	register_data_write_lessorequalthan when instruction_enabler(17) = '1' else
	register_data_write_equal when instruction_enabler(18) = '1' else
	register_data_write_notequal when instruction_enabler(19) = '1' else
	register_data_write_jump when instruction_enabler(20) = '1' else
	register_data_write_jumpifcarry when instruction_enabler(21) = '1' else
	register_data_write_halt when instruction_enabler(22) = '1' else
	register_data_write_reset when instruction_enabler(23) = '1';
	-- [[[end]]]

	register_operation <=
	register_operation_local when mux_disabled = '1' else
	-- [[[cog
	--content = [line.rstrip('\n') for line in open('instructions.txt')]
	--counter=0;
	--for line in content[:-1]:
	-- 	cog.outl("\tregister_operation_{0} when instruction_enabler({1}) = '1' else".format(line.lower(), counter));
	--	counter = counter + 1
	--cog.outl("\tregister_operation_{0} when instruction_enabler({1}) = '1';".format(content[-1].lower(), counter));
	--]]]
	register_operation_load when instruction_enabler(0) = '1' else
	register_operation_store when instruction_enabler(1) = '1' else
	register_operation_writeio when instruction_enabler(2) = '1' else
	register_operation_readio when instruction_enabler(3) = '1' else
	register_operation_add when instruction_enabler(4) = '1' else
	register_operation_subtract when instruction_enabler(5) = '1' else
	register_operation_multiply when instruction_enabler(6) = '1' else
	register_operation_divide when instruction_enabler(7) = '1' else
	register_operation_bitwiseand when instruction_enabler(8) = '1' else
	register_operation_bitwiseor when instruction_enabler(9) = '1' else
	register_operation_bitwisenand when instruction_enabler(10) = '1' else
	register_operation_bitwisenor when instruction_enabler(11) = '1' else
	register_operation_bitwisexor when instruction_enabler(12) = '1' else
	register_operation_bitwisenot when instruction_enabler(13) = '1' else
	register_operation_greaterthan when instruction_enabler(14) = '1' else
	register_operation_greaterorequalthan when instruction_enabler(15) = '1' else
	register_operation_lessthan when instruction_enabler(16) = '1' else
	register_operation_lessorequalthan when instruction_enabler(17) = '1' else
	register_operation_equal when instruction_enabler(18) = '1' else
	register_operation_notequal when instruction_enabler(19) = '1' else
	register_operation_jump when instruction_enabler(20) = '1' else
	register_operation_jumpifcarry when instruction_enabler(21) = '1' else
	register_operation_halt when instruction_enabler(22) = '1' else
	register_operation_reset when instruction_enabler(23) = '1';
	-- [[[end]]]

	register_enable <=
	-- [[[cog
	--content = [line.rstrip('\n') for line in open('instructions.txt')]
	--counter=0;
	--for line in content[:-1]:
	-- 	cog.outl("\tregister_enable_{0} when instruction_enabler({1}) = '1' else".format(line.lower(), counter));
	--	counter = counter + 1
	--cog.outl("\tregister_enable_{0} when instruction_enabler({1}) = '1';".format(content[-1].lower(), counter));
	--]]]
	register_enable_load when instruction_enabler(0) = '1' else
	register_enable_store when instruction_enabler(1) = '1' else
	register_enable_writeio when instruction_enabler(2) = '1' else
	register_enable_readio when instruction_enabler(3) = '1' else
	register_enable_add when instruction_enabler(4) = '1' else
	register_enable_subtract when instruction_enabler(5) = '1' else
	register_enable_multiply when instruction_enabler(6) = '1' else
	register_enable_divide when instruction_enabler(7) = '1' else
	register_enable_bitwiseand when instruction_enabler(8) = '1' else
	register_enable_bitwiseor when instruction_enabler(9) = '1' else
	register_enable_bitwisenand when instruction_enabler(10) = '1' else
	register_enable_bitwisenor when instruction_enabler(11) = '1' else
	register_enable_bitwisexor when instruction_enabler(12) = '1' else
	register_enable_bitwisenot when instruction_enabler(13) = '1' else
	register_enable_greaterthan when instruction_enabler(14) = '1' else
	register_enable_greaterorequalthan when instruction_enabler(15) = '1' else
	register_enable_lessthan when instruction_enabler(16) = '1' else
	register_enable_lessorequalthan when instruction_enabler(17) = '1' else
	register_enable_equal when instruction_enabler(18) = '1' else
	register_enable_notequal when instruction_enabler(19) = '1' else
	register_enable_jump when instruction_enabler(20) = '1' else
	register_enable_jumpifcarry when instruction_enabler(21) = '1' else
	register_enable_halt when instruction_enabler(22) = '1' else
	register_enable_reset when instruction_enabler(23) = '1' else
	-- [[[end]]]
	'0';

	register_address <=
	register_address_local when mux_disabled = '1' else
	-- [[[cog
	--content = [line.rstrip('\n') for line in open('instructions.txt')]
	--counter=0;
	--for line in content[:-1]:
	-- 	cog.outl("\tregister_address_{0} when instruction_enabler({1}) = '1' else".format(line.lower(), counter));
	--	counter = counter + 1
	--cog.outl("\tregister_address_{0} when instruction_enabler({1}) = '1';".format(content[-1].lower(), counter));
	--]]]
	register_address_load when instruction_enabler(0) = '1' else
	register_address_store when instruction_enabler(1) = '1' else
	register_address_writeio when instruction_enabler(2) = '1' else
	register_address_readio when instruction_enabler(3) = '1' else
	register_address_add when instruction_enabler(4) = '1' else
	register_address_subtract when instruction_enabler(5) = '1' else
	register_address_multiply when instruction_enabler(6) = '1' else
	register_address_divide when instruction_enabler(7) = '1' else
	register_address_bitwiseand when instruction_enabler(8) = '1' else
	register_address_bitwiseor when instruction_enabler(9) = '1' else
	register_address_bitwisenand when instruction_enabler(10) = '1' else
	register_address_bitwisenor when instruction_enabler(11) = '1' else
	register_address_bitwisexor when instruction_enabler(12) = '1' else
	register_address_bitwisenot when instruction_enabler(13) = '1' else
	register_address_greaterthan when instruction_enabler(14) = '1' else
	register_address_greaterorequalthan when instruction_enabler(15) = '1' else
	register_address_lessthan when instruction_enabler(16) = '1' else
	register_address_lessorequalthan when instruction_enabler(17) = '1' else
	register_address_equal when instruction_enabler(18) = '1' else
	register_address_notequal when instruction_enabler(19) = '1' else
	register_address_jump when instruction_enabler(20) = '1' else
	register_address_jumpifcarry when instruction_enabler(21) = '1' else
	register_address_halt when instruction_enabler(22) = '1' else
	register_address_reset when instruction_enabler(23) = '1';
	-- [[[end]]]

	-- [[--[cog
	--content = [line.rstrip('\n') for line in open('instructions.txt')]
	--counter=0;
	--for line in content:
	--	template_vars = {
	--		'LowerName': line.lower(),
	--		'Name': line,
	--		'Index': counter
	--	}
	-- 	cog.outl("{LowerName}_instruction_executor: {Name}InstructionExecutor port map(".format(**template_vars))
	-- 	cog.outl("\tclock => clock,".format(**template_vars))
	-- 	cog.outl("\tenable => instruction_enabler({Index}),".format(**template_vars))
	-- 	cog.outl("\targ0_address => current_instruction.reg0,".format(**template_vars))
	-- 	cog.outl("\targ1_address => current_instruction.reg1,".format(**template_vars))
	-- 	cog.outl("\tinstruction_ready => instruction_ready({Index}),".format(**template_vars))
	-- 	cog.outl("\tmemory_address => memory_address_{LowerName},".format(**template_vars))
	-- 	cog.outl("\tmemory_data_read => memory_data_read,".format(**template_vars))
	-- 	cog.outl("\tmemory_data_write => memory_data_write_{LowerName},".format(**template_vars))
	-- 	cog.outl("\tmemory_operation => memory_operation_{LowerName},".format(**template_vars))
	-- 	cog.outl("\tmemory_enable => memory_enable_{LowerName},".format(**template_vars))
	-- 	cog.outl("\tmemory_ready => memory_ready,".format(**template_vars))
	-- 	cog.outl("\tregister_address => register_address_{LowerName},".format(**template_vars))
	-- 	cog.outl("\tregister_operation => register_operation_{LowerName},".format(**template_vars))
	-- 	cog.outl("\tregister_data_read => register_data_read,".format(**template_vars))
	-- 	cog.outl("\tregister_data_write => register_data_write_{LowerName},".format(**template_vars))
	-- 	cog.outl("\tregister_enable => register_enable_{LowerName},".format(**template_vars))
	-- 	cog.outl("\tport0 => port0,".format(**template_vars))
	-- 	cog.outl("\tport1 => port1_{LowerName}".format(**template_vars))
	--	cog.outl(");".format(**template_vars))
	--	cog.outl()
	--	counter = counter + 1
	--]]--]
	load_instruction_executor: LoadInstructionExecutor port map(
		clock => clock,
		enable => instruction_enabler(0),
		arg0_address => current_instruction.reg0,
		arg1_address => current_instruction.reg1,
		arg2_address => current_instruction.address,
		instruction_ready => instruction_ready(0),
		memory_address => memory_address_load,
		memory_data_read => memory_data_read,
		memory_data_write => memory_data_write_load,
		memory_operation => memory_operation_load,
		memory_enable => memory_enable_load,
		memory_ready => memory_ready,
		register_address => register_address_load,
		register_operation => register_operation_load,
		register_data_read => register_data_read,
		register_data_write => register_data_write_load,
		register_enable => register_enable_load,
		register_ready => register_ready
	);

	store_instruction_executor: StoreInstructionExecutor port map(
		clock => clock,
		enable => instruction_enabler(1),
		arg0_address => current_instruction.reg0,
		arg1_address => current_instruction.reg1,
		arg2_address => current_instruction.address,
		instruction_ready => instruction_ready(1),
		memory_address => memory_address_store,
		memory_data_read => memory_data_read,
		memory_data_write => memory_data_write_store,
		memory_operation => memory_operation_store,
		memory_enable => memory_enable_store,
		memory_ready => memory_ready,
		register_address => register_address_store,
		register_operation => register_operation_store,
		register_data_read => register_data_read,
		register_data_write => register_data_write_store,
		register_enable => register_enable_store,
		register_ready => register_ready
	);

	writeio_instruction_executor: WriteIoInstructionExecutor port map(
		clock => clock,
		enable => instruction_enabler(2),
		arg0_address => current_instruction.reg0,
		arg1_address => current_instruction.reg1,
		instruction_ready => instruction_ready(2),
		memory_address => memory_address_writeio,
		memory_data_read => memory_data_read,
		memory_data_write => memory_data_write_writeio,
		memory_operation => memory_operation_writeio,
		memory_enable => memory_enable_writeio,
		memory_ready => memory_ready,
		register_address => register_address_writeio,
		register_operation => register_operation_writeio,
		register_data_read => register_data_read,
		register_data_write => register_data_write_writeio,
		register_enable => register_enable_writeio,
		register_ready => register_ready,
		port1 => port1
	);

	readio_instruction_executor: ReadIoInstructionExecutor port map(
		clock => clock,
		enable => instruction_enabler(3),
		arg0_address => current_instruction.reg0,
		arg1_address => current_instruction.reg1,
		instruction_ready => instruction_ready(3),
		memory_address => memory_address_readio,
		memory_data_read => memory_data_read,
		memory_data_write => memory_data_write_readio,
		memory_operation => memory_operation_readio,
		memory_enable => memory_enable_readio,
		memory_ready => memory_ready,
		register_address => register_address_readio,
		register_operation => register_operation_readio,
		register_data_read => register_data_read,
		register_data_write => register_data_write_readio,
		register_enable => register_enable_readio,
		register_ready => register_ready,
		port0 => port0
	);

	add_instruction_executor: AddInstructionExecutor port map(
		clock => clock,
		enable => instruction_enabler(4),
		arg0_address => current_instruction.reg0,
		arg1_address => current_instruction.reg1,
		instruction_ready => instruction_ready(4),
		memory_address => memory_address_add,
		memory_data_read => memory_data_read,
		memory_data_write => memory_data_write_add,
		memory_operation => memory_operation_add,
		memory_enable => memory_enable_add,
		memory_ready => memory_ready,
		register_address => register_address_add,
		register_operation => register_operation_add,
		register_data_read => register_data_read,
		register_data_write => register_data_write_add,
		register_enable => register_enable_add,
		register_ready => register_ready
	);

	subtract_instruction_executor: SubtractInstructionExecutor port map(
		clock => clock,
		enable => instruction_enabler(5),
		arg0_address => current_instruction.reg0,
		arg1_address => current_instruction.reg1,
		instruction_ready => instruction_ready(5),
		memory_address => memory_address_subtract,
		memory_data_read => memory_data_read,
		memory_data_write => memory_data_write_subtract,
		memory_operation => memory_operation_subtract,
		memory_enable => memory_enable_subtract,
		memory_ready => memory_ready,
		register_address => register_address_subtract,
		register_operation => register_operation_subtract,
		register_data_read => register_data_read,
		register_data_write => register_data_write_subtract,
		register_enable => register_enable_subtract,
		register_ready => register_ready
	);

	multiply_instruction_executor: MultiplyInstructionExecutor port map(
		clock => clock,
		enable => instruction_enabler(6),
		arg0_address => current_instruction.reg0,
		arg1_address => current_instruction.reg1,
		instruction_ready => instruction_ready(6),
		memory_address => memory_address_multiply,
		memory_data_read => memory_data_read,
		memory_data_write => memory_data_write_multiply,
		memory_operation => memory_operation_multiply,
		memory_enable => memory_enable_multiply,
		memory_ready => memory_ready,
		register_address => register_address_multiply,
		register_operation => register_operation_multiply,
		register_data_read => register_data_read,
		register_data_write => register_data_write_multiply,
		register_enable => register_enable_multiply,
		register_ready => register_ready
	);

	divide_instruction_executor: DivideInstructionExecutor port map(
		clock => clock,
		enable => instruction_enabler(7),
		arg0_address => current_instruction.reg0,
		arg1_address => current_instruction.reg1,
		instruction_ready => instruction_ready(7),
		memory_address => memory_address_divide,
		memory_data_read => memory_data_read,
		memory_data_write => memory_data_write_divide,
		memory_operation => memory_operation_divide,
		memory_enable => memory_enable_divide,
		memory_ready => memory_ready,
		register_address => register_address_divide,
		register_operation => register_operation_divide,
		register_data_read => register_data_read,
		register_data_write => register_data_write_divide,
		register_enable => register_enable_divide,
		register_ready => register_ready
	);

	bitwiseand_instruction_executor: BitwiseAndInstructionExecutor port map(
		clock => clock,
		enable => instruction_enabler(8),
		arg0_address => current_instruction.reg0,
		arg1_address => current_instruction.reg1,
		instruction_ready => instruction_ready(8),
		memory_address => memory_address_bitwiseand,
		memory_data_read => memory_data_read,
		memory_data_write => memory_data_write_bitwiseand,
		memory_operation => memory_operation_bitwiseand,
		memory_enable => memory_enable_bitwiseand,
		memory_ready => memory_ready,
		register_address => register_address_bitwiseand,
		register_operation => register_operation_bitwiseand,
		register_data_read => register_data_read,
		register_data_write => register_data_write_bitwiseand,
		register_enable => register_enable_bitwiseand,
		register_ready => register_ready
	);

	bitwiseor_instruction_executor: BitwiseOrInstructionExecutor port map(
		clock => clock,
		enable => instruction_enabler(9),
		arg0_address => current_instruction.reg0,
		arg1_address => current_instruction.reg1,
		instruction_ready => instruction_ready(9),
		memory_address => memory_address_bitwiseor,
		memory_data_read => memory_data_read,
		memory_data_write => memory_data_write_bitwiseor,
		memory_operation => memory_operation_bitwiseor,
		memory_enable => memory_enable_bitwiseor,
		memory_ready => memory_ready,
		register_address => register_address_bitwiseor,
		register_operation => register_operation_bitwiseor,
		register_data_read => register_data_read,
		register_data_write => register_data_write_bitwiseor,
		register_enable => register_enable_bitwiseor,
		register_ready => register_ready
	);

	bitwisenand_instruction_executor: BitwiseNandInstructionExecutor port map(
		clock => clock,
		enable => instruction_enabler(10),
		arg0_address => current_instruction.reg0,
		arg1_address => current_instruction.reg1,
		instruction_ready => instruction_ready(10),
		memory_address => memory_address_bitwisenand,
		memory_data_read => memory_data_read,
		memory_data_write => memory_data_write_bitwisenand,
		memory_operation => memory_operation_bitwisenand,
		memory_enable => memory_enable_bitwisenand,
		memory_ready => memory_ready,
		register_address => register_address_bitwisenand,
		register_operation => register_operation_bitwisenand,
		register_data_read => register_data_read,
		register_data_write => register_data_write_bitwisenand,
		register_enable => register_enable_bitwisenand,
		register_ready => register_ready
	);

	bitwisenor_instruction_executor: BitwiseNorInstructionExecutor port map(
		clock => clock,
		enable => instruction_enabler(11),
		arg0_address => current_instruction.reg0,
		arg1_address => current_instruction.reg1,
		instruction_ready => instruction_ready(11),
		memory_address => memory_address_bitwisenor,
		memory_data_read => memory_data_read,
		memory_data_write => memory_data_write_bitwisenor,
		memory_operation => memory_operation_bitwisenor,
		memory_enable => memory_enable_bitwisenor,
		memory_ready => memory_ready,
		register_address => register_address_bitwisenor,
		register_operation => register_operation_bitwisenor,
		register_data_read => register_data_read,
		register_data_write => register_data_write_bitwisenor,
		register_enable => register_enable_bitwisenor,
		register_ready => register_ready
	);

	bitwisexor_instruction_executor: BitwiseXorInstructionExecutor port map(
		clock => clock,
		enable => instruction_enabler(12),
		arg0_address => current_instruction.reg0,
		arg1_address => current_instruction.reg1,
		instruction_ready => instruction_ready(12),
		memory_address => memory_address_bitwisexor,
		memory_data_read => memory_data_read,
		memory_data_write => memory_data_write_bitwisexor,
		memory_operation => memory_operation_bitwisexor,
		memory_enable => memory_enable_bitwisexor,
		memory_ready => memory_ready,
		register_address => register_address_bitwisexor,
		register_operation => register_operation_bitwisexor,
		register_data_read => register_data_read,
		register_data_write => register_data_write_bitwisexor,
		register_enable => register_enable_bitwisexor,
		register_ready => register_ready
	);

	bitwisenot_instruction_executor: BitwiseNotInstructionExecutor port map(
		clock => clock,
		enable => instruction_enabler(13),
		arg0_address => current_instruction.reg0,
		arg1_address => current_instruction.reg1,
		instruction_ready => instruction_ready(13),
		memory_address => memory_address_bitwisenot,
		memory_data_read => memory_data_read,
		memory_data_write => memory_data_write_bitwisenot,
		memory_operation => memory_operation_bitwisenot,
		memory_enable => memory_enable_bitwisenot,
		memory_ready => memory_ready,
		register_address => register_address_bitwisenot,
		register_operation => register_operation_bitwisenot,
		register_data_read => register_data_read,
		register_data_write => register_data_write_bitwisenot,
		register_enable => register_enable_bitwisenot,
		register_ready => register_ready
	);

	greaterthan_instruction_executor: GreaterThanInstructionExecutor port map(
		clock => clock,
		enable => instruction_enabler(14),
		arg0_address => current_instruction.reg0,
		arg1_address => current_instruction.reg1,
		instruction_ready => instruction_ready(14),
		memory_address => memory_address_greaterthan,
		memory_data_read => memory_data_read,
		memory_data_write => memory_data_write_greaterthan,
		memory_operation => memory_operation_greaterthan,
		memory_enable => memory_enable_greaterthan,
		memory_ready => memory_ready,
		register_address => register_address_greaterthan,
		register_operation => register_operation_greaterthan,
		register_data_read => register_data_read,
		register_data_write => register_data_write_greaterthan,
		register_enable => register_enable_greaterthan,
		register_ready => register_ready
	);

	greaterorequalthan_instruction_executor: GreaterOrEqualThanInstructionExecutor port map(
		clock => clock,
		enable => instruction_enabler(15),
		arg0_address => current_instruction.reg0,
		arg1_address => current_instruction.reg1,
		instruction_ready => instruction_ready(15),
		memory_address => memory_address_greaterorequalthan,
		memory_data_read => memory_data_read,
		memory_data_write => memory_data_write_greaterorequalthan,
		memory_operation => memory_operation_greaterorequalthan,
		memory_enable => memory_enable_greaterorequalthan,
		memory_ready => memory_ready,
		register_address => register_address_greaterorequalthan,
		register_operation => register_operation_greaterorequalthan,
		register_data_read => register_data_read,
		register_data_write => register_data_write_greaterorequalthan,
		register_enable => register_enable_greaterorequalthan,
		register_ready => register_ready
	);

	lessthan_instruction_executor: LessThanInstructionExecutor port map(
		clock => clock,
		enable => instruction_enabler(16),
		arg0_address => current_instruction.reg0,
		arg1_address => current_instruction.reg1,
		instruction_ready => instruction_ready(16),
		memory_address => memory_address_lessthan,
		memory_data_read => memory_data_read,
		memory_data_write => memory_data_write_lessthan,
		memory_operation => memory_operation_lessthan,
		memory_enable => memory_enable_lessthan,
		memory_ready => memory_ready,
		register_address => register_address_lessthan,
		register_operation => register_operation_lessthan,
		register_data_read => register_data_read,
		register_data_write => register_data_write_lessthan,
		register_enable => register_enable_lessthan,
		register_ready => register_ready
	);

	lessorequalthan_instruction_executor: LessOrEqualThanInstructionExecutor port map(
		clock => clock,
		enable => instruction_enabler(17),
		arg0_address => current_instruction.reg0,
		arg1_address => current_instruction.reg1,
		instruction_ready => instruction_ready(17),
		memory_address => memory_address_lessorequalthan,
		memory_data_read => memory_data_read,
		memory_data_write => memory_data_write_lessorequalthan,
		memory_operation => memory_operation_lessorequalthan,
		memory_enable => memory_enable_lessorequalthan,
		memory_ready => memory_ready,
		register_address => register_address_lessorequalthan,
		register_operation => register_operation_lessorequalthan,
		register_data_read => register_data_read,
		register_data_write => register_data_write_lessorequalthan,
		register_enable => register_enable_lessorequalthan,
		register_ready => register_ready
	);

	equal_instruction_executor: EqualInstructionExecutor port map(
		clock => clock,
		enable => instruction_enabler(18),
		arg0_address => current_instruction.reg0,
		arg1_address => current_instruction.reg1,
		instruction_ready => instruction_ready(18),
		memory_address => memory_address_equal,
		memory_data_read => memory_data_read,
		memory_data_write => memory_data_write_equal,
		memory_operation => memory_operation_equal,
		memory_enable => memory_enable_equal,
		memory_ready => memory_ready,
		register_address => register_address_equal,
		register_operation => register_operation_equal,
		register_data_read => register_data_read,
		register_data_write => register_data_write_equal,
		register_enable => register_enable_equal,
		register_ready => register_ready
	);

	notequal_instruction_executor: NotEqualInstructionExecutor port map(
		clock => clock,
		enable => instruction_enabler(19),
		arg0_address => current_instruction.reg0,
		arg1_address => current_instruction.reg1,
		instruction_ready => instruction_ready(19),
		memory_address => memory_address_notequal,
		memory_data_read => memory_data_read,
		memory_data_write => memory_data_write_notequal,
		memory_operation => memory_operation_notequal,
		memory_enable => memory_enable_notequal,
		memory_ready => memory_ready,
		register_address => register_address_notequal,
		register_operation => register_operation_notequal,
		register_data_read => register_data_read,
		register_data_write => register_data_write_notequal,
		register_enable => register_enable_notequal,
		register_ready => register_ready
	);

	jump_instruction_executor: JumpInstructionExecutor port map(
		clock => clock,
		enable => instruction_enabler(20),
		arg0_address => current_instruction.address,
		instruction_ready => instruction_ready(20),
		memory_address => memory_address_jump,
		memory_data_read => memory_data_read,
		memory_data_write => memory_data_write_jump,
		memory_operation => memory_operation_jump,
		memory_enable => memory_enable_jump,
		memory_ready => memory_ready,
		register_address => register_address_jump,
		register_operation => register_operation_jump,
		register_data_read => register_data_read,
		register_data_write => register_data_write_jump,
		register_enable => register_enable_jump,
		program_counter => jump_program_counter,
		program_counter_set => jump_program_counter_set,
		register_ready => register_ready
	);

	jumpifcarry_instruction_executor: JumpIfCarryInstructionExecutor port map(
		clock => clock,
		enable => instruction_enabler(21),
		arg0_address => current_instruction.address,
		instruction_ready => instruction_ready(21),
		memory_address => memory_address_jumpifcarry,
		memory_data_read => memory_data_read,
		memory_data_write => memory_data_write_jumpifcarry,
		memory_operation => memory_operation_jumpifcarry,
		memory_enable => memory_enable_jumpifcarry,
		memory_ready => memory_ready,
		register_address => register_address_jumpifcarry,
		register_operation => register_operation_jumpifcarry,
		register_data_read => register_data_read,
		register_data_write => register_data_write_jumpifcarry,
		register_enable => register_enable_jumpifcarry,
		register_ready => register_ready,

		program_counter => jump_if_carry_program_counter,
		program_counter_set => jump_if_carry_program_counter_set
	);

	halt_instruction_executor: HaltInstructionExecutor port map(
		clock => clock,
		enable => instruction_enabler(22),
		arg0_address => current_instruction.reg0,
		arg1_address => current_instruction.reg1,
		instruction_ready => instruction_ready(22),
		memory_address => memory_address_halt,
		memory_data_read => memory_data_read,
		memory_data_write => memory_data_write_halt,
		memory_operation => memory_operation_halt,
		memory_enable => memory_enable_halt,
		memory_ready => memory_ready,
		register_address => register_address_halt,
		register_operation => register_operation_halt,
		register_data_read => register_data_read,
		register_data_write => register_data_write_halt,
		register_enable => register_enable_halt,
		register_ready => register_ready
	);

	reset_instruction_executor: ResetInstructionExecutor port map(
		clock => clock,
		enable => instruction_enabler(23),
		arg0_address => current_instruction.reg0,
		arg1_address => current_instruction.reg1,
		instruction_ready => instruction_ready(23),
		memory_address => memory_address_reset,
		memory_data_read => memory_data_read,
		memory_data_write => memory_data_write_reset,
		memory_operation => memory_operation_reset,
		memory_enable => memory_enable_reset,
		memory_ready => memory_ready,
		register_address => register_address_reset,
		register_operation => register_operation_reset,
		register_data_read => register_data_read,
		register_data_write => register_data_write_reset,
		register_enable => register_enable_reset,
		register_ready => register_ready
	);

	-- [[[--end]]]

	process(clock) begin
		if clock'event and clock = '1' then
			case state is
				when read_memory0 =>
					mux_disabled <= '1';
					memory_address_local <= program_counter;
					memory_operation_local <= MEMORY_OP_READ;
					memory_enable_local <= '1';

					state <= wait_memory0;

				when wait_memory0 =>
					mux_disabled <= '1';
					if memory_ready = '1' then
						instruction_data(0 to 7) <= memory_data_read;
						memory_enable_local <= '0';
						state <= read_memory1;
					else
						state <= wait_memory0;
					end if;

				when read_memory1 =>
					mux_disabled <= '1';
					memory_address_local <= program_counter + 1;
					memory_operation_local <= MEMORY_OP_READ;
					memory_enable_local <= '1';

					state <= wait_memory1;

				when wait_memory1 =>
					mux_disabled <= '1';
					if memory_ready = '1' then
						instruction_data(8 to 15) <= memory_data_read;
						memory_enable_local <= '0';
						state <= read_memory2;
					else
						state <= wait_memory1;
					end if;

				when read_memory2 =>
					mux_disabled <= '1';
					memory_address_local <= program_counter + 2;
					memory_operation_local <= MEMORY_OP_READ;
					memory_enable_local <= '1';
					state <= wait_memory2;

				when wait_memory2 =>
					mux_disabled <= '1';
					if memory_ready = '1' then
						instruction_data(16 to 23) <= memory_data_read;
						memory_enable_local <= '0';
						state <= read_memory3;
					else
						state <= wait_memory2;
					end if;

				when read_memory3 =>
					mux_disabled <= '1';
					memory_address_local <= program_counter + 3;
					memory_operation_local <= MEMORY_OP_READ;
					memory_enable_local <= '1';
					state <= wait_memory3;

				when wait_memory3 =>
					mux_disabled <= '1';
					if memory_ready = '1' then
						instruction_data(24 to 31) <= memory_data_read;
						memory_enable_local <= '0';
						state <= decode_instruction;
					else
						state <= wait_memory3;
					end if;

				when decode_instruction =>
					mux_disabled <= '0';
					memory_enable_local <= '0';

					case instruction_data(0 to 7) is
						when "00000000" =>
							current_instruction.opcode <= LOAD;

							current_instruction.reg0 <= unsigned(instruction_data(8 to 11));
							current_instruction.reg1 <= unsigned(instruction_data(12 to 15));
							current_instruction.address <= unsigned(instruction_data(16 to 31));

							if unsigned(instruction_data(8 to 11)) = 0 then
								current_instruction.size <= 3;
							elsif unsigned(instruction_data(8 to 11)) = 1 then
								current_instruction.size <= 4;
							elsif unsigned(instruction_data(8 to 11)) = 2 then
								current_instruction.size <= 4;
							end if;

						when "00000001" =>
							current_instruction.opcode <= STORE;
							current_instruction.size <= 4;

							current_instruction.reg0 <= (unsigned(instruction_data(8 to 11)));
							current_instruction.reg1 <= (unsigned(instruction_data(12 to 15)));
							current_instruction.address <= unsigned(instruction_data(16 to 31));

						when "00000010" =>
							current_instruction.opcode <= WRITE_IO;
							current_instruction.size <= 2;

							current_instruction.reg0 <= (unsigned(instruction_data(8 to 11)));
							current_instruction.reg1 <= (unsigned(instruction_data(12 to 15)));

						when "00000011" =>
							current_instruction.opcode <= READ_IO;
							current_instruction.size <= 2;

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
							
							current_instruction.address <= bits_to_memory_address(instruction_data(8 to 23));

						when others =>
							current_instruction.opcode <= HALT;
							current_instruction.size <= 1;
					end case;

					state <= execute;
				when execute =>
					mux_disabled <= '0';
					program_counter <= program_counter + current_instruction.size;

					case current_instruction.opcode is

						-- [[[cog
						--import re
						--
						--content = [line.rstrip('\n') for line in open('instructions.txt')]
						--counter=0;
						--for line in content:
						--	cog.outl("when {0} => instruction_enabler <= ({1} => '1', others => '0');".format(re.sub('([a-z0-9])([A-Z])', r'\1_\2', re.sub('(.)([A-Z][a-z]+)', r'\1_\2', line)).upper(), counter))
						--	counter = counter + 1
						--]]]
						when LOAD => instruction_enabler <= (0 => '1', others => '0');
						when STORE => instruction_enabler <= (1 => '1', others => '0');
						when WRITE_IO => instruction_enabler <= (2 => '1', others => '0');
						when READ_IO => instruction_enabler <= (3 => '1', others => '0');
						when ADD => instruction_enabler <= (4 => '1', others => '0');
						when SUBTRACT => instruction_enabler <= (5 => '1', others => '0');
						when MULTIPLY => instruction_enabler <= (6 => '1', others => '0');
						when DIVIDE => instruction_enabler <= (7 => '1', others => '0');
						when BITWISE_AND => instruction_enabler <= (8 => '1', others => '0');
						when BITWISE_OR => instruction_enabler <= (9 => '1', others => '0');
						when BITWISE_NAND => instruction_enabler <= (10 => '1', others => '0');
						when BITWISE_NOR => instruction_enabler <= (11 => '1', others => '0');
						when BITWISE_XOR => instruction_enabler <= (12 => '1', others => '0');
						when BITWISE_NOT => instruction_enabler <= (13 => '1', others => '0');
						when GREATER_THAN => instruction_enabler <= (14 => '1', others => '0');
						when GREATER_OR_EQUAL_THAN => instruction_enabler <= (15 => '1', others => '0');
						when LESS_THAN => instruction_enabler <= (16 => '1', others => '0');
						when LESS_OR_EQUAL_THAN => instruction_enabler <= (17 => '1', others => '0');
						when EQUAL => instruction_enabler <= (18 => '1', others => '0');
						when NOT_EQUAL => instruction_enabler <= (19 => '1', others => '0');
						when JUMP => instruction_enabler <= (20 => '1', others => '0');
						when JUMP_IF_CARRY => instruction_enabler <= (21 => '1', others => '0');
						when HALT => instruction_enabler <= (22 => '1', others => '0');
						when RESET => instruction_enabler <= (23 => '1', others => '0');
						-- [[[end]]]

						when others =>
							instruction_enabler <= (others => '0');
					end case;
					state <= wait_execute;

				when wait_execute =>
--					program_counter <=
--						jump_program_counter when jump_program_counter_set = '1' else
--						jump_if_carry_program_counter when jump_if_carry_program_counter_set = '1' else
--						program_counter;

					if jump_program_counter_set = '1' then
						program_counter <= jump_program_counter;
					elsif  jump_if_carry_program_counter_set = '1' then
						program_counter <= jump_if_carry_program_counter;
					else
						program_counter <= program_counter;
					end if;

					case current_instruction.opcode is
						-- [[[cog
						--import re
						--
						--content = [line.rstrip('\n') for line in open('instructions.txt')]
						--counter=0;
						--for line in content:
						--	cog.outl("when {0} => ".format(re.sub('([a-z0-9])([A-Z])', r'\1_\2', re.sub('(.)([A-Z][a-z]+)', r'\1_\2', line)).upper(), counter))
						--	cog.outl("\tif instruction_ready({0}) = '1' then".format(counter))
						--	cog.outl("\t\tinstruction_enabler <= (others => '0');")
						--	cog.outl("\t\tmux_disabled <= '1';")
						--	cog.outl("\t\tstate <= read_memory0;")
						--	cog.outl("\telse")
						--	cog.outl("\t\tstate <= wait_execute;")
						--	cog.outl("\tend if;")
						--	counter = counter + 1
						--]]]
						when LOAD =>
							if instruction_ready(0) = '1' then
								instruction_enabler <= (others => '0');
								mux_disabled <= '1';
								state <= read_memory0;
							else
								state <= wait_execute;
							end if;
						when STORE =>
							if instruction_ready(1) = '1' then
								instruction_enabler <= (others => '0');
								mux_disabled <= '1';
								state <= read_memory0;
							else
								state <= wait_execute;
							end if;
						when WRITE_IO =>
							if instruction_ready(2) = '1' then
								instruction_enabler <= (others => '0');
								mux_disabled <= '1';
								state <= read_memory0;
							else
								state <= wait_execute;
							end if;
						when READ_IO =>
							if instruction_ready(3) = '1' then
								instruction_enabler <= (others => '0');
								mux_disabled <= '1';
								state <= read_memory0;
							else
								state <= wait_execute;
							end if;
						when ADD =>
							if instruction_ready(4) = '1' then
								instruction_enabler <= (others => '0');
								mux_disabled <= '1';
								state <= read_memory0;
							else
								state <= wait_execute;
							end if;
						when SUBTRACT =>
							if instruction_ready(5) = '1' then
								instruction_enabler <= (others => '0');
								mux_disabled <= '1';
								state <= read_memory0;
							else
								state <= wait_execute;
							end if;
						when MULTIPLY =>
							if instruction_ready(6) = '1' then
								instruction_enabler <= (others => '0');
								mux_disabled <= '1';
								state <= read_memory0;
							else
								state <= wait_execute;
							end if;
						when DIVIDE =>
							if instruction_ready(7) = '1' then
								instruction_enabler <= (others => '0');
								mux_disabled <= '1';
								state <= read_memory0;
							else
								state <= wait_execute;
							end if;
						when BITWISE_AND =>
							if instruction_ready(8) = '1' then
								instruction_enabler <= (others => '0');
								mux_disabled <= '1';
								state <= read_memory0;
							else
								state <= wait_execute;
							end if;
						when BITWISE_OR =>
							if instruction_ready(9) = '1' then
								instruction_enabler <= (others => '0');
								mux_disabled <= '1';
								state <= read_memory0;
							else
								state <= wait_execute;
							end if;
						when BITWISE_NAND =>
							if instruction_ready(10) = '1' then
								instruction_enabler <= (others => '0');
								mux_disabled <= '1';
								state <= read_memory0;
							else
								state <= wait_execute;
							end if;
						when BITWISE_NOR =>
							if instruction_ready(11) = '1' then
								instruction_enabler <= (others => '0');
								mux_disabled <= '1';
								state <= read_memory0;
							else
								state <= wait_execute;
							end if;
						when BITWISE_XOR =>
							if instruction_ready(12) = '1' then
								instruction_enabler <= (others => '0');
								mux_disabled <= '1';
								state <= read_memory0;
							else
								state <= wait_execute;
							end if;
						when BITWISE_NOT =>
							if instruction_ready(13) = '1' then
								instruction_enabler <= (others => '0');
								mux_disabled <= '1';
								state <= read_memory0;
							else
								state <= wait_execute;
							end if;
						when GREATER_THAN =>
							if instruction_ready(14) = '1' then
								instruction_enabler <= (others => '0');
								mux_disabled <= '1';
								state <= read_memory0;
							else
								state <= wait_execute;
							end if;
						when GREATER_OR_EQUAL_THAN =>
							if instruction_ready(15) = '1' then
								instruction_enabler <= (others => '0');
								mux_disabled <= '1';
								state <= read_memory0;
							else
								state <= wait_execute;
							end if;
						when LESS_THAN =>
							if instruction_ready(16) = '1' then
								instruction_enabler <= (others => '0');
								mux_disabled <= '1';
								state <= read_memory0;
							else
								state <= wait_execute;
							end if;
						when LESS_OR_EQUAL_THAN =>
							if instruction_ready(17) = '1' then
								instruction_enabler <= (others => '0');
								mux_disabled <= '1';
								state <= read_memory0;
							else
								state <= wait_execute;
							end if;
						when EQUAL =>
							if instruction_ready(18) = '1' then
								instruction_enabler <= (others => '0');
								mux_disabled <= '1';
								state <= read_memory0;
							else
								state <= wait_execute;
							end if;
						when NOT_EQUAL =>
							if instruction_ready(19) = '1' then
								instruction_enabler <= (others => '0');
								mux_disabled <= '1';
								state <= read_memory0;
							else
								state <= wait_execute;
							end if;
						when JUMP =>
							if instruction_ready(20) = '1' then
								instruction_enabler <= (others => '0');
								mux_disabled <= '1';
								state <= read_memory0;
							else
								state <= wait_execute;
							end if;
						when JUMP_IF_CARRY =>
							if instruction_ready(21) = '1' then
								instruction_enabler <= (others => '0');
								mux_disabled <= '1';
								state <= read_memory0;
							else
								state <= wait_execute;
							end if;
						when HALT =>
							if instruction_ready(22) = '1' then
								instruction_enabler <= (others => '0');
								mux_disabled <= '1';
								state <= read_memory0;
							else
								state <= wait_execute;
							end if;
						when RESET =>
							if instruction_ready(23) = '1' then
								instruction_enabler <= (others => '0');
								mux_disabled <= '1';
								state <= read_memory0;
							else
								state <= wait_execute;
							end if;
						-- [[[end]]]
					end case;

			end case;
		end if;
	end process;
end InstructionControllerImpl;
