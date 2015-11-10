library ieee;  
use ieee.std_logic_1164.all;  

library BananaCore; 
use BananaCore.Numeric.Word; 

 
entity reg is  
	generic( 
		-- the number of bits in the integer 
		N: integer  
	); 

  port(
	-- clock of the system
	CLK:	in std_logic;
	
	-- reset of the data
	RST:	in std_logic;
	
	-- data in
	portIn: in	Word(N-1 downto 0);  
	
	-- data out
   portOut: out	Word(N-1 downto 0)
	);  
end reg;  

architecture archi of reg is  
	begin  
		process (CLK) 
			begin  
				if (CLK'event and CLK='1') then 
					if (RST='1') then  
						for I in N-1 to 0 loop
							portOut(I) <= '0';
						end loop;
					else  
						portOut <= portIn;  
				   end if;  
				end if;  
		end process;  
end archi; 
