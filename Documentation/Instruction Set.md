# Instruction Set

## Memory Control instructions
### LOAD
The load instruction is used to copy data from a arbitrary memory location into a internal register.

|Address (bit)| Description|Usage example|Example description
|-------------|---------------|-----------|-----------
|0-8|Opcode|0000 0000|(constant)
|9-12|Source address configuration
|13-16|Destination register|0000|Stores the fetched data into register 0
|17-32|Source address|(16-bit address)|The address to read the register data from
> Source Address configuration:

>0000 Loads the data from a memory address

>0001 Loads the data from another internal register

>0010 Loads a constant 

### STORE
The store instruction is used to copy data from a register into a arbitraty address in memory


|Address (bit)| Description|Usage example|Example description
|-------------|---------------|-----------|-----------
|0-8|Opcode|0000 0001|(constant)
|9-12|Destination address configuration|0000|Stores the data into a memory address
|13-16|Source register|0000|Gets the data from register 0
|17-32|Destination address|(16-bit address)|To the given address

> Source Address configuration:

>0000 Stores data ina a memory address

>0001 Stores data in another internal register


### NOT CARRY BIT
Unset the carry bit of the CONTROL register

|Address (bit)| Description|Usage example|Example description
|-------------|---------------|-----------|-----------
|0-8|Opcode|0000 0010|(constant)

## Arithmetic Instructions
### ADD
Adds two numbers and stores the resulting content into the accumulator register and the carry bit is set at the CONTROL register.

|Address (bit)| Description|Usage example|Example description
|-------------|---------------|-----------|-----------
|0-8|Opcode|0001 0000|(constant)
|9-12|The first register to add|0000|Adds register 0
|13-16|The second register to add|0001|with register 1

### SUBTRACT
Subtracts two numbers and stores the resulting content into the accumulator register and the carry bit is set at the CONTROL register.

|Address (bit)| Description|Usage example|Example description
|-------------|---------------|-----------|-----------
|0-8|Opcode|0001 0001|(constant)
|9-12|The first register to subtract from|0000|Subtracts from register 0
|13-16|The second register to subtract by|0001|the value of register 1

### MULTIPLY
Multiplies two numbers and stores the resulting content into the accumulator register and the carry bit is set at the CONTROL register.

|Address (bit)| Description|Usage example|Example description
|-------------|---------------|-----------|-----------
|0-8|Opcode|0001 0010|(constant)
|9-12|The first register to multiply with|0000|Multiplies register 0
|13-16|The second register to multiply by|0001|by register 1

### DIVIDE
Divides two numbers and stores the resulting content into the accumulator register and the carry bit is set at the CONTROL register.

|Address (bit)| Description|Usage example|Example description
|-------------|---------------|-----------|-----------
|0-8|Opcode|0001 0011|(constant)
|9-12|The first register to divide from|0000|Divides register 0
|13-16|The second register to divide by|0001|by register 1

## Logic Instructions
### BITWISE AND 
Do a Bitwise AND operation between the bits of the registers, stores the resulting content into the accumulator and the carry bit is set at the CONTROL register.

|Address (bit)| Description|Usage example|Example description
|-------------|---------------|-----------|-----------
|0-8|Opcode|0100 0000|(constant)
|9-12|The first register |0000|Compares register 0
|13-16|The second register |0001|With register 1

### BITWISE OR 
Do a Bitwise OR operation between the bits of the registers, stores the resulting content into the accumulator and the carry bit is set at the CONTROL register.

|Address (bit)| Description|Usage example|Example description
|-------------|---------------|-----------|-----------
|0-8|Opcode|0100 0001|(constant)
|9-12|The first register |0000|Compares register 0
|13-16|The second register |0001|With register 1

### BITWISE NAND 
Do a Bitwise NAND operation between the bits of the registers, stores the resulting content into the accumulator and the carry bit is set at the CONTROL register.

|Address (bit)| Description|Usage example|Example description
|-------------|---------------|-----------|-----------
|0-8|Opcode|0100 0010|(constant)
|9-12|The first register |0000|Compares register 0
|13-16|The second register |0001|With register 1

### BITWISE NOR 
Do a Bitwise NOR operation between the bits of the registers, stores the resulting content into the accumulator and the carry bit is set at the CONTROL register.

|Address (bit)| Description|Usage example|Example description
|-------------|---------------|-----------|-----------
|0-8|Opcode|0100 0011|(constant)
|9-12|The first register |0000|Compares register 0
|13-16|The second register |0001|With register 1

### BITWISE XOR 
Do a Bitwise XOR operation between the bits of the registers, stores the resulting content into the accumulator and the carry bit is set at the CONTROL register.

|Address (bit)| Description|Usage example|Example description
|-------------|---------------|-----------|-----------
|0-8|Opcode|0100 0100|(constant)
|9-12|The first register |0000|Compares register 0
|13-16|The second register |0001|With register 1

### BITWISE NOT 
Do a Bitwise NOT operation between the bits of the registers, stores the resulting content into the accumulator and the carry bit is set at the CONTROL register.

|Address (bit)| Description|Usage example|Example description
|-------------|---------------|-----------|-----------
|0-8|Opcode|0100 0101|(constant)
|9-12|The first register |0000|Compares register 0
|13-16|The second register |0001|With register 1


## Comparision Instructions
### GREATER THAN 
Compares two numbers stored in registers an if the first is bigger than the second sets the carry bit at the CONTROL register

|Address (bit)| Description|Usage example|Example description
|-------------|---------------|-----------|-----------
|0-8|Opcode|0011 0000|(constant)
|9-12|The first register |0000|Divides register 0
|13-16|The second register |0001|by register 1

### GREATER OR EQUAL THAN 
Compares two numbers stored in registers an if the first is bigger or equal to the second sets the carry bit at the CONTROL register

|Address (bit)| Description|Usage example|Example description
|-------------|---------------|-----------|-----------
|0-8|Opcode|0011 0001|(constant)
|9-12|The first register |0000|Divides register 0
|13-16|The second register |0001|by register 1

### LESS THAN
Compares two numbers stored in registers an if the first is smaller than the second sets the carry bit at the CONTROL register

|Address (bit)| Description|Usage example|Example description
|-------------|---------------|-----------|-----------
|0-8|Opcode|0011 0010|(constant)
|9-12|The first register |0000|Divides register 0
|13-16|The second register |0001|by register 1

### LESS OR EQUAL THAN
Compares two numbers stored in registers an if the first is smaller or equal to the second sets the carry bit at the CONTROL register

|Address (bit)| Description|Usage example|Example description
|-------------|---------------|-----------|-----------
|0-8|Opcode|0011 0011|(constant)
|9-12|The first register |0000|Divides register 0
|13-16|The second register |0001|by register 1

### EQUAL
Compares two numbers stored in registers an if they are equal sets the carry bit at the CONTROL register

|Address (bit)| Description|Usage example|Example description
|-------------|---------------|-----------|-----------
|0-8|Opcode|0011 0100|(constant)
|9-12|The first register |0000|Divides register 0
|13-16|The second register |0001|by register 1

### NOT EQUAL
Compares two numbers stored in registers an if they are different sets the carry bit at the CONTROL register

|Address (bit)| Description|Usage example|Example description
|-------------|---------------|-----------|-----------
|0-8|Opcode|0011 0101|(constant)
|9-12|The first register |0000|Divides register 0
|13-16|The second register |0001|by register 1


## Flow Control Instructions
### JUMP
Jumps the program counter register into a arbitrary address

|Address (bit)| Description|Usage example|Example description
|-------------|---------------|-----------|-----------
|0-8|Opcode|0010 0000|(constant)
|9-24|Destination address|(16-bit address)|Jumps the program into the given address

### JUMP\_CONDITIONAL
Jumps the program counter register into a arbitrary address only if the register selected is not zero
## this function is not necessary since there is a redundant with the jump if carry
|Address (bit)| Description|Usage example|Example description
|-------------|---------------|-----------|-----------
|0-8|Opcode|0010 0001|(constant)
|9-12|(ignored)|-----|-----
|13-16|The comparision register|0001|Checks if the register 1 is not equal to zero
|17-32|Destination address|(16-bit address)|if not equal, jumps the the given address

### JUMP\_IF\_CARRY
Jumps the program counter register into a arbitrary address only if the carry bit is set in the CONTROL register. If the carry bit is not set, the flow contiues normally.

|Address (bit)| Description|Usage example|Example description
|-------------|---------------|-----------|-----------
|0-8|Opcode|0010 0010|(constant)
|9-24|Destination address|(16-bit address)|Jumps the program into the given address

## Processor Control Instructions

### HALT
Halts the processor and prevents any instruction from further execution

|Address (bit)| Description|Usage example|Example description
|-------------|---------------|-----------|-----------
|0-8|Opcode|1111 1110|(constant)

### DEBUG (Virtual Machine only)
Prints a debug string into the virtual machine console. This instruction is only implemented in a VM environment and on hardware is equivalent to a NOOP.
## we can implement this function in the hardware displaying one register at a time.

|Address (bit)| Description|Usage example|Example description
|-------------|---------------|-----------|-----------
|0-8|Opcode|1111 1111|(constant)
|9-12| Register to be displayed in hardware



