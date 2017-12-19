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
ENTITY receiver_hw IS
	PORT
	(
		clk		: IN std_logic;
		rst_b		: IN std_logic;
		rx		: IN std_logic;
		pn_select_b_SW0	: IN std_logic;
		pn_select_b_SW1	: IN std_logic;
		display_b_SEG_A : OUT std_logic;
		display_b_SEG_B : OUT std_logic;
		display_b_SEG_C : OUT std_logic;
		display_b_SEG_D : OUT std_logic;
		display_b_SEG_E : OUT std_logic;
		display_b_SEG_F : OUT std_logic;
		display_b_SEG_G : OUT std_logic;
		display_b_SEG_DP: OUT std_logic
	);
END receiver_hw;
ARCHITECTURE behavior OF receiver_hw IS
	SIGNAL bitsample	: std_logic;
	SIGNAL databit		: std_logic;
	SIGNAL rst		: std_logic;
	SIGNAL clk_en		: std_logic;
	SIGNAL preamble		: std_logic_vector(6 DOWNTO 0);
	SIGNAL data		: std_logic_vector(3 DOWNTO 0); -- received number from transmitter
	SIGNAL display_b	: std_logic_vector(6 DOWNTO 0);
	SIGNAL pn_select: std_logic_vector(1 DOWNTO 0);
BEGIN
-- display outputs
display_b_SEG_A <= display_b(6);
display_b_SEG_B <= display_b(5);
display_b_SEG_C <= display_b(4);
display_b_SEG_D <= display_b(3);
display_b_SEG_E <= display_b(2);
display_b_SEG_F <= display_b(1);
display_b_SEG_G <= display_b(0);
display_b_SEG_DP <= '1'; -- turn DOT off
-- dipswitch inputs
pn_select <= NOT(pn_select_b_SW1) & NOT(pn_select_b_SW0);
-- buttons inputs
rst <= NOT(rst_b);
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