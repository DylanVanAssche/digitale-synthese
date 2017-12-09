--***************************************
--* TITLE: DPLL Semaphore (receiver)	*
--* TYPE: Component	 		*
--* AUTHOR: Dylan Van Assche	 	*
--* DATE: 9/12/2017 			*
--***************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- DPLL semaphore regulates the segment signals depending on extb and chipsample_1 signals (synchronisation).
--2)Principle:
-- Mealy statemachine (2 states):
-- 	* WAIT FOR EXTB: waiting for synchronisation pulse, send SEG_C out. On EXTB signal, go to WAIT FOR CS.
--	* WAIT FOR CS: waiting for chipsample pulse, send input segment (from periodcounter) out. On chipsample_1 signal, go to WAIT FOR EXTB.
--3)Inputs:
-- segments_in, extb, chipsample_1
--4)Outputs:
-- segments_out
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY dpll_semaphore IS
  PORT (
		clk		: IN  std_logic;
		clk_en		: IN  std_logic;
		rst		: IN  std_logic;
		extb		: IN  std_logic;
		chipsample_1	: IN  std_logic;
		segments_in	: IN  std_logic_vector(4 DOWNTO 0);
		segments_out	: OUT std_logic_vector(4 DOWNTO 0)
  	 );
END dpll_semaphore;

--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE behavior OF dpll_semaphore IS
	-- constants
	CONSTANT SEG_C		: std_logic_vector(4 DOWNTO 0) := "00100";
	-- signals & states
	TYPE state IS (waitForEXTB, waitForCS);
	SIGNAL present_state	: state;
	SIGNAL next_state	: state;
	SIGNAL segments_next	: std_logic_vector(4 DOWNTO 0) := SEG_C;
BEGIN
-- 2-Process: synchronous part
mealy_sync: PROCESS(clk)
BEGIN
	IF (rising_edge(clk) AND clk_en = '1') THEN
		IF (rst = '1') THEN -- rst line high, go to initial state
			present_state <= waitForEXTB;
		ELSE  -- normal operation
			present_state <= next_state;
		END IF;
	END IF;
END PROCESS mealy_sync;
-- 2-Process: combinatoric part
mealy_comb: PROCESS(present_state, extb, chipsample_1, segments_in)
BEGIN
-- Statemachine Mealy, direct action required
CASE present_state IS
	-- wait for EXTB signal
	WHEN waitForEXTB => segments_out <= SEG_C;
		IF (extb = '1') THEN
			next_state <= waitForCS;
		ELSE
			next_state <= waitForEXTB;
		END IF;
	-- wait for chipsample_1 signal
	WHEN waitForCS => segments_out <= segments_in;
		IF (chipsample_1 = '1') THEN
			next_state <= waitForEXTB;
		ELSE
			next_state <= waitForCS;
		END IF;  
	-- synchronisation is needed since state is unknown
	WHEN OTHERS => segments_next <= SEG_C;
		next_state <= waitForEXTB;
END CASE;
END PROCESS mealy_comb;
END behavior;