--*******************************
--* TITLE: Debouncer (sender) 	*
--* TYPE: Component 		*
--* AUTHOR: Dylan Van Assche 	*
--* DATE: 28/09/2017 		*
--*******************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- Debouncing the input buttons.
--2)Principle:
-- When detecting 4 clock cycles the same input, data is valid.
--3)Ingangen:
-- cha, rst, clk
--4)Uitgangen:
-- syncha
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
ENTITY debouncer IS
	PORT
	(
		cha, clk, clk_en, rst : IN std_logic;
		syncha                : OUT std_logic
	);
END debouncer;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE behavior OF debouncer IS
	SIGNAL reg      : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');
	SIGNAL reg_next : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');
	SIGNAL sh_ldb   : std_logic;
BEGIN
-- output of the shiftreg asigned to syncha (signal -> output)
syncha <= reg(0);
-- exor
sh_ldb <= reg(0) XOR cha;
-- 2-Process: synchronous part
sync_debouncer : PROCESS (clk)
BEGIN
	IF (rising_edge(clk) AND clk_en = '1') THEN
		IF (rst = '1') THEN -- reset line high, go to initial state
			reg <= (OTHERS => '0');
		ELSE -- normal operation
			reg <= reg_next;
		END IF;
	END IF;
END PROCESS sync_debouncer;
-- 2-Process: combinatoric part
comb_debouncer : PROCESS (reg, sh_ldb, cha)
BEGIN
	IF (sh_ldb = '1') THEN
		reg_next <= cha & reg(3 DOWNTO 1);
	ELSE
		reg_next <= (OTHERS => reg(0));
	END IF;
END PROCESS comb_debouncer;
END behavior;
