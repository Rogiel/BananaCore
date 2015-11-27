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
entity InstructionController is
	generic(
		-- the processor data width
		DataWidth: integer
	);
	port(
		-- the processor main clock 
 		clock: in BananaCore.Core.Clock; 
		
		-- the address to read/write memory from/to 
 		address: out MemoryAddress; 
 		 
 		-- the memory being read/written to 
 		memory_data: inout MemoryData; 
 		 
 		-- the operation to perform on the memory 
 		operation: out MemoryOperation 

		
		-- Register controller 
		-- http://www.cs.umd.edu/class/sum2003/cmsc311/Notes/Overall/steps.html
	);
	
end InstructionController;

architecture InstructionControllerImpl of InstructionController is
signal instruction_data:bit_vector(23 downto 0);
signal current_instruction:DecodedInstruction;

begin
	
	instruction_decoder: InstructionDecoder
	generic map(
		DataWidth => DataWidth
	)
	port map(
		clock => clock,
		instruction_data => instruction_data,
		instruction => current_instruction
	);

	process(clock) begin 
		if clock'event and clock = '1' then

			
		end if; 
	end process;
end InstructionControllerImpl;
