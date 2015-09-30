--
--  BananaCore - A processor written in VHDL
--
--  Created by Rogiel Sulzbach.
--  Copyright (c) 2014-2015 Rogiel Sulzbach. All rights reserved.
--

library BananaCore;

package Instruction is

	-- Represents a instruction by name
	type InstructionCode is (
		-- Halts the processor
		HALT,
		
		-- Jumps the processor into a fixed address
		JUMP
	);

	-- Represents a record with information about the decoded instruction and its arguments
	type DecodedInstruction is record
		-- The instruction code
		opcode: InstructionCode;
	end record;
end package;