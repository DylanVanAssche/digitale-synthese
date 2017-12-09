--*************************************
--* TITLE: Matched Filter (receiver)  *
--* TYPE: Component 		      *
--* AUTHOR: Dylan Van Assche 	      *
--* DATE: 21/11/2017 		      *
--*************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- Filter PN code sequences from noisy sdi_spread signal
--2)Principle:
-- Using a MUX we select the right PN code on the receiver, 
-- when the shift register contains the PN code that we selected, 
-- the comparator will output a '1' to the PN Generator.
-- The inverted version of all the PN codes are generated using a NOT port and not reimplemented!
--3)Inputs:
-- sdi_spread, chip_sample, clk, clk_en, rst
--4)Outputs:
-- output
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
ENTITY matchfilter IS
	PORT
	(
		clk         : IN std_logic;
		clk_en      : IN std_logic;
		rst         : IN std_logic;
		sdi_spread  : IN std_logic;
		chip_sample : IN std_logic;
		pn_select   : IN std_logic_vector(1 DOWNTO 0);
		seq_det     : OUT std_logic
	);
END matchfilter;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE behavior OF matchfilter IS
	SIGNAL output: std_logic;
	SIGNAL output_next: std_logic;
	SIGNAL chipreg: std_logic_vector(30 DOWNTO 0);
	SIGNAL chipreg_next: std_logic_vector(30 DOWNTO 0);
	SIGNAL current_pn: std_logic_vector(30 DOWNTO 0);
	CONSTANT NO_PTRN: std_logic_vector(30 DOWNTO 0) := (OTHERS => '0');
	CONSTANT PTRN_1 : std_logic_vector(30 DOWNTO 0) := "0101100111110001101110101000010"; -- WARNING: this can change depending on how the transmitter is implemented!
	CONSTANT PTRN_2 : std_logic_vector(30 DOWNTO 0) := "0011011111010001001010110000111"; -- In case if this isn't working, shift all bit and try again!
	CONSTANT PTRN_3 : std_logic_vector(30 DOWNTO 0) := "0110111000100000100100011000101";
BEGIN
-- connect signal to output
seq_det <= output;
-- 2-Process: synchronous part
matchfilter_sync : PROCESS (clk)
BEGIN
	IF (rising_edge(clk) AND clk_en = '1') THEN
		IF (rst = '1') THEN -- rst line high, go to initial state
			output <= '0';
			chipreg <= (OTHERS => '0');
		ELSE -- normal operation
		  chipreg <= chipreg_next;
			output <= output_next;
		END IF;
	END IF;
END PROCESS matchfilter_sync;
-- 2-Process: combinatoric part
matchfilter_comb : PROCESS(sdi_spread, chip_sample, chipreg, current_pn)
BEGIN
  -- Compare if the register contains our PN code (normal or inverted), if so we set output to 1.
  IF((current_pn = chipreg) OR (NOT(current_pn) = chipreg)) THEN
    output_next <= '1';
  ELSE
    output_next <= '0';
  END IF;
  -- Shift the data from sdi_spread into the chip register on chip_sample
  IF(chip_sample = '1') THEN
    chipreg_next <= sdi_spread & chipreg(30 DOWNTO 1);
  ELSE
    chipreg_next <= chipreg;
  END IF;
END PROCESS matchfilter_comb;
-- MUX comb process
mux : PROCESS(pn_select) 
BEGIN
  -- Execute MUX, reusing not possible due type mismatch (std_logic != std_logic_vector)
  CASE pn_select IS
		WHEN "00"   => current_pn <= NO_PTRN; 
		WHEN "01"   => current_pn <= PTRN_1;  
		WHEN "10"   => current_pn <= PTRN_2; 
		WHEN "11"   => current_pn <= PTRN_3; 
		WHEN OTHERS => current_pn <= NO_PTRN; -- fallback
	END CASE;
END PROCESS mux;
END behavior;
