--***********************************************
--* TITLE: DPLL Periodcounter (receiver)	*
--* TYPE: Component	 			*
--* AUTHOR: Dylan Van Assche	 		*
--* DATE: 5/12/2017 				*
--***********************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- DPLL period counter counts the periods of the transition detector pulses.
--2)Principle:
-- Deadendupcounter (4 bits) which decodes the segments of the period as output.
-- Segments are exclusive active! Each period is divided in 16 pieces and we want to sample in segment C (middle of a period)
-- Synchronisation is needed to do this!
--3)Inputs:
-- extb
--4)Outputs:
-- segments
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY dpll_periodcounter IS
  PORT (
		clk       : IN  std_logic;
		clk_en    : IN  std_logic;
		rst       : IN  std_logic;
		extb      : IN  std_logic;
		segments  : OUT std_logic_vector(4 DOWNTO 0)
  	 );
END dpll_periodcounter;

--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE behavior OF dpll_periodcounter IS
	SIGNAL n_count      : std_logic_vector(3 DOWNTO 0);
	SIGNAL p_count      : std_logic_vector(3 DOWNTO 0);
	CONSTANT MAXVALUE   : std_logic_vector(3 DOWNTO 0) := "1111"; -- deadendupcounter maximum
	CONSTANT RSTVALUE   : std_logic_vector(3 DOWNTO 0) := "0000"; -- deadendupcounter reset value
	-- Segment codes for decoder
	CONSTANT SEG_A      : std_logic_vector(4 DOWNTO 0) := "10000";
	CONSTANT SEG_B      : std_logic_vector(4 DOWNTO 0) := "01000";
	CONSTANT SEG_C      : std_logic_vector(4 DOWNTO 0) := "00100";
	CONSTANT SEG_D      : std_logic_vector(4 DOWNTO 0) := "00010";
	CONSTANT SEG_E      : std_logic_vector(4 DOWNTO 0) := "00001";
BEGIN
-- 2-Process: synchronous part
count_sync: PROCESS(clk)
BEGIN
	IF (rising_edge(clk) AND clk_en = '1') THEN
		IF (rst = '1') THEN -- rst line high, go to initial state
			p_count <= (OTHERS => '0');
		ELSE  
			p_count <= n_count;
		END IF;
	END IF;
END PROCESS count_sync;
-- 2-Process: combinatoric part (deadendupcounter)
count_comb: PROCESS(p_count, extb)
BEGIN
	IF (extb = '0') THEN -- no puls received
		IF (n_count = MAXVALUE) THEN -- prevent counting 
			n_count <= p_count;
		ELSE -- count normally
			n_count <= p_count + 1;
		END IF;
	ELSE -- comb. reset when puls is received
		n_count <= RSTVALUE;
	END IF;
END PROCESS count_comb;
-- 2-Process: combinatoric part (decoder)
decoder_comb: PROCESS(p_count)
BEGIN
	IF (p_count <= "0100") THEN -- <= 4 SEG A
		segments <= SEG_A;
	ELSIF (p_count <= "0110") THEN -- <= 6 SEG B
		segments <= SEG_B;
	ELSIF (p_count <= "1000") THEN -- <= 8 SEG C
		segments <= SEG_C;
	ELSIF (p_count <= "1010") THEN -- <= 10 SEG D
		segments <= SEG_D;
	ELSIF (p_count <= "1111") THEN -- <= 15 SEG E
		segments <= SEG_E;
	ELSE -- All other cases
		segments <= SEG_C;
	END IF;
END PROCESS decoder_comb;
END behavior;

