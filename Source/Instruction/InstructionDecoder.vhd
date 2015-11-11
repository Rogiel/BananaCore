--
--  BananaCore - A processor written in VHDL
--
--  Created by Rogiel Sulzbach.
--  Copyright (c) 2014-2015 Rogiel Sulzbach. All rights reserved.
--

library BananaCore;

use BananaCore.Instruction.DecodedInstruction;
use BananaCore.Instruction.all;

-- Decodes a instruction bit stream into a organized and easy to use instruction record
entity InstructionDecoder is
	generic(
		-- the processor data width
		DataWidth: integer
	);
	port(
		-- the instruction input byte
		instruction_data: in  bit_vector(23 downto 0);
		
		-- the resulting decoded instruction
		-- 24 bits from JUMP instruction plus 16 bits from destination address
		instruction: out DecodedInstruction;
		instruction: out bit_vector(39 downto 0); 
	)
	
end InstructionDecoder;

architecture InstructionDecoderImpl of InstructionDecoder is
begin

	with instruction_byte select
   instruction.opcode <=
		-- Memory Control instructions
		LOAD			        when "00000000",
		STORE 			 	when "00000001",
		NOT_CARRY_BIT 			when "00000010",
		-- Arithmetic Instructions 
		ADD 				when "00010000",
		SUBTRACT 			when "00010001",
		MULTIPLY 			when "00010010",
		DIVIDE 				when "00010011",
		-- Logic Instructions
		BITWISE_AND 			when "01000000",
		BITWISE_OR 			when "01000001",
		BITWISE_NAND 			when "01000010",
		BITWISE_NOR 			when "01000011",
		BITWISE_XOR 			when "01000100",
		BITWISE_NOT 			when "01000101',
		-- Comparision Instructions
		GREATER_THAN 			when "00110000",
		GREATER_OR_EQUAL_THAN 		when "00110001",
		LESS_THAN 			when "00110010",
		LESS_OR_EQUAL_THAN 		when "00110011",
		EQUAL 				when "00110100",
		NOT_EQUAL 			when "00110101",
		-- Flow Control Instructions
		JUMP 				when "00100000",
		JUMP_IF_CARRY 			when "00100010",
		-- Processor Control Instructions
		HAL				when "11111110",
		RESET 				when "11111101",
		HALT 				when others;
	

end InstructionDecoderImpl;
