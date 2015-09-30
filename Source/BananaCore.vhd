--
--  BananaCore - A processor written in VHDL
--
--  Created by Rogiel Sulzbach.
--  Copyright (c) 2014-2015 Rogiel Sulzbach. All rights reserved.
--

library BananaCore;
use BananaCore.Adder;
use BananaCore.InstructionDecoder;
use BananaCore.Instruction.DecodedInstruction;

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
	
	-- a temporary static instruction data
	signal instruction_data : bit_vector(7 downto 0) := "00000000";

begin

	instruction_decoder: InstructionDecoder
	generic map(
		DataWidth => DataWidth
	)
	port map(
		instruction_byte => instruction_data,
		instruction => current_instruction
	);

	my_adder: Adder
	generic map(
		N => DataWidth
	)
	port map(
		a => port0,
		b => port1,
		carry_in => '0',
					
		output => port2
	);

end BananaCoreImpl;