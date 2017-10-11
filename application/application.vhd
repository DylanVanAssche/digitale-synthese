--*******************************
--* TITLE: Application (sender) *
--* TYPE: Component		*
--* AUTHOR: Dylan Van Assche 	*
--* DATE: 01/10/2017 		*
--*******************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- Application layer API.
--2)Principle:
-- Provide an API as application layer
--3)Ingangen:
-- cha, rst, clk, clk_en
--4)Uitgangen:
-- output, display_b
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY application IS
	PORT
	(
		clk       : IN std_logic;
		clk_en    : IN std_logic;
		rst       : IN std_logic;
		up        : IN std_logic;
		down      : IN std_logic;
		output    : OUT std_logic_vector(3 DOWNTO 0);
		display_b : OUT std_logic_vector(6 DOWNTO 0)
	);
END application;
ARCHITECTURE behavior OF application IS
	SIGNAL counter_output : std_logic_vector(3 DOWNTO 0);
	SIGNAL debounce1_syncha   : std_logic;
	SIGNAL debounce2_syncha : std_logic;
	SIGNAL edge1_puls   : std_logic;
	SIGNAL edge2_puls : std_logic;
BEGIN
	output <= counter_output;
	decoder : ENTITY work.decoder(behavior)
	PORT MAP
	(
		bin    => counter_output,
		disp_b => display_b
	);
	edge1 : ENTITY work.edgedetector(behavior)
	PORT MAP
	(
		data   => debounce1_syncha,
		puls   => edge1_puls,
		clk    => clk,
		clk_en => clk_en,
		rst    => rst
	);
	edge2 : ENTITY work.edgedetector(behavior)
	PORT MAP
	(
		data   => debounce2_syncha,
		puls   => edge2_puls,
		clk    => clk,
		clk_en => clk_en,
		rst    => rst
	);
	debounce1 : ENTITY work.debouncer(behavior)
	PORT MAP
	(
		clk    => clk,
		clk_en => clk_en,
		rst    => rst,
		cha    => up,
		syncha => debounce1_syncha
	);
	debounce2 : ENTITY work.debouncer(behavior)
	PORT MAP
	(
		clk    => clk,
		clk_en => clk_en,
		rst    => rst,
		cha    => down,
		syncha => debounce2_syncha
	);
	counter : ENTITY work.counter(behavior)
	PORT MAP
	(
		clk    => clk,
		clk_en => clk_en,
		rst    => rst,
		up     => edge1_puls,
		down   => edge2_puls,
		output => counter_output
	);
END behavior;
