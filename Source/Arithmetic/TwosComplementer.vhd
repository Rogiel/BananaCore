--
--  BananaCore - A processor written in VHDL
--
--  Created by Rogiel Sulzbach.
--  Copyright (c) 2014-2015 Rogiel Sulzbach. All rights reserved.
--

library ieee;
use ieee.numeric_bit.all;

library BananaCore;
use BananaCore.SingleBitAdder;

-- Applies the twos complement to a number
entity TwosComplementer is
	generic(
		-- the number of bits in the integer to be complemented
		N: integer
	);
	port(
		-- the first number to add with
		input: in unsigned(N-1 downto 0);

		-- the sum result
		output: out unsigned(N-1 downto 0)
	);

end TwosComplementer;

architecture TwosComplementerImpl of TwosComplementer is
	begin

		output <= not(input) + 1;
	
end TwosComplementerImpl;