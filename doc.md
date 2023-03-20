# HardWare Design Lib
------
### ALU
- Supports 12 Operations
- Changeable with parameters
<table><tr><th>
            Operation
        </th><th>
            OpCode
        </th> </tr><tr><th>
        Addition
        </th><th>
            0001
        </th></tr><tr><th>
        Substraction
    </th><th>
            0010
    </th></tr><tr><th>
        Multiplication
        </th><th>
            0011<tr><th>
        Divison
        </th><th>
            0100
        </th></tr><tr><th>
        Left Shift
        </th><th>
            0101
        </th></tr><tr><th>
        Right Shift
        </th><th>
            0110
        </th></tr><tr><th>
        Or
        </th> <th>
            0111
        </th></tr><tr><th>
        And
        </th><th>
            1000
        </th></tr> <tr><th>
        Nand</th><th>
            1001
        </th></tr> <tr><th>
        Xor
        </th><th>
            1010
        </th></tr><tr><th>
        Xnor
        </th><th>
            1011</th></tr><tr><th>
        nor
        </th> <th>
            1100
        </th></tr></table>

### SRAM
- Size and bitdeep changeable per parameters
> Pre defidet is 16bit adressbus, 65536 cells, 32 bits per cell
<table><tr><th>
    Do</th><th>
    WE</th><th>
    OE</th><tr><th>
    Read</th><th>
    0</th><th>
    1</th></tr><tr><th>
    Write</th><th>
    1</th><th>
    0</th></tr><tr><th>
    Standby</th><th>
    0</th><th>
    0</th></tr></table>