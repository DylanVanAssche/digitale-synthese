--***************************************
--* TITLE: Correlator (receiver)	*
--* TYPE: Component 			*
--* AUTHOR: Dylan Van Assche 		*
--* DATE: 21/11/2017 			*
--***************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- Removing noise from the despreader signal
--2)Principle:
-- Up/Down counter to detect if the bit (holded in the chips) is '1' or '0'. 
-- A '1' increments the counter, a 0 decrements the counter.
-- On the bitsample signal we check the counter value when > 32 which is a bit = '1' otherwise the bit is '0'.
--3)Inputs:
-- sdi_despread, bitsample, chipsample, clk, clk_en, rst
--4)Outputs:
-- databit
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY correlator IS
	PORT (
		clk          : IN  std_logic;
		clk_en       : IN  std_logic;
		rst          : IN  std_logic;
		sdi_despread : IN  std_logic;
		bitsample    : IN  std_logic;
		chipsample   : IN  std_logic;
		databit      : OUT std_logic
  	 );
END correlator;

--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE behavior OF correlator IS
	SIGNAL n_count : std_logic_vector(5 DOWNTO 0) := "100000";
	SIGNAL p_count : std_logic_vector(5 DOWNTO 0) := "100000";
	SIGNAL n_reg   : std_logic := '0';
	SIGNAL p_reg   : std_logic := '0';
BEGIN
-- Connect signal to output
databit <= p_reg;
-- 2-Process: synchronous part
correlator_sync : PROCESS (clk)
BEGIN
	IF (rising_edge(clk) AND clk_en = '1') THEN
		IF (rst = '1') THEN -- rst line high, go to initial state
			p_count <= "100000";
			p_reg <= '0';
		ELSE -- normal operation
			p_count <= n_count; -- count
			p_reg <= n_reg; -- datareg
		END IF;
	END IF;
END PROCESS correlator_sync;
-- 2-Process: combinatoric part
correlator_comb : PROCESS(bitsample, chipsample, sdi_despread, p_count, p_reg)
BEGIN
	-- up/down counter on chip_sample
	IF (sdi_despread = '1' AND chipsample = '1') THEN -- count up
		n_count <= p_count + 1;   
	ELSIF (sdi_despread = '0' AND chipsample = '1') THEN -- count down
		n_count <= p_count - 1;
	ELSE -- all other cases, do nothing
		n_count <= p_count;
	END IF;
	-- load dataregister on bitsample with counter value
	IF (bitsample = '1' AND p_count(5) = '1' ) THEN --MSB = 1 then at least 32 or higher
		n_reg <= '1';
	ELSIF (bitsample = '1' AND p_count(5) = '0' ) THEN --MSB = 0 then at max 31 or lower
		n_reg <= '0';
	ELSE -- all other cases, do nothing
		n_reg <= p_reg;
	END IF;
END PROCESS correlator_comb;
END behavior;
