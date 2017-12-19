--***************************************
--* TITLE: NCO (receiver)		*
--* TYPE: Component 			*
--* AUTHOR: Dylan Van Assche 		*
--* DATE: 13/12/2017 			*
--***************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- NCO to divide the 100 Mhz clock of the Virtex II Pro.
--2)Principle:
-- When counting down, send a clk_en signal out and restart.
--3)Ingangen:
-- rst, clk
--4)Uitgangen:
-- clk_en
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
ENTITY nco_rx IS
	PORT
	(
		clk     : IN std_logic;
		rst     : IN std_logic;
		clk_en  : OUT std_logic
	);
END;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE behavior OF nco_rx IS
	SIGNAL n_count		: std_logic_vector(10 DOWNTO 0);
	SIGNAL p_count		: std_logic_vector(10 DOWNTO 0);
	SIGNAL enable		: std_logic := '1'; -- allow for reset
	SIGNAL enable_next	: std_logic := '0';
	CONSTANT TRIGGER	: std_logic_vector(10 DOWNTO 0) := (OTHERS => '0');
BEGIN
clk_en <= enable;
-- 2-Process: synchronous part
count_sync : PROCESS (clk)
BEGIN
	IF (rising_edge(clk)) THEN
		IF (rst = '1') THEN -- rst line high, go to initial state
			p_count <= (OTHERS => '0');
			enable <= '1';
		ELSE -- normal operation
			p_count <= n_count;
			enable <= enable_next;
		END IF;
	END IF;
END PROCESS count_sync;
-- 2-Process: combinatoric part
count_comb : PROCESS (p_count, enable)
BEGIN
	n_count <= p_count + 1;
	IF (n_count = TRIGGER) THEN -- clk_en signal
		enable_next <= '1';
	ELSE
		enable_next <= '0';
	END IF;
END PROCESS count_comb;
END behavior;