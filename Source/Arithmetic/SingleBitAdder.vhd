--
--  BananaCore - A processor written in VHDL
--
--  Created by Rogiel Sulzbach.
--  Copyright (c) 2014-2015 Rogiel Sulzbach. All rights reserved.
--

library BananaCore;

-- Implements a single bit adder
entity SingleBitAdder is
	port(
		-- the first bit to add with
		a: 			in  bit;
		
		-- the second bit to add with
		b: 			in  bit;
		
		-- the adder carry in
		carry_in: 	in  bit;
		
		-- the adder resulting bit
		output: 		out bit;
		
		-- the adder carry out bit
		carry_out:	out bit
	);

end SingleBitAdder;

architecture SingleBitAdderImpl of SingleBitAdder is
begin

	output <= a xor b xor carry_in;
	carry_out <= (a and b) or (carry_in and (a xor b));

end SingleBitAdderImpl;