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
		-- Memory Control instructions
		LOAD,			      
		STORE, 			 	
		NOT_CARRY_BIT, 			
		-- Arithmetic Instructions 
		ADD, 				
		SUBTRACT, 			
		MULTIPLY, 			
		DIVIDE, 				
		-- Logic Instructions
		BITWISE_AND, 			
		BITWISE_OR, 			
		BITWISE_NAND, 		
		BITWISE_NOR, 			
		BITWISE_XOR, 			
		BITWISE_NOT, 			
		-- Comparision Instructions
		GREATER_THAN, 			
		GREATER_OR_EQUAL_THAN, 		
		LESS_THAN, 			
		LESS_OR_EQUAL_THAN, 		
		EQUAL, 				
		NOT_EQUAL, 			
		-- Flow Control Instructions
		JUMP, 				
		JUMP_IF_CARRY, 			
		-- Processor Control Instructions
		RESET, 				
		HALT 				
		
			
	);

	-- Represents a record with information about the decoded instruction and its arguments
	type DecodedInstruction is record
		-- The instruction code
		opcode: InstructionCode;
		-- The instruction size
		size: integer;
	end record;
end package;