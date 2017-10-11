--*******************************
--* TITLE: Counter (sender)	*
--* TYPE: Component 		*
--* AUTHOR: Dylan Van Assche 	*
--* DATE: 01/10/2017 		*
--*******************************
--* DESCRIPTION *
--***************
--1)Purpose:
-- Counting up/down
--2)Principle:
-- When up or down input is high, count
--3)Ingangen:
-- up, down, rst, clk, clk_en
--4)Uitgangen:
-- output
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
ENTITY counter IS
	PORT
	(
		clk, clk_en, rst, up, down : IN std_logic;
		output                     : OUT std_logic_vector(3 DOWNTO 0)
	);
	SIGNAL n_count : std_logic_vector(3 DOWNTO 0);
	SIGNAL p_count : std_logic_vector(3 DOWNTO 0);
END;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE behavior OF counter IS
BEGIN
	output <= p_count;
	-- 2-Process: synchronous part
	count_sync : PROCESS (clk)
	BEGIN
		IF (rising_edge(clk) AND clk_en = '1') THEN
			IF (rst = '1') THEN -- rst line high, go to initial state
				p_count <= (OTHERS => '0');
			ELSE -- normal operation
				p_count <= n_count;
			END IF;
		END IF;
	END PROCESS count_sync;
	-- 2-Process: combinatoric part
	count_comb : PROCESS (p_count, up, down)
	BEGIN
		IF up = '1' AND down = '0' THEN -- count up
			n_count <= p_count + 1;
		ELSIF down = '1' AND up = '0' THEN -- count down
			n_count <= p_count - 1;
		ELSE
			n_count <= p_count; -- halt
		END IF;
	END PROCESS count_comb;
END behavior;