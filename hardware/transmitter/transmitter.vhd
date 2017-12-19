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
ENTITY transmitter_hw IS
	PORT
	(
		clk		: IN std_logic;
		rst_b		: IN std_logic;
		up_b		: IN std_logic;
		down_b		: IN std_logic;
		pn_select_b_SW0	: IN std_logic;
		pn_select_b_SW1	: IN std_logic;
		display_b_SEG_A : OUT std_logic;
		display_b_SEG_B : OUT std_logic;
		display_b_SEG_C : OUT std_logic;
		display_b_SEG_D : OUT std_logic;
		display_b_SEG_E : OUT std_logic;
		display_b_SEG_F : OUT std_logic;
		display_b_SEG_G : OUT std_logic;
		display_b_SEG_DP: OUT std_logic;
		tx		: OUT std_logic
	);
END transmitter_hw ;
ARCHITECTURE behavior OF transmitter_hw IS
	SIGNAL pn_start	: std_logic;
	SIGNAL payload	: std_logic;
	SIGNAL clk_en	: std_logic := '1'; -- allow reset without NCO
	SIGNAL rst	: std_logic;
	SIGNAL up	: std_logic;
	SIGNAL down	: std_logic;
	SIGNAL counter	: std_logic_vector(3 DOWNTO 0);
	SIGNAL display_b: std_logic_vector(6 DOWNTO 0);
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
up <= NOT(up_b);
down <= NOT(down_b);
--layers
nco_tx : ENTITY work.nco_tx(behavior)
PORT MAP
(
	clk    => clk,
	rst    => rst,
	clk_en => clk_en
);
application_layer_tx : ENTITY work.application_layer_tx(behavior)
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
datalink_layer_tx : ENTITY work.datalink_layer_tx(behavior)
PORT MAP
(
	clk      => clk,
	clk_en   => clk_en,
	rst      => rst,
	pn_start => pn_start,
	output   => payload,
	data     => counter         
);
access_layer_tx : ENTITY work.access_layer_tx(behavior)
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