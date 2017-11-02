--***************************************
--* TITLE: Dataregister (transmitter)	*
--* TYPE: Component 			*
--* AUTHOR: Dylan Van Assche 		*
--* DATE: 19/10/2017 			*
--***************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- Generate serial data output with a preamble and counter data
--2)Principle:
-- When the load signal is received, data is loaded from the counter.
-- When the shift signal is received, data is shifted out (1 place).
--3)Inputs:
-- sh, ld, data, clk, clk_en, rst
--4)Outputs:
-- output
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY datareg IS
	PORT (
		sh     : IN  std_logic; 
		ld     : IN  std_logic;
		clk    : IN  std_logic;
		clk_en : IN  std_logic;
		rst    : IN  std_logic;
		data   : IN  std_logic_vector(3 DOWNTO 0);
		output : OUT std_logic
    	 );
END datareg;

--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE behavior OF datareg IS
	SIGNAL reg: std_logic_vector(10 DOWNTO 0);
	SIGNAL reg_next: std_logic_vector(10 DOWNTO 0);
	CONSTANT PREAMBLE: std_logic_vector(6 DOWNTO 0) := "0111110";
BEGIN
-- connect signal to output
output <= reg(0);
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
reg_comb : PROCESS(reg, ld, sh)
BEGIN
	IF ld = '1' AND sh = '0' THEN -- load data, first PREAMBLE to reg(0) then the number of the counter
		reg_next <= data & PREAMBLE;
	ELSIF ld = '0' AND sh = '1' THEN -- shift data, first preamble to reg(0) then the number of the counter
		reg_next <= '0' & reg(10 DOWNTO 1); -- Zeros added since load signal will occur as soon as zeros are arrived at the output
	ELSE -- Input signals wrong!
		reg_next <= reg;
	END IF;
END PROCESS reg_comb;
END behavior;