--***************************************
--* TITLE: Despreader (receiver)	*
--* TYPE: Component 			*
--* AUTHOR: Dylan Van Assche 		*
--* DATE: 14/11/2017 			*
--***************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- EXOR'ing with noise reduction
--2)Principle:
-- Timed EXOR'ing which is synced to the DPLL to reduce the noise on sdi_spread.
--3)Inputs:
-- sdi_spread, pn_code, clk, clk_en, rst
--4)Outputs:
-- sdi_despread
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY despreader IS
	PORT (
		clk          : IN  std_logic;
		clk_en       : IN  std_logic;
		rst          : IN  std_logic;
		sdi_spread   : IN  std_logic;
		pn_code      : IN  std_logic;
		chipsample   : IN  std_logic;
		sdi_despread : OUT std_logic
    	 );
END despreader;

--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE behavior OF despreader IS
	SIGNAL despread		: std_logic := '0';
	SIGNAL despread_next	: std_logic;
BEGIN
-- connect signal to output
sdi_despread <= despread;
-- 2-Process: synchronous part
despread_sync : PROCESS (clk)
BEGIN
	IF (rising_edge(clk) AND clk_en = '1' AND chipsample = '1') THEN
		IF (rst = '1') THEN -- rst line high, go to initial state
			despread <= '0';
		ELSE -- normal operation
			despread <= despread_next;
		END IF;
	END IF;
END PROCESS despread_sync;
-- 2-Process: combinatoric part
despread_comb : PROCESS(despread, sdi_spread, pn_code)
BEGIN
    despread_next <= sdi_spread XOR pn_code;
END PROCESS despread_comb;
END behavior;
