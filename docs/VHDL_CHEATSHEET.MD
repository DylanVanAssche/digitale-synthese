# VHDL Cheatsheet
_by Dylan Van Assche_

## STD_LOGIC_VECTOR
### syntax:
```myvector : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01000111" ```

:information_source: Myvector is a STD_LOGIC_VECTOR with a length of 8 bits.

:exclamation: __DOWN TO__ is Little Endian based: MSB.....LSB

### slicing:
- ```myvector(3 DOWNTO 0) = "111"```
- ```myvector(7) = "0"```

### concatenation:
- ```biggervector(10 DOWNTO 0) = myvector & "0000"``` results in: ```"010001110000"```

## Sources:
- [http://insights.sigasi.com/tech/to-downto-ranges-vhdl.html](http://insights.sigasi.com/tech/to-downto-ranges-vhdl.html)
