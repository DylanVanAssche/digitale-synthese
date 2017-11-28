--*************************************
--* TITLE: Matched Filter (receiver)  *
--* TYPE: Component 		                *
--* AUTHOR: Dylan Van Assche 	        *
--* DATE: 28/11/2017 		               *
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
USE ieee.std_logic_arith.ALL;
ENTITY matchfilter_test IS
END matchfilter_test;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE structural OF matchfilter_test IS
	--initialize signals & constants
	CONSTANT PERIOD        : TIME := 100 ns;
	CONSTANT DELAY         : TIME := 10 ns;
	SIGNAL end_of_sim      : BOOLEAN := false;
	SIGNAL clk             : std_logic := '0';
	SIGNAL clk_en          : std_logic := '1';
	SIGNAL rst             : std_logic := '0';
	SIGNAL sdi_spread      : std_logic := '0';
	SIGNAL chip_sample     : std_logic := '0';
	SIGNAL seq_det         : std_logic := '0';
	SIGNAL pn_select       : std_logic_vector(1 DOWNTO 0) := "00";
	--initialize constants
	CONSTANT NO_PTRN: std_logic_vector(30 DOWNTO 0) := (OTHERS => '0');
	CONSTANT PTRN_1 : std_logic_vector(30 DOWNTO 0) := "0100001010111011000111110011010"; -- WARNING: this can change depending on how the transmitter is implemented!
	CONSTANT PTRN_2 : std_logic_vector(30 DOWNTO 0) := "1110000110101001000101111101100"; -- In case if this isn't working, shift all bit and try again!
	CONSTANT PTRN_3 : std_logic_vector(30 DOWNTO 0) := "1010001100010010000010001110110";
BEGIN
--***********
--* MAPPING *
--***********
uut : ENTITY work.matchfilter(behavior)
	PORT MAP
	(
		clk          => clk,
		clk_en       => clk_en,
		rst          => rst,
		sdi_spread   => sdi_spread,
		chip_sample  => chip_sample,
		seq_det      => seq_det,
		pn_select    => pn_select
	);
-- Only for synchronous components
clock : PROCESS
BEGIN
	clk <= '0';
	WAIT FOR PERIOD/2;
	LOOP
		clk <= '0';
		WAIT FOR PERIOD/2;
		clk <= '1';
		WAIT FOR PERIOD/2;
		EXIT WHEN end_of_sim;
	END LOOP;
	WAIT;
END PROCESS clock;
-- Testbench
tb : PROCESS
	-- Reset procedure to initialize the component
	PROCEDURE reset IS
	BEGIN
		rst <= '1';
		WAIT FOR PERIOD*2;
		rst <= '0';
		WAIT FOR PERIOD;
	END reset;
	-- Test data procedure
	PROCEDURE test (CONSTANT TESTPN : IN std_logic_vector(1 DOWNTO 0); CONSTANT TESTCHIP: IN std_logic; CONSTANT TESTDATA: IN std_logic) IS
	BEGIN
		pn_select <= TESTPN;
		chip_sample <= TESTCHIP;
		sdi_spread <= TESTDATA;
		WAIT FOR PERIOD;
	END test;
BEGIN
	-- Reset at startup
	reset;
	-- Test data
	-- seq_det should be 0 for the next loop:
	FOR pn_code IN 0 TO 3 LOOP
	  FOR i IN 0 TO 30 LOOP
	    test(CONV_STD_LOGIC_VECTOR(pn_code, 2), '1', '1');
	  END LOOP;
	END LOOP;
	-- seq_det should be 1 for the next 3 loops, NO_PTRN isn't used and already visible in the above loop at initialisation:
	-- pn1
  FOR i IN 0 TO 30 LOOP
	    test("01", '1', PTRN_1(30-i));
	END LOOP;
	FOR i IN 0 TO 30 LOOP
	    test("01", '1', PTRN_1(30-i));
	END LOOP;
	test("11",'0','0');-- show
	WAIT FOR PERIOD*3;
	-- pn2
	FOR i IN 0 TO 30 LOOP
	    test("10", '1', PTRN_2(30-i));
	END LOOP;
	FOR i IN 0 TO 30 LOOP
	    test("10", '1', PTRN_2(30-i));
	END LOOP;
	test("11",'0','0');-- show
	WAIT FOR PERIOD*3;
	FOR i IN 0 TO 30 LOOP
	    test("11", '1', PTRN_3(30-i));
	END LOOP;FOR i IN 0 TO 30 LOOP
	    test("11", '1', PTRN_3(30-i));
	END LOOP;
	-- pn3
	test("11",'1','0');-- show
	WAIT FOR PERIOD*3;
		
	end_of_sim <= true;
	WAIT;
END PROCESS;
END;

