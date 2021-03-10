#pragma once
#include <ctype.h>
#include <cstring>

char* stripwhite (char* string) {
   char* s;
   for (s = string; isspace(*s); s++);
   if (*s == 0) return (s);

   char* t = s + strlen(s) - 1;
   while (t > s && isspace (*t)) t--;
   *++t = '\0';

   return s;
}

char *dupstr (const char* s)
{
   auto* r = reinterpret_cast<char*>(malloc(strlen(s) + 1));
   strcpy(r, s);
   return r;
}
