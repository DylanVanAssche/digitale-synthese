--***************************************
--* TITLE: Receiver (receiver) 		*
--* TYPE: Top File			*
--* AUTHOR: Dylan Van Assche 		*
--* DATE: 9/12/2017 			*
--***************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- Connect all the layers into 1 VHDL file.
--2)Principle:
-- Connect every layer API.
--3)Inputs:
-- rx, pn_select, rst, clk, clk_en
--4)Outputs:
-- display_b
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY receiver IS
	PORT
	(
		clk		: IN std_logic;
		rst		: IN std_logic;
		rx		: IN std_logic;
		pn_select	: IN std_logic_vector(1 DOWNTO 0);
		display_b	: OUT std_logic_vector(6 DOWNTO 0)
	);
END receiver ;
ARCHITECTURE behavior OF receiver IS
	SIGNAL bitsample	: std_logic;
	SIGNAL databit		: std_logic;
	SIGNAL clk_en		: std_logic;
	SIGNAL preamble		: std_logic_vector(6 DOWNTO 0);
	SIGNAL data		: std_logic_vector(3 DOWNTO 0); -- received number from transmitter
BEGIN
--layers
nco_rx : ENTITY work.nco_rx(behavior)
PORT MAP
(
	clk    => clk,
	rst    => rst,
	clk_en => clk_en
);
application_layer : ENTITY work.application_layer(behavior)
PORT MAP
(
	clk       => clk,
	clk_en    => clk_en,
	rst       => rst,
	bitsample => bitsample,
	preamble  => preamble,
	data_in   => data,
	display_b => display_b
);
datalink_layer : ENTITY work.datashiftreg(behavior) -- datalink layer is only 1 component
PORT MAP
(
	clk        => clk,
	clk_en     => clk_en,
	rst        => rst,
	bitsample  => bitsample,
	databit    => databit,
	preamble   => preamble,
	data       => data 
);
access_layer : ENTITY work.access_layer(behavior)
PORT MAP
(
	clk		=> clk,
	clk_en		=> clk_en,
	rst		=> rst,
	sdi_spread	=> rx,
	pn_select	=> pn_select,
	bitsample_out	=> bitsample,
	databit		=> databit
);
END behavior;