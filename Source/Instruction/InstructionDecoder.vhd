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
		instruction_byte: in  bit_vector(7 downto 0);
		
		-- the resulting decoded instruction
		instruction: out DecodedInstruction
	);
	
end InstructionDecoder;

architecture InstructionDecoderImpl of InstructionDecoder is
begin

	with instruction_byte select
   instruction.opcode <=
		-- Memory Control instructions
		LOAD when "00000000",
		STORE when "00000001",
		NOTCARRYBIT when "00000010",
		-- Arithmetic Instructions 
		ADD when "00010000",
		SUBTRACT when "00010001",
		MULTIPLY when "00010010",
		DIVIDE when "00010011",
		-- Logic Instructions
		BITWISEAND when "01000000",
		BITWISEOR when "01000001",
		BITWISENAND when "01000010",
		BITWISENOR when "01000011",
		BITWISEXOR when "01000100",
		BITWISENOT when "01000101',
		-- Comparision Instructions
		GREATERTHAN when "00110000",
		GREATEROREQUALTHAN when "00110001",
		LESSTHAN when "00110010",
		LESSOREQUALTHAN when "00110011",
		EQUAL when "00110100",
		NOTEQUAL when  "0011 0101",
		-- Flow Control Instructions
		JUMP when "00100000",
		JUMPIFCARRY when "00100010",
		-- Processor Control Instructions
		HALT when "11111110",
		RESET when "11111101",
		HALT when others;
	

end InstructionDecoderImpl;
