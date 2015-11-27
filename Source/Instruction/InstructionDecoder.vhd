--
--  BananaCore - A processor written in VHDL
--
--  Created by Rogiel Sulzbach.
--  Copyright (c) 2014-2015 Rogiel Sulzbach. All rights reserved.
--

library BananaCore;

use BananaCore.Instruction.DecodedInstruction;
use BananaCore.Instruction.all;
use BananaCore.Core.all;

-- Decodes a instruction bit stream into a organized and easy to use instruction record
entity InstructionDecoder is
	generic(
		-- the processor data width
		DataWidth: integer
	);
	port(
		-- the processor main clock 
 		clock: in BananaCore.Core.Clock; 
		
		-- the instruction input byte
		instruction_data: in  bit_vector(23 downto 0);
	
		-- the resulting decoded instruction
		-- 24 bits from JUMP instruction plus 16 bits from destination address
		instruction: out DecodedInstruction 
	);
	
end InstructionDecoder;

architecture InstructionDecoderImpl of InstructionDecoder is
signal instruction_opcode: bit_vector(7 downto 0);

begin
	process(clock) begin 
		if clock'event and clock = '1' then

			instruction_opcode <= instruction_data(7 downto 0);
			case instruction_opcode is 
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0; --TaMaNhO em baites =D
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
				when "00000000" =>
					instruction.opcode <= LOAD;
					instruction.size <= 0;
			end case;
			
			
			
			
			
			
			

			
		end if; 
	end process;
end InstructionDecoderImpl;
