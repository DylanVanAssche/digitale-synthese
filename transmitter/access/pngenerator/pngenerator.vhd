--***************************************
--* TITLE: PNGenerator (transmitter)	*
--* TYPE: Component 			*
--* AUTHOR: Dylan Van Assche 		*
--* DATE: 12/10/2017 			*
--***************************************
--* DESCRIPTION *
--***************
--1)Purpose:
-- Generating a PN code
--2)Principle:
-- Lineair feedback register to generate a PN code (31 bits)
--3)Inputs:
-- rst, clk, clk_en
--4)Outputs:
-- pn_start, pn_1, pn_2, pn_3
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
ENTITY pngenerator IS
	PORT
	(
		clk    : IN std_logic;
		clk_en : IN std_logic;
		rst    : IN std_logic;
		pn_s   : OUT std_logic; -- pn_0 is without PN code
		pn_1   : OUT std_logic;
		pn_2   : OUT std_logic;
		pn_3   : OUT std_logic
	);
	SIGNAL shdata1          : std_logic_vector(4 DOWNTO 0);
	SIGNAL shdata1_next     : std_logic_vector(4 DOWNTO 0);
	SIGNAL shdata2          : std_logic_vector(4 DOWNTO 0);
	SIGNAL shdata2_next     : std_logic_vector(4 DOWNTO 0);
	SIGNAL pn_start_next    : std_logic;
	SIGNAL pn_start         : std_logic;
	SIGNAL linear_feedback1 : std_logic;
	SIGNAL linear_feedback2 : std_logic;
END;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE behavior OF pngenerator IS
BEGIN
-- calculate linear feedback for both PN counters (LFSR)
linear_feedback1 <= (shdata1(0) XOR shdata1(3));
linear_feedback2 <= ((shdata2(0) XOR shdata2(1)) XOR shdata2(3)) XOR shdata2(4);
-- connect signals to outputs
pn_1 <= shdata1(0);
pn_2 <= shdata2(0);
pn_3 <= shdata1(0) XOR shdata2(0);
pn_s <= pn_start;
-- 2-Process: synchronous part
pn_sync : PROCESS (clk)
BEGIN
	IF (rising_edge(clk) AND clk_en = '1') THEN
		IF (rst = '1') THEN -- rst line high, go to initial state
			shdata1 <= "00010";
			shdata2 <= "00111";
			pn_start <= '1';
		ELSE -- normal operation
			pn_start <= pn_start_next;
			shdata1 <= shdata1_next;
			shdata2 <= shdata2_next;
		END IF;
	END IF;
END PROCESS pn_sync;
-- 2-Process: combinatoric part
pn_comb : PROCESS (shdata1, shdata2, linear_feedback1, linear_feedback2)
BEGIN
	shdata1_next <= linear_feedback1 & shdata1(4 DOWNTO 1);
	shdata2_next <= linear_feedback2 & shdata2(4 DOWNTO 1);
	IF (shdata1 = "00100") THEN -- next value is the start value, prepare this already
			pn_start_next <= '1';
	ELSE
			pn_start_next <= '0';
	END IF;	
END PROCESS pn_comb;
END behavior;
