--
--  BananaCore - A processor written in VHDL
--
--  Created by Rogiel Sulzbach.
--  Copyright (c) 2014-2015 Rogiel Sulzbach. All rights reserved.
--

library ieee;
use ieee.numeric_bit.all;

library BananaCore;

package Numeric is

	subtype Word is unsigned;
	subtype UnsignedNumber is unsigned;
	subtype SignedNumber is signed;
	
end package;