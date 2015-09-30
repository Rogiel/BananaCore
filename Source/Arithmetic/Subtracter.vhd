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

-- Subtracts two numbers with a variable number of bits
entity Subtracter is
	generic(
		-- the number of bits in the integer
		N: integer
	);
	port(
		-- the number to subtract from
		a: in  Word(N-1 downto 0);
		
		-- the number the subtract to
		b: in  Word(N-1 downto 0);
		
		-- the sum result
		output: out Word(N-1 downto 0);
		
		-- the sum carry out, if any.
		carry_out:	out bit
	);

end Subtracter;

architecture SubtracterImpl of Subtracter is
	begin
	
		output <= a - b;
		-- TODO: implement carry out!!!
		
end SubtracterImpl;