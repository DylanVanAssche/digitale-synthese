--***********************************************
--* TITLE: DPLL Transition detector (receiver)	*
--* TYPE: Component 			        *
--* AUTHOR: Dylan Van Assche 		        *
--* DATE: 5/12/2017 			        *
--***********************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- Detect transitions on sdi_spread
--2)Principle:
-- Wait for transition on sdi_spread.
-- Send puls out for 1 CLK period.
-- Moore statemachine (4 states):
--	* WAIT FOR 0: wait until the input returns to 0, go to PULSE 0.
--	* WAIT FOR 1: wait until the input returns to 1, go to PULSE 1.
--	* PULSE 0: send out pulse for 1 CLK period, go to WAIT FOR 1.
--	* PULSE 1: send out pulse for 1 CLK period, go to WAIT FOR 0.
--3)Inputs:
-- sdi_spread, clk, clk_en, rst
--4)Outputs:
-- extb
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY dpll_transdect IS
  PORT (
		clk          : IN  std_logic;
		clk_en       : IN  std_logic;
		rst          : IN  std_logic;
		sdi_spread   : IN  std_logic;
		extb         : OUT std_logic
  	 );
END dpll_transdect;

--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE behavior OF dpll_transdect IS
	TYPE state IS (waitFor1, puls1, puls0, waitFor0);
	SIGNAL present_state	: state;
	SIGNAL next_state	: state;
BEGIN
-- 2-Process: synchronous part
moore_sync : PROCESS(clk)
BEGIN
	IF (rising_edge(clk) AND clk_en = '1') THEN
		IF (rst = '1') THEN -- rst line high, go to initial state
			present_state <= waitFor1;
		ELSE -- normal operation
			present_state <= next_state;
		END IF;
	END IF;
END PROCESS moore_sync;
-- 2-Process: combinatoric part
moore_comb : PROCESS(present_state, sdi_spread)
BEGIN
-- Statemachine Moore
CASE present_state IS
	-- wait for 0 on sdi_spread
	WHEN waitFor0 => extb <= '0';
		IF (sdi_spread = '0') THEN
			next_state <= puls0;
		ELSE
			next_state <= waitFor0;
		END IF;
	-- clock transition puls reason = waitFor0
	WHEN puls0 => extb <= '1';
		IF (sdi_spread = '1') THEN
			next_state <= puls1;
		ELSE
			next_state <= waitFor1;
		END IF;  
	-- clock transition puls reason = waitFor1
	WHEN puls1 => extb <= '1';
		IF (sdi_spread = '0') THEN
			next_state <= puls0;
		ELSE
			next_state <= waitFor0;
		END IF; 
	-- wait for 1 on sdi_spread
	WHEN waitFor1 => extb <= '0';
		IF (sdi_spread = '1') THEN
			next_state <= puls1;
		ELSE
			next_state <= waitFor1;
		END IF;  
	-- wait for 1 on sdi_spread  
	WHEN OTHERS => extb <= '0';
		next_state <= waitFor0;
END CASE;
END PROCESS moore_comb;
END behavior;