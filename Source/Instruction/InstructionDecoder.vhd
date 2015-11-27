--
--  BananaCore - A processor written in VHDL
--
--  Created by Rogiel Sulzbach.
--  Copyright (c) 2014-2015 Rogiel Sulzbach. All rights reserved.
--

library ieee;
use ieee.numeric_bit.all;
use ieee.std_logic_1164.all;

library BananaCore;

use BananaCore.Instruction.DecodedInstruction;
use BananaCore.Instruction.all;
use BananaCore.Core.all;

-- Decodes a instruction bit stream into a organized and easy to use instruction record
entity InstructionDecoder is
	port(
		-- the processor main clock 
 		clock: in BananaCore.Core.Clock; 
	
		-- the instruction input byte
		instruction_data: in  std_logic_vector(23 downto 0);
	
		-- the resulting decoded instruction
		instruction: out DecodedInstruction;
		
		enable: in bit;
		ready: out bit
	);
	
end InstructionDecoder;

architecture InstructionDecoderImpl of InstructionDecoder is
	signal decoded_instruction: DecodedInstruction;

begin
	process(clock) begin
		if clock'event and clock = '1' then
			if enable = '1' then
			case instruction_data(7 downto 0) is 
				when "00000000" =>
					decoded_instruction.opcode <= LOAD;
					decoded_instruction.size <= 3;
				when "00000001" =>
					decoded_instruction.opcode <= STORE;
					decoded_instruction.size <= 3;
					
				when "00010000" =>
					decoded_instruction.opcode <= ADD;
					decoded_instruction.size <= 2;
				when "00010001" =>
					decoded_instruction.opcode <= SUBTRACT;
					decoded_instruction.size <= 2;
				when "00010010" =>
					decoded_instruction.opcode <= MULTIPLY;
					decoded_instruction.size <= 2;
				when "00010011" =>
					decoded_instruction.opcode <= DIVIDE;
					decoded_instruction.size <= 2;
					
				when "01000000" =>
					decoded_instruction.opcode <= BITWISE_AND;
					decoded_instruction.size <= 2;
				when "01000001" =>
					decoded_instruction.opcode <= BITWISE_OR;
					decoded_instruction.size <= 2;
				when "01000010" =>
					decoded_instruction.opcode <= BITWISE_NAND;
					decoded_instruction.size <= 2;
				when "01000011" =>
					decoded_instruction.opcode <= BITWISE_NOR;
					decoded_instruction.size <= 2;
				when "01000100" =>
					decoded_instruction.opcode <= BITWISE_XOR;
					decoded_instruction.size <= 2;
				when "01000101" =>
					decoded_instruction.opcode <= BITWISE_NOT;
					decoded_instruction.size <= 2;
					
				when "00110000" =>
					decoded_instruction.opcode <= GREATER_THAN;
					decoded_instruction.size <= 2;
				when "00110001" =>
					decoded_instruction.opcode <= GREATER_OR_EQUAL_THAN;
					decoded_instruction.size <= 2;
				when "00110010" =>
					decoded_instruction.opcode <= LESS_THAN;
					decoded_instruction.size <= 2;
				when "00110011" =>
					decoded_instruction.opcode <= LESS_OR_EQUAL_THAN;
					decoded_instruction.size <= 2;
				when "00110100" =>
					decoded_instruction.opcode <= EQUAL;
					decoded_instruction.size <= 2;
				when "00110101" =>
					decoded_instruction.opcode <= NOT_EQUAL;
					decoded_instruction.size <= 2;
					
				when "00100000" =>
					decoded_instruction.opcode <= JUMP;
					decoded_instruction.size <= 3;
				when "00100010" =>
					decoded_instruction.opcode <= JUMP_IF_CARRY;
					decoded_instruction.size <= 3;
					
				when others =>
					decoded_instruction.opcode <= HALT;
					decoded_instruction.size <= 1;
			end case;
			instruction <= decoded_instruction;
			ready <='1';
			else 
				ready <= '0';
			end if;
		end if;

	end process;
end InstructionDecoderImpl;
