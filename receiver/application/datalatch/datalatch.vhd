--***************************************
--* TITLE: Datalatch (receiver)	*
--* TYPE: Component 			*
--* AUTHOR: Dylan Van Assche 		*
--* DATE: 26/10/2017 			*
--***************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- Read the serial data stream from the access layer and keep it for a limited time in a register.
-- Application layer will 'ask' if the preamble is in the register before it reads from it
--2)Principle:
-- When the shift signal is received, data is shifted out (1 place).
--3)Inputs:
-- sh, serialdata, clk, clk_en, rst
--4)Outputs:
-- preamble, value
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY datareg IS
  PORT (
		sh         : IN  std_logic;
		clk        : IN  std_logic;
		clk_en     : IN  std_logic;
		rst        : IN  std_logic;
		serialdata : IN std_logic;
		value      : OUT std_logic_vector(3 DOWNTO 0);
		preamble   : OUT std_logic_logic(6 DOWNTO 0)
    	 );
END datareg;

--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE behavior OF datareg IS
	SIGNAL reg: std_logic_vector(9 DOWNTO 0);
	SIGNAL reg_next: std_logic_vector(9 DOWNTO 0);
BEGIN
-- connect signal to output
preamble <= reg(9 DOWNTO 4);
value <= reg(3 DOWNTO 0);
-- 2-Process: synchronous part
reg_sync : PROCESS (clk)
BEGIN
	IF (rising_edge(clk) AND clk_en = '1') THEN
		IF (rst = '1') THEN -- rst line high, go to initial state
			reg <= (OTHERS => '0');
		ELSE -- normal operation
			reg <= reg_next;
		END IF;
	END IF;
END PROCESS reg_sync;
-- 2-Process: combinatoric part
reg_comb : PROCESS(reg, sh)
BEGIN
	IF sh = '1' THEN -- shift data with serialdata as input
		reg_next <= reg(9 DOWNTO 1) & serialdata;
	ELSE -- Input signals wrong!
		reg_next <= reg;
	END IF;
END PROCESS reg_comb;
END behavior;