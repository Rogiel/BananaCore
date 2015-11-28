--
--  BananaCore - A processor written in VHDL
--
--  Created by Rogiel Sulzbach.
--  Copyright (c) 2014-2015 Rogiel Sulzbach. All rights reserved.
--

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_1164.std_logic;

library BananaCore;
use BananaCore.Core.all;
package RegisterPackage is
	-- Represents a memory operation
	type RegisterOperation is (
		-- Reads from a register
		OP_REG_GET,
		
		-- Writes to a register
		OP_REG_SET
	);
	
	-- Represents a memory address
	subtype RegisterAddress is unsigned(3 downto 0);
	
	-- Represents a data
	subtype RegisterData is std_logic_vector(DataWidth-1 downto 0);
	
	-- Declares the processor native data width
	constant AccumulatorRegister : RegisterAddress := "1110";
	
	function register_to_integer(address : RegisterData) return integer;
end package RegisterPackage;


package body RegisterPackage is
	function register_to_integer(address : RegisterData)
	return integer is begin
		return to_integer(unsigned(address));
	end register_to_integer;
end RegisterPackage;

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_1164.std_logic;

library BananaCore;
use BananaCore.Memory.all;
use BananaCore.Core.all;
use BananaCore.RegisterPackage.all;
use BananaCore.RegisterEntity;

-- A gateway that controls access to the register bus
entity RegisterController is
	port(
		-- the processor main clock
		clock: in BananaCore.Core.Clock;
	
		-- the address to read/write memory from/to
		address: in RegisterAddress;
		
		-- the memory being read/written to
		data: inout RegisterData;
		
		-- the operation to perform on the memory
		operation: in RegisterOperation;
		
		-- a flag indicating that the bus has been enabled
		enable: in std_logic
	);
	
end RegisterController;

architecture RegisterControllerImpl of RegisterController is

signal register_enable: std_logic_vector(0 to 15);

begin
	generated_registers: for I in 0 to 15 generate
      registerx : RegisterEntity port map(
			clock => clock, 
			data => data,
			enable => register_enable(I),
			operation => operation
		);
   end generate generated_registers;

	process (clock) begin
		if clock'event and clock = '1' then
			
			if enable = '1' then
				case to_integer(address) is
					when  0 => register_enable <= ( 0 => '1', others => '0');
					when  1 => register_enable <= ( 1 => '1', others => '0');
					when  2 => register_enable <= ( 2 => '1', others => '0');
					when  3 => register_enable <= ( 3 => '1', others => '0');
					when  4 => register_enable <= ( 4 => '1', others => '0');
					when  5 => register_enable <= ( 5 => '1', others => '0');
					when  6 => register_enable <= ( 6 => '1', others => '0');
					when  7 => register_enable <= ( 7 => '1', others => '0');
					when  8 => register_enable <= ( 8 => '1', others => '0');
					when  9 => register_enable <= ( 9 => '1', others => '0');
					when 10 => register_enable <= (10 => '1', others => '0');
					when 11 => register_enable <= (11 => '1', others => '0');
					when 12 => register_enable <= (12 => '1', others => '0');
					when 13 => register_enable <= (13 => '1', others => '0');
					when 14 => register_enable <= (14 => '1', others => '0');
					when 15 => register_enable <= (15 => '1', others => '0');
					
					-- if the register is not available, the output is put in high impedance
					-- and all registers are disabled
					when others => 
						register_enable <= (others => '0');
						data <= (others => 'Z');
				end case;
			else
				register_enable <= (others => '0');
				data <= (others => 'Z');
			end if;
			
		end if;
	end process;

end RegisterControllerImpl;