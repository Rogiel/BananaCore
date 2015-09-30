--
--  BananaCore - A processor written in VHDL
--
--  Created by Rogiel Sulzbach.
--  Copyright (c) 2014-2015 Rogiel Sulzbach. All rights reserved.
--

library BananaCore;

use BananaCore.SingleBitAdder;

-- Adds two numbers with a variable number of bits
entity Adder is
	generic(
		-- the number of bits in the integer
		N: integer
	);
	port(
		-- the first number to add with
		a: 			in  bit_vector(N-1 downto 0);
		
		-- the second number the add with
		b: 			in  bit_vector(N-1 downto 0);
		
		-- the carry in
		carry_in: 	in  bit;
		
		-- the sum result
		output: 		out bit_vector(N-1 downto 0);
		
		-- the sum carry out, if any.
		carry_out:	out bit
	);

end Adder;

architecture AdderImpl of Adder is

	signal internal_carry_bits : bit_vector(N-1 downto 0);

	begin
	
		adders: for i in N-1 downto 0 generate
			lower_bit: if i=0 generate
				U: SingleBitAdder port map(
					a => a(i),
					b => b(i),
					carry_in => carry_in,
					
					output => output(i),
					carry_out => internal_carry_bits(i)
				);
			
			end generate lower_bit;

			upper_bits: if i>0 generate
				U: SingleBitAdder port map(
					a => a(i),
					b => b(i),
					carry_in => internal_carry_bits(i-1),
					
					output => output(i),
					carry_out => internal_carry_bits(i)
				);
			end generate upper_bits;
		end generate adders;
	
	carry_out <= internal_carry_bits(N-1);

end AdderImpl;