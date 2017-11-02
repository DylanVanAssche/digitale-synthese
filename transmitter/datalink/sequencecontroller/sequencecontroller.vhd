--***********************************************
--* TITLE: Sequencecontroller (transmitter)	*
--* TYPE: Component 		        	*
--* AUTHOR: Dylan Van Assche 			*
--* DATE: 19/10/2017 				*
--***********************************************
--* DESCRIPTION *
--***************
--1)Purpose:
-- Controlling the behavior of the dataregister
--2)Principle:
-- When 0, emit load signal. Data is loaded into the register. From 1 to 10 data is shifted by emitting the shift signal.
-- On 10, the counter rests itself and the sequence starts again.
--3)Inputs:
-- clk, clk_en, rst, pn_start
--4)Outputs:
-- ld, sh
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
ENTITY sequencecontroller IS
	PORT
	(
		clk      : IN std_logic;
		clk_en   : IN std_logic;
		rst      : IN std_logic;
		pn_start : IN std_logic;
		ld       : OUT std_logic; 
		sh       : OUT std_logic
	);
END;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE behavior OF sequencecontroller IS
	SIGNAL n_count : std_logic_vector(3 DOWNTO 0);
	SIGNAL p_count : std_logic_vector(3 DOWNTO 0);
	SIGNAL ld_next : std_logic;
	SIGNAL sh_next : std_logic;
BEGIN
-- 2-Process: synchronous part
count_sync : PROCESS (clk)
BEGIN
	IF (rising_edge(clk) AND clk_en = '1') THEN
		IF (rst = '1') THEN -- rst line high, go to initial state
			p_count <= (OTHERS => '0');
			ld <= '1';
      			sh <= '0';
		ELSE -- normal operation
			p_count <= n_count;
			ld <= ld_next;
			sh <= sh_next;
		END IF;
	END IF;
END PROCESS count_sync;
-- 2-Process: combinatoric part
-- 1 LOAD + 10 SHIFTS = counter from 0 to 10
count_comb : PROCESS (p_count, pn_start)
BEGIN
	IF p_count = "1010" AND pn_start = '1' THEN -- When 10, reset (priority)
		n_count <= "0000";
		ld_next <= '1';
    		sh_next <= '0';
	ELSIF pn_start = '1' THEN -- count up when PN_start is received
		n_count <= p_count + 1;
		ld_next <= '0';
    		sh_next <= '1';
	ELSE -- halt
		ld_next <= '0';
    		sh_next <= '0';
		n_count <= p_count; 
	END IF;
END PROCESS count_comb;
END behavior;
