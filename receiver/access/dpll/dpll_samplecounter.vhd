--***********************************************
--* TITLE: DPLL Samplecounter (receiver)	*
--* TYPE: Component	 			*
--* AUTHOR: Dylan Van Assche	 		*
--* DATE: 6/12/2017 				*
--***********************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- DPLL sample counter counts down from a fixed value given by the periodcounter to synchronise with the transmitter data
--2)Principle:
-- Downcounter with a configurable reset value (Numerical Controlled Oscillator NCO) which resets on the value determined by the decoder.
-- The decoder gets the right segment signal from the semaphore. When the downcounter reaches 0 a pulse is generated (chipsample).
-- In order to synchronise every block in the receiver 3 chipsample signals are generated with a delay of 1 clock cycle between 
-- [chipsample_1, chipsample_2] and [chipsample_2, chipsample_3].
--3)Inputs:
-- segments
--4)Outputs:
-- chipsample_1, chipsample_2, chipsample_3
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY dpll_samplecounter IS
  PORT (
		clk		: IN  std_logic;
		clk_en		: IN  std_logic;
		rst		: IN  std_logic;
		segments	: IN std_logic_vector(4 DOWNTO 0);
		chipsample_1	: OUT std_logic;
		chipsample_2	: OUT std_logic;
		chipsample_3	: OUT std_logic
  	 );
END dpll_samplecounter;

--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE behavior OF dpll_samplecounter IS
	-- Segment codes for decoder
	CONSTANT SEG_A      		: std_logic_vector(4 DOWNTO 0) := "10000";
	CONSTANT SEG_B      		: std_logic_vector(4 DOWNTO 0) := "01000";
	CONSTANT SEG_C      		: std_logic_vector(4 DOWNTO 0) := "00100";
	CONSTANT SEG_D      		: std_logic_vector(4 DOWNTO 0) := "00010";
	CONSTANT SEG_E      		: std_logic_vector(4 DOWNTO 0) := "00001";
	-- Reset values for the downcounter for each segment
	CONSTANT SEG_A_RST_VALUE	: std_logic_vector(4 DOWNTO 0) := "10010"; --way too early: 18
	CONSTANT SEG_B_RST_VALUE	: std_logic_vector(4 DOWNTO 0) := "10000"; --too early: 16
	CONSTANT SEG_C_RST_VALUE	: std_logic_vector(4 DOWNTO 0) := "01111"; --ok: 15
	CONSTANT SEG_D_RST_VALUE	: std_logic_vector(4 DOWNTO 0) := "00011"; --too late: 14
	CONSTANT SEG_E_RST_VALUE	: std_logic_vector(4 DOWNTO 0) := "01110"; --way too late: 12
	-- Downcounter
	SIGNAL n_count			: std_logic_vector(4 DOWNTO 0);
	SIGNAL p_count			: std_logic_vector(4 DOWNTO 0);
	SIGNAL rst_count		: std_logic_vector(4 DOWNTO 0); -- Reset value for the downcounter default segment C
	-- 2 DOWNTO 0 is enough for the chipsample register but we can choose how much delay we want between chipsamples 1,2,3 with a longer register
	SIGNAL chip_next		: std_logic_vector(6 DOWNTO 0); 
	SIGNAL chip_present		: std_logic_vector(6 DOWNTO 0);
	-- Changing delays is just changing a number below:
	CONSTANT CS_1_POINT		: integer := 0;
	CONSTANT CS_2_POINT		: integer := 1;
	CONSTANT CS_3_POINT		: integer := 2;
BEGIN
-- Connect signals to outputs
chipsample_1 <= chip_present(CS_1_POINT);
chipsample_2 <= chip_present(CS_2_POINT);
chipsample_3 <= chip_present(CS_3_POINT);
-- 2-Process: synchronous part
count_sync: PROCESS(clk)
BEGIN
	IF (rising_edge(clk) AND clk_en = '1') THEN
		IF (rst = '1') THEN -- rst line high, go to initial state
			p_count <= SEG_C_RST_VALUE;
			chip_present <= (OTHERS => '0');
		ELSE  
			p_count <= n_count;
			chip_present <= chip_next;
		END IF;
	END IF;
END PROCESS count_sync;
-- 2-Process: combinatoric part (downcounter)
count_comb: PROCESS(p_count, chip_present, rst_count)
BEGIN
	IF (p_count = 0) THEN -- restart NCO on rst_count from the decoder and send puls
		chip_next <= chip_present(5 DOWNTO 0) & '1';
		n_count <= rst_count;
	ELSE -- count normally and shift further
		chip_next <= chip_present(5 DOWNTO 0) & '0';
		n_count <= p_count - 1;
	END IF;
END PROCESS count_comb;
-- 2-Process: combinatoric part (decoder)
decoder_comb: PROCESS(segments)
BEGIN
	IF (segments = SEG_A) THEN -- SEG A detected
		rst_count <= SEG_A_RST_VALUE;
	ELSIF (segments = SEG_B) THEN -- SEG B detected
		rst_count <= SEG_B_RST_VALUE;
	ELSIF (segments = SEG_C) THEN -- SEG C detected
		rst_count <= SEG_C_RST_VALUE;
	ELSIF (segments = SEG_D) THEN -- SEG D detected
		rst_count <= SEG_D_RST_VALUE;
	ELSIF (segments = SEG_E) THEN -- SEG E detected
		rst_count <= SEG_E_RST_VALUE;
	ELSE -- All other cases
		rst_count <= SEG_C_RST_VALUE;
	END IF;
END PROCESS decoder_comb;
END behavior;

