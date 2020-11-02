library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package common is

   -- Array for channel data.
   type data_t is array(7 downto 0) of std_logic_vector(15 downto 0);

   -- Channel constants.
   constant CHANNEL_A : natural range 0 to 7 := 0;
   constant CHANNEL_B : natural range 0 to 7 := 1;
   constant CHANNEL_C : natural range 0 to 7 := 2;
   constant CHANNEL_D : natural range 0 to 7 := 3;
   constant CHANNEL_E : natural range 0 to 7 := 4;
   constant CHANNEL_F : natural range 0 to 7 := 5;
   constant CHANNEL_G : natural range 0 to 7 := 6;
   constant CHANNEL_H : natural range 0 to 7 := 7;

   -- Check, if channel flag is set.
   function isSet(el_chnl : std_logic_vector; channel : natural) return boolean;
end common;

package body common is

   -- Check, if channel flag is set.
   function isSet(el_chnl : std_logic_vector; channel : natural)
   return boolean is
   begin
      return (el_chnl(channel) = '1');
   end;
end common;