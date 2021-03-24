LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY sim_siphash_main IS
END sim_siphash_main;

ARCHITECTURE rtl OF sim_siphash_main IS

SIGNAL clk : STD_LOGIC := '0';
CONSTANT clk_period : TIME := 10 ns;

BEGIN

  -- Clock process definitions
  clk_process : PROCESS
  BEGIN
    clk <= '0';
    WAIT FOR clk_period/2;
    clk <= '1';
    WAIT FOR clk_period/2;
  END PROCESS;

  -- Stimulus process
  stim_proc : PROCESS
  BEGIN
    -- hold reset state for 100 ns.
    WAIT FOR 100 ns;

    WAIT FOR clk_period * 10;

  END PROCESS;

END;

