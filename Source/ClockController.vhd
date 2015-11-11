--
--  BananaCore - A processor written in VHDL
--
--  Created by Rogiel Sulzbach.
--  Copyright (c) 2014-2015 Rogiel Sulzbach. All rights reserved.
--

library BananaCore;

-- A controller that generates (and manages) the core main clock
entity ClockController is
	port(
		-- the processor main clock
		clock: buffer BananaCore.Core.Clock;
	
		-- a enable that that allows to enabale and disable the clock
		enable: in bit
	);
end ClockController;

architecture ClockControllerImpl of ClockController is
begin
	
	-- FIXME use a real hardware clock source
	clock <= '1' after 0.5 ns when clock = '0' and enable = '1' else
				'0' after 0.5 ns when clock = '1' and enable = '1';

end ClockControllerImpl;