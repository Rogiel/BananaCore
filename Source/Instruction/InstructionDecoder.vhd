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
		HALT when "00000000",
		JUMP when "00000001",
		-- HALT and JUMP must be changed?
		--LOAD when "00000000",
		-- STORE when "00000001",
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
		GREATEROREQUALTHAN "00110001",
		
		
		
		
		
		
		HALT when others;
	

end InstructionDecoderImpl;
