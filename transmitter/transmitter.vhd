--***************************************
--* TITLE: Transmitter (transmitter) 	*
--* TYPE: Top File			*
--* AUTHOR: Dylan Van Assche 		*
--* DATE: 25/10/2017 			*
--***************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- Connect all the layers into 1 VHDL file.
--2)Principle:
-- Connect every layer API.
--3)Inputs:
-- up, down, pn_select, rst, clk, clk_en
--4)Outputs:
-- tx
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY transmitter IS
	PORT
	(
		clk       : IN std_logic;
		clk_en    : IN std_logic;
		rst       : IN std_logic;
		up	  : IN std_logic;
		down	  : IN std_logic;
		pn_select : IN std_logic_vector(1 DOWNTO 0);
		display_b : OUT std_logic_vector(6 DOWNTO 0);
		tx	  : OUT std_logic
	);
END transmitter ;
ARCHITECTURE behavior OF transmitter IS
	SIGNAL counter : std_logic_vector(3 DOWNTO 0);
	SIGNAL pn_start : std_logic;
	SIGNAL payload : std_logic;
BEGIN
--layers
application_layer : ENTITY work.application_layer(behavior)
PORT MAP
(
	clk        => clk,
	clk_en     => clk_en,
	rst        => rst,
	up 	   => up,
	down       => down,
	display_b  => display_b,
	output     => counter
);
datalink_layer : ENTITY work.datalink_layer(behavior)
PORT MAP
(
	clk      => clk,
	clk_en   => clk_en,
	rst      => rst,
	pn_start => pn_start,
	output   => payload,
	data     => counter         
);
access_layer : ENTITY work.access_layer(behavior)
PORT MAP
(
	clk       => clk,
	clk_en    => clk_en,
	rst       => rst,
	pn_select => pn_select,
	pn_start  => pn_start,
	tx        => tx,
	data      => payload         
);
END behavior;