# Blocs Specifications
##Basic Blocs

###REG
####Description
This bloc will work as a flipflop with an enable in it's input and another in it's output (when the output enable is '1' the output should be high impedance)

####Interfaces
|Name       |In/Out|Type                           |
|-----------|------|-------------------------------|
|**In**     |In    |std_logic _vector (N downto 0)  |
|**eIn**    |In    |std_logic                      |
|**eOut**   |In    |std_logic                      |
|**RST**    |In    |std_logic                      |
|**CLK**    |In    |std_logic                      |
|**Out**    |Out   |std_logic _vector (N downto 0)  |

####Workings
The variables eIn, eOut and RST control how the register will work in each clock cycle (each time **CLK** changes from '0' to '1') as follows in decrescent order of priority.

1.	If **eOut** is '1', **Out** will assume the value 'Z' (high impedance) in all bits.
2. If **RST** is '1', **Out** will assume the value '0' in all bits.
3. If **eIn** is '1', **Out** will copy the value in In.
4. If **eIn** is '0', **Out** will not change it's value.

###ULA
####Description
This block will work as a 4 operations ULA with an enable in it's output (when the output enable is '1' the output should be high impedance)

####Interfaces
|Name       |In/Out|Type                           |
|-----------|------|-------------------------------|
|**InA**    |In    |std_logic _vector (N downto 0)  |
|**InB**    |In    |std_logic _vector (N downto 0)  |
|**CTRL**   |In    |std_logic _vector (2 downto 0)  |
|**eOut**   |In    |std_logic                      |
|**OV**     |Out   |std_logic                      |
|**Out**    |Out   |std_logic _vector (N downto 0)  |

####Workings
The variables eOut and CTRL control how the ULA will work instantaneously (independent of clock cycle) as follows in decrescent order of priority.

1.  If **eOut** is '1', **Out** and **OV** will assume the value 'Z' (high impedance) in all bits.
2. If **CTRL** is '00', **Out** will assume the value of the mathematical operation A+B
3. If **CTRL** is '01', **Out** will assume the value of the mathematical operation A-B
4. If **CTRL** is '10', **Out** will assume the value of the mathematical operation A*B
5. If **CTRL** is '11', **Out** will assume the value of the mathematical operation A/B

>If the value of the operation is bigger than N bits **Out** will truncate the valeu to the first N bits and the **OV** will be '1', otherwise **OV** will be '0'

##Composed Blocs
###ULAREG
####Description
This block will be an **ULA** with a **REG** conected in each of it's entrances

####Components
|Name           |Type       |
|---------------|-----------|
|**Register A** |**REG**    |
|**Register B** |**REG**    |
|**Main ULA**   |**ULA**    |

####External Interfaces
|Name       |In/Out|Type                           |
|-----------|------|-------------------------------|
|**InA**    |In    |std_logic _vector (N downto 0)  |
|**InB**    |In    |std_logic _vector (N downto 0)  |
|**CTRL**   |In    |std_logic _vector (2 downto 0)  |
|**eIn**    |In    |std_logic _Vector (2 downto 0)  |
|**eOut**   |In    |std_logic                      |
|**CLK**    |In    |std_logic                      |
|**RST**    |In    |std_logic                      |
|**OV**     |Out   |std_logic                      |
|**Out**    |Out   |std_logic _vector (N downto 0)  |

####Internal Interfaces
Interface 1 is connected to Interface 2

|Interface 1    |From           |Interface 2    |From   |
|---------------|---------------|---------------|---------------|
|**In**         |**Register A** |**InA**        |**External**   |
|**In**         |**Register B** |**InB**        |**External**   |
|**CTRL**       |**Main ULA**   |**CTRL**       |**External**   |
|**hIn**        |**Register A** |**InA**        |**External**   |
|**eIn**        |**Register A** |**eIn[0]**     |**External**   |
|**eIn**        |**Register B** |**eIn[1]**     |**External**   |
|**eOut**       |**Main ULA**   |**eOut**       |**External**   |
|**CLK**        |**Register A** |**CLK**        |**External**   |
|**CLK**        |**Register B** |**CLK**        |**External**   |
|**RST**        |**Register A** |**RST**        |**External**   |
|**RST**        |**Register B** |**RST**        |**External**   |
|**eOut**       |**Register A** |**GND**        |**External**   |
|**eOut**       |**Register B** |**GND**        |**External**   |
|**Out**        |**Main ULA**   |**Out**        |**External**   |
|**OV**         |**Main ULA**   |**OV**         |**External**   |
|**Out**        |**Register A** |**InA**        |**Main ULA**   |
|**Out**        |**Register B** |**InB**        |**Main ULA**   |

###Operative part

####Description
This block will be composed of 16 **REG** and a **ULAREG** to work as the operative part of the processor

####Components
|Name           |Type       |
|---------------|-----------|
|**Register A** |**REG**    |
|**Register B** |**REG**    |
|**Register C** |**REG**    |
|**Register D** |**REG**    |
|**Register E** |**REG**    |
|**Register F** |**REG**    |
|**Register G** |**REG**    |
|**Register H** |**REG**    |
|**Register I** |**REG**    |
|**Register J** |**REG**    |
|**Register K** |**REG**    |
|**Register L** |**REG**    |
|**Register M** |**REG**    |
|**Register N** |**REG**    |
|**Register ACC** |**REG**    |
|**Register SPC** |**REG**    |
|**Main ULA**   |**ULAREG** |

####External Interfaces
|Name       |In/Out|Type                           |
|-----------|------|-------------------------------|
|**BUS**    |In/Out|std_logic _vector (N downto 0)  |
|**eRegIn** |In    |std_logic _vector (15 downto 0)  |
|**eRegOut**|In    |std_logic _vector (15 downto 0)  |
|**eULAIn** |In    |std_logic                       |
|**eULAOut**|In    |std_logic                      |
|**CLK**    |In    |std_logic                      |
|**ULACTRL**|In    |std_logic _vector (1 downto 0) |
|**RST**    |In    |std_logic                      |
|**OV**     |Out   |std_logic                      |
|**Out**    |Out   |std_logic _vector (N downto 0)  |

####Internal Interfaces
Interface 1 is connected to Interface 2

|Interface 1    |From           |Interface 2    |From           |
|---------------|---------------|---------------|---------------|
|**In**         |**Register A** |**BUS**        |**External**   |
|**In**         |**Register B** |**BUS**        |**External**   |
|**In**         |**Register C** |**BUS**        |**External**   |
|**In**         |**Register D** |**BUS**        |**External**   |
|**In**         |**Register E** |**BUS**        |**External**   |
|**In**         |**Register F** |**BUS**        |**External**   |
|**In**         |**Register G** |**BUS**        |**External**   |
|**In**         |**Register H** |**BUS**        |**External**   |
|**In**         |**Register I** |**BUS**        |**External**   |
|**In**         |**Register J** |**BUS**        |**External**   |
|**In**         |**Register K** |**BUS**        |**External**   |
|**In**         |**Register L** |**BUS**        |**External**   |
|**In**         |**Register M** |**BUS**        |**External**   |
|**In**         |**Register N** |**BUS**        |**External**   |
|**In**         |**Register ACC** |**BUS**        |**External**   |
|**In**         |**Register SPC** |**BUS**        |**External**   |
|**Out**        |**Register A** |**BUS**        |**External**   |
|**Out**        |**Register B** |**BUS**        |**External**   |
|**Out**        |**Register C** |**BUS**        |**External**   |
|**Out**        |**Register D** |**BUS**        |**External**   |
|**Out**        |**Register E** |**BUS**        |**External**   |
|**Out**        |**Register F** |**BUS**        |**External**   |
|**Out**        |**Register G** |**BUS**        |**External**   |
|**Out**        |**Register H** |**BUS**        |**External**   |
|**Out**        |**Register I** |**BUS**        |**External**   |
|**Out**        |**Register J** |**BUS**        |**External**   |
|**Out**        |**Register K** |**BUS**        |**External**   |
|**Out**        |**Register L** |**BUS**        |**External**   |
|**Out**        |**Register M** |**BUS**        |**External**   |
|**Out**        |**Register N** |**BUS**        |**External**   |
|**Out**        |**Register ACC** |**BUS**        |**External**   |
|**Out**        |**Register SPC** |**BUS**        |**External**   |
|**CLK**        |**Register A** |**CLK**        |**External**   |
|**CLK**        |**Register B** |**CLK**        |**External**   |
|**CLK**        |**Register C** |**CLK**        |**External**   |
|**CLK**        |**Register D** |**CLK**        |**External**   |
|**CLK**        |**Register E** |**CLK**        |**External**   |
|**CLK**        |**Register F** |**CLK**        |**External**   |
|**CLK**        |**Register G** |**CLK**        |**External**   |
|**CLK**        |**Register H** |**CLK**        |**External**   |
|**CLK**        |**Register I** |**CLK**        |**External**   |
|**CLK**        |**Register J** |**CLK**        |**External**   |
|**CLK**        |**Register K** |**CLK**        |**External**   |
|**CLK**        |**Register L** |**CLK**        |**External**   |
|**CLK**        |**Register M** |**CLK**        |**External**   |
|**CLK**        |**Register N** |**CLK**        |**External**   |
|**CLK**        |**Register ACC** |**CLK**        |**External**   |
|**CLK**        |**Register SPC** |**CLK**        |**External**   |
|**eIn**        |**Register A** |**eIn[0]**        |**External**   |
|**eIn**        |**Register B** |**eIn[1]**        |**External**   |
|**eIn**        |**Register C** |**eIn[2]**        |**External**   |
|**eIn**        |**Register D** |**eIn[3]**        |**External**   |
|**eIn**        |**Register E** |**eIn[4]**        |**External**   |
|**eIn**        |**Register F** |**eIn[5]**        |**External**   |
|**eIn**        |**Register G** |**eIn[6]**        |**External**   |
|**eIn**        |**Register H** |**eIn[7]**        |**External**   |
|**eIn**        |**Register I** |**eIn[8]**        |**External**   |
|**eIn**        |**Register J** |**eIn[9]**        |**External**   |
|**eIn**        |**Register K** |**eIn[10]**        |**External**   |
|**eIn**        |**Register L** |**eIn[11]**        |**External**   |
|**eIn**        |**Register M** |**eIn[12]**        |**External**   |
|**eIn**        |**Register N** |**eIn[13]**        |**External**   |
|**eIn**        |**Register ACC** |**eIn[14]**        |**External**   |
|**eIn**        |**Register SPC** |**eIn[15]**        |**External**   |
|**eOut**        |**Register A** |**eOut[0]**        |**External**   |
|**eOut**        |**Register B** |**eOut[1]**        |**External**   |
|**eOut**        |**Register C** |**eOut[2]**        |**External**   |
|**eOut**        |**Register D** |**eOut[3]**        |**External**   |
|**eOut**        |**Register E** |**eOut[4]**        |**External**   |
|**eOut**        |**Register F** |**eOut[5]**        |**External**   |
|**eOut**        |**Register G** |**eOut[6]**        |**External**   |
|**eOut**        |**Register H** |**eOut[7]**        |**External**   |
|**eOut**        |**Register I** |**eOut[8]**        |**External**   |
|**eOut**        |**Register J** |**eOut[9]**        |**External**   |
|**eOut**        |**Register K** |**eOut[10]**        |**External**   |
|**eOut**        |**Register L** |**eOut[11]**        |**External**   |
|**eOut**        |**Register M** |**eOut[12]**        |**External**   |
|**eOut**        |**Register N** |**eOut[13]**        |**External**   |
|**eOut**        |**Register ACC** |**eOut[14]**        |**External**   |
|**eOut**        |**Register SPC** |**eOut[15]**        |**External**   |
|**RST**        |**Register A** |**RST**        |**External**   |
|**RST**        |**Register B** |**RST**        |**External**   |
|**RST**        |**Register C** |**RST**        |**External**   |
|**RST**        |**Register D** |**RST**        |**External**   |
|**RST**        |**Register E** |**RST**        |**External**   |
|**RST**        |**Register F** |**RST**        |**External**   |
|**RST**        |**Register G** |**RST**        |**External**   |
|**RST**        |**Register H** |**RST**        |**External**   |
|**RST**        |**Register I** |**RST**        |**External**   |
|**RST**        |**Register J** |**RST**        |**External**   |
|**RST**        |**Register K** |**RST**        |**External**   |
|**RST**        |**Register L** |**RST**        |**External**   |
|**RST**        |**Register M** |**RST**        |**External**   |
|**RST**        |**Register N** |**RST**        |**External**   |
|**RST**        |**Register ACC** |**RST**        |**External**   |
|**RST**        |**Register SPC** |**RST**        |**External**   |
|**InA**        |**Main ULA**   |**BUS**        |**External**   |
|**InB**        |**Main ULA** |**BUS**        |**External**   |
|**Out**        |**Main ULA** |**BUS**        |**External**   |
|**RST**        |**Main ULA**|**RST**        |**External**   |
|**CLK**        |**Main ULA**|**CLK**        |**External**   |
|**CTRL**        |**Main ULA**|**ULACTRL**        |**External**   |
|**eIn**        |**Main ULA** |**eULAIn**        |**External**   |
|**OV**        |**Main ULA** |**OV**        |**External**   |
|**eOut**        |**Main ULA** |**eULAOut**        |**External**   |
