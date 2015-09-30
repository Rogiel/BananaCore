--
--  BananaCore - A processor written in VHDL
--
--  Created by Rogiel Sulzbach.
--  Copyright (c) 2014-2015 Rogiel Sulzbach. All rights reserved.
--


library ieee;
use ieee.numeric_bit.all;

library BananaCore;
use BananaCore.Numeric.Word;

use BananaCore.Adder;
use BananaCore.Subtracter;

-- Adds two numbers with a variable number of bits
entity ULA is
	generic(
		-- the number of bits in the integer
		N: integer
	);
	port(
		-- the first number to be operated on
		a: in  Word(N-1 downto 0);
		
		-- the second number to be operated on
		b: in  Word(N-1 downto 0);
		
		-- the carry in (if any)
		carry_in: in  bit;
		
		-- the operation result
		output: out Word(N-1 downto 0);
		
		-- the sum carry out (if any)
		carry_out: out bit;
		
		operation_selection: in bit
	);

end ULA;

architecture ULAImpl of ULA is

	signal add_result: Word(N-1 downto 0);
	signal add_carry_out: bit;
	
	signal subtract_result: Word(N-1 downto 0);
	signal subtract_carry_out: bit;
	
	begin
	
		ula_adder: Adder
		generic map(
			N => N
		)
		port map(
			a => a,
			b => b,
			carry_in => carry_in,
			output => add_result,
			carry_out => add_carry_out
		);
		
		
		ula_subtracter: Subtracter
		generic map(
			N => N
		)
		port map(
			a => a,
			b => b,
			output => subtract_result,
			carry_out => subtract_carry_out
		);
		
		with operation_selection select
		output <=
			add_result when '0',
			subtract_result when '1';
			
		with operation_selection select
		carry_out <=
			add_carry_out when '0',
			subtract_carry_out when '1';


end ULAImpl;