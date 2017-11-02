--***************************************
--* TITLE: Application (transmitter)	*
--* TYPE: Component			*
--* AUTHOR: Dylan Van Assche 		*
--* DATE: 01/10/2017 			*
--***************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- Application layer API.
--2)Principle:
-- Provide an API as application layer
--3)Inputs:
-- cha, rst, clk, clk_en
--4)Outputs:
-- output, display_b
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY application_layer IS
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
END application_layer;
ARCHITECTURE behavior OF application_layer IS
	SIGNAL counter_output     : std_logic_vector(3 DOWNTO 0);
	SIGNAL btn_up_debounced   : std_logic;
	SIGNAL btn_down_debounced : std_logic;
	SIGNAL btn_up_edged   	  : std_logic;
	SIGNAL btn_down_edged     : std_logic;
BEGIN
output <= counter_output;
debounce_up : ENTITY work.debouncer(behavior)
PORT MAP
(
	clk    => clk,
	clk_en => clk_en,
	rst    => rst,
	cha    => up,
	syncha => btn_up_debounced   
);
debounce_down : ENTITY work.debouncer(behavior)
PORT MAP
(
	clk    => clk,
	clk_en => clk_en,
	rst    => rst,
	cha    => down,
	syncha => btn_down_debounced
);
edge_up : ENTITY work.edgedetector(behavior)
PORT MAP
(
	data   => btn_up_debounced,
	puls   => btn_up_edged,
	clk    => clk,
	clk_en => clk_en,
	rst    => rst
);
edge_down : ENTITY work.edgedetector(behavior)
PORT MAP
(
	data   => btn_up_debounced,
	puls   => btn_down_edged,
	clk    => clk,
	clk_en => clk_en,
	rst    => rst
);
counter : ENTITY work.counter(behavior)
PORT MAP
(
	clk    => clk,
	clk_en => clk_en,
	rst    => rst,
	up     => btn_up_edged,
	down   => btn_down_edged,
	output => counter_output
);
decoder : ENTITY work.decoder(behavior)
PORT MAP
(
	bin    => counter_output,
	disp_b => display_b
);
END behavior;
