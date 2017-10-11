--******************************************************************************
--* TITLE: Edgedetector FSM (sender) *
--* TYPE: Component *
--* AUTHOR: Dylan Van Assche *
--* DATE: 05/10/2017 *
--******************************************************************************
--********************
--* DESCRIPTION *
--********************
--1)Purpose:
-- Check if a signal goes from LOW to HIGH
--2)Principle:
-- Moore FSM
--3)Inputs:
-- data, clk, clk_en, rst
--4)Outputs:
-- puls
--***************************
--* LIBRARIES & ENTITY *
--***************************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
ENTITY edgedetector IS
	PORT
	(
		data, clk, clk_en, rst : IN std_logic;
		puls                   : OUT std_logic
	);
END edgedetector;
--**************************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--**************************************************
ARCHITECTURE behavior OF edgedetector IS
	TYPE state IS (s0, s1, s2);
	SIGNAL present_state, next_state : state;
BEGIN
-- 2-Process: synchronous part
sync_moore : PROCESS (clk)
BEGIN
	IF (rising_edge(clk) AND clk_en = '1') THEN
		IF (rst = '1') THEN -- reset line high, go to initial state
			present_state <= s0;
		ELSE -- normal operation
			present_state <= next_state;
		END IF;
	END IF;
END PROCESS sync_moore;
-- 2-Process: combinatoric part
comb_moore : PROCESS (present_state, data)
BEGIN
	CASE present_state IS
		WHEN s0 => puls <= '0'; -- Initial state
		IF (data = '1') THEN -- data high, send puls
			next_state <= s1;
		ELSE
			next_state <= s0;
		END IF;
		WHEN s1 => puls <= '1'; -- Send puls out (high)
		next_state      <= s2;
		WHEN s2 => puls <= '0'; -- After 1 CLK cycle, puls low
		IF (data = '0') THEN -- data low, go to initial state
			next_state <= s0;
		ELSE
			next_state <= s2;
		END IF;
	END CASE;
END PROCESS comb_moore;
END behavior;