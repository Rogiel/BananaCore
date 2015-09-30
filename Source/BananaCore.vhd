--
--  BananaCore - A processor written in VHDL
--
--  Created by Rogiel Sulzbach.
--  Copyright (c) 2014-2015 Rogiel Sulzbach. All rights reserved.
--

library BananaCore;

use BananaCore.InstructionDecoder;
use BananaCore.Instruction.DecodedInstruction;

use BananaCore.Numeric.Word;

use BananaCore.ULA;

-- Implements the processor entry point
entity BananaCore is
	generic(
		-- the data width to be used within the processor
		DataWidth: integer := 32
	);
	port(
		-- io port: port0
		port0: inout bit_vector(DataWidth-1 downto 0);
		
		-- io port: port1
		port1: inout bit_vector(DataWidth-1 downto 0);
		
		-- io port: port2
		port2: inout bit_vector(DataWidth-1 downto 0)
	);
	
end BananaCore;

architecture BananaCoreImpl of BananaCore is
	-- a signal holding the instruction that is currently being executed by the processor
	signal current_instruction : DecodedInstruction;
	
	signal output_transform : Word(DataWidth-1 downto 0);
	
begin

	instruction_decoder: InstructionDecoder
	generic map(
		DataWidth => DataWidth
	)
	port map(
		instruction_byte => "00000000",
		instruction => current_instruction
	);

	my_ula: ULA
	generic map(
		N => DataWidth
	)
	port map(
		a => Word(port0),
		b => Word(port1),
		carry_in => '0',
					
		output => output_transform,
		operation_selection => port1(0)
	);
	
	port2 <= bit_vector(output_transform);

end BananaCoreImpl;