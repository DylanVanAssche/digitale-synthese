--***************************************
--* TITLE: Datalatch (receiver)		*
--* TYPE: Component 			*
--* AUTHOR: Dylan Van Assche 		*
--* DATE: 26/10/2017 			*
--***************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- Read the data and preamble from the datashiftreg from the datalink layer only when preamble is valid
--2)Principle:
-- When the preamble is found in the datashiftreg from the datalink layer we load the data into the latch to display on the 7 segment display
--3)Inputs:
-- sh, data, preamble, clk, clk_en, rst
--4)Outputs:
-- value
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY datalatch IS
  PORT (
		clk        : IN  std_logic;
		clk_en     : IN  std_logic;
		rst        : IN  std_logic;
		bitsample  : IN  std_logic;
		preamble   : IN  std_logic_vector(6 DOWNTO 0); -- 7bits
		data_in    : IN  std_logic_vector(3 DOWNTO 0); -- 4bits
		data_out   : OUT std_logic_vector(3 DOWNTO 0) 
    	 );
END datalatch;

--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE behavior OF datalatch IS
	SIGNAL latch: std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');
	SIGNAL latch_next: std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');
	CONSTANT PREAMBLE_VALUE: std_logic_vector(6 DOWNTO 0) := "0111110";
BEGIN
-- connect signal to output
data_out <= latch;
-- 2-Process: synchronous part
latch_sync : PROCESS (clk)
BEGIN
	IF (rising_edge(clk) AND clk_en = '1' AND bitsample = '1') THEN
		IF (rst = '1') THEN -- rst line high, go to initial state
			latch <= (OTHERS => '0');
		ELSE -- normal operation
			latch <= latch_next;
		END IF;
	END IF;
END PROCESS latch_sync;
-- 2-Process: combinatoric part
latch_comb : PROCESS(preamble, data_in, latch)
BEGIN
	IF (preamble = PREAMBLE_VALUE) THEN -- preamble found, set data in latch
		latch_next <= data_in;
	ELSE -- keeping value until preamble is found
		latch_next <= latch;
	END IF;
END PROCESS latch_comb;
END behavior;
