--***********************************************
--* TITLE: Dataregister TESTBENCH (receiver)	*
--* TYPE: Component 			*
--* AUTHOR: Dylan Van Assche 		*
--* DATE: 26/10/2017 			*
--***************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- Read the serial data stream from the access layer and keep it for a limited time in a register.
-- Application layer will 'ask' if the preamble is in the register before it reads from it
--2)Principle:
-- When the shift signal is received, data is shifted out (1 place).
--3)Inputs:
-- sh, serialdata, clk, clk_en, rst
--4)Outputs:
-- preamble, value
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;
ENTITY datareg_test IS
END datareg_test;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE structural OF datareg_test IS
	--initialize signals & constants
	CONSTANT PERIOD   : TIME := 100 ns;
	CONSTANT DELAY    : TIME := 10 ns;
	SIGNAL end_of_sim : BOOLEAN := false;
	SIGNAL clk        : std_logic := '0';
	SIGNAL clk_en     : std_logic := '1';
	SIGNAL rst        : std_logic := '0';
	SIGNAL sh	        : std_logic := '0';
	SIGNAL value	     : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0'); -- counter value part register
	SIGNAL preamble	  : std_logic_vector(6 DOWNTO 0) := (OTHERS => '0'); -- preamble part register
BEGIN
--***********
--* MAPPING *
--***********
uut : ENTITY work.datareg(behavior)
	PORT MAP
	(
		clk        => clk,
		clk_en     => clk_en,
		rst        => rst,
		sh         => sh,
		serialdata => serialdata,
		value      => value,
		preamble   => preamble
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
		WAIT FOR PERIOD * 2;
		rst <= '0';
		WAIT FOR PERIOD;
	END reset;
	-- Test data procedure
	PROCEDURE test (CONSTANT TESTDATA : IN std_logic_vector(1 DOWNTO 0)) IS
	BEGIN
		data <= TESTDATA(0);
		sh <= TESTDATA(1);
		WAIT FOR PERIOD * 1;
		sh <= '0';
		WAIT FOR PERIOD * 5; -- normally 31 clock cycles for sequence controller (PN_START)
	END test;
BEGIN
	-- Reset at startup
	reset;
	-- Test data TO DO
	FOR counter IN 0 TO 3 LOOP -- 3 cycles with 3 different counter values
		FOR i IN 0 TO 10 LOOP -- imitate sequencecontroller
			IF(i = 0) THEN -- load
				test(CONV_STD_LOGIC_VECTOR(counter, 4) & "01");
			ELSE -- shift
				test(CONV_STD_LOGIC_VECTOR(counter, 4) & "10");
			END IF;
		END LOOP;
	END LOOP;
	clk_en <= '0'; -- disable clock
	test(CONV_STD_LOGIC_VECTOR(5, 4) & "10");
	test(CONV_STD_LOGIC_VECTOR(6, 4) & "01");
	end_of_sim <= true;
	WAIT;
END PROCESS;
END;

