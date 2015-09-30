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

-- Adds two numbers with a variable number of bits
entity Adder is
	generic(
		-- the number of bits in the integer
		N: integer
	);
	port(
		-- the first number to add with
		a: 			in  Word(N-1 downto 0);
		
		-- the second number the add with
		b: 			in  Word(N-1 downto 0);
		
		-- the carry in
		carry_in: 	in  bit;
		
		-- the sum result
		output: 		out Word(N-1 downto 0);
		
		-- the sum carry out, if any.
		carry_out:	out bit
	);

end Adder;

architecture AdderImpl of Adder is
	begin
	
		output <= a + b;
		-- TODO: implement carry out and carry in!!!

end AdderImpl;