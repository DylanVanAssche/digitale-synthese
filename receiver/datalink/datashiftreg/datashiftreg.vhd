--***************************************
--* TITLE: Datashiftreg (receiver)	*
--* TYPE: Component 			*
--* AUTHOR: Dylan Van Assche 		*
--* DATE: 29/11/2017 			*
--***************************************
--* DESCRIPTION *
--***************
--1)Purpose:
-- Make the serial data available for the application layer as parallel data.
--2)Principle:
-- Loads the serial data from the access layer into a shift register. The preamble code is MSB and the data LSB.
--3)Inputs:
-- databit, bitsample, rst, clk, clk_en
--4)Outputs:
-- preamble, data
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
ENTITY datashiftreg IS
PORT
(
	clk        : IN std_logic;
	clk_en     : IN std_logic;
	rst        : IN std_logic;
	databit    : IN std_logic;
	bitsample  : IN std_logic;
	preamble   : OUT std_logic_vector(6 DOWNTO 0); --7bits
	data       : OUT std_logic_vector(3 DOWNTO 0) --4bits
);
END;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE behavior OF datashiftreg IS
	SIGNAL shdata          : std_logic_vector(10 DOWNTO 0) := (OTHERS => '0');
	SIGNAL shdata_next     : std_logic_vector(10 DOWNTO 0) := (OTHERS => '0');
BEGIN
-- connect signals to outputs
preamble <= shdata(10 DOWNTO 4);
data <= shdata(3 DOWNTO 0);
-- 2-Process: synchronous part
datashiftreg_sync : PROCESS (clk)
BEGIN
	IF (rising_edge(clk) AND clk_en = '1' AND bitsample = '1') THEN
		IF (rst = '1') THEN -- rst line high, go to initial state
			shdata <= (OTHERS => '0');
		ELSE -- normal operation
			shdata <= shdata_next;
		END IF;
	END IF;
END PROCESS datashiftreg_sync;
-- 2-Process: combinatoric part
datashiftreg_comb : PROCESS (shdata, databit)
BEGIN
	shdata_next <=  shdata(9 DOWNTO 0) & databit;
END PROCESS datashiftreg_comb;
END behavior;
