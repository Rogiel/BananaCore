library ieee;  
use ieee.std_logic_1164.all;  
 
entity Reg is  
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
	portIn: in	std_logic_vector(N-1 downto 0);

	-- data in enable
	eIn: in std_logic;
	
	-- data out
   portOut: out std_logic_vector(N-1 downto 0);
	
	-- data out enable
	eOut: in std_logic
	);  
end Reg;  

architecture Archi of Reg is  
	begin  
		process (CLK) 
			begin  
				if (CLK'event and CLK='1') then 
					if (eOut='0') then
						for I in N-1 to 0 loop
							portOut(I) <= 'Z';
						end loop;
					else 
						if (RST='1') then  
							for I in N-1 to 0 loop
								portOut(I) <= '0';
							end loop;
						else  
							portOut <= portIn;  
						end if;  
					end if; 
				end if;	
		end process;  
end Archi; 
