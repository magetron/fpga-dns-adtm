/* 
 * Based upon the work of Grant P. Maizels and Ross Williams.
 * Their original licence details are in the header file.
 * This amalgamation is the work of James Bensley Copyright (c) 2018.
 */ 


#include <stdio.h>     // EOF, FILE, fclose(), fprintf(), fscanf(), perror(), printf(), stderr, stdin
#include <stdlib.h>    // calloc(), exit()
#include <inttypes.h>  // intN_t, PRIxN, SCNxN, uintN_t
#include <string.h>    // memset()
#include <bitset>
#include <iostream>
#include <arpa/inet.h>
#include <algorithm>

/*
 * The original license details for the work by Grant P. Maizels and
 * Ross Williams, code amalgamation by James Bensley Copyright (c) 2018.
 *
 ******************************************************************************
 * Copyright (C) 2000 Grant P. Maizels. All rights reserved
 * This software is copyrighted work licensed under the terms of the
 * GNU General Public License. Please consult
 * http://www.gnu.org/licenses/licenses.html#GPL for details.
 * Version 1.0 last update 19Nov2001
 ******************************************************************************
 *
 * Author : Ross Williams (ross@guest.adelaide.edu.au.).
 * Date   : 3 June 1993.
 * Status : Public domain.
 *
 * Description : This is the header (.h) file for the reference
 * implementation of the Rocksoft^tm Model CRC Algorithm. For more
 * information on the Rocksoft^tm Model CRC Algorithm, see the document
 * titled "A Painless Guide to CRC Error Detection Algorithms" by Ross
 * Williams (ross@guest.adelaide.edu.au.). This document is likely to be in
 * "ftp.adelaide.edu.au/pub/rocksoft".
 *
 * Note: Rocksoft is a trademark of Rocksoft Pty Ltd, Adelaide, Australia.
 *
 ******************************************************************************
 */


#ifndef _CRC32_H_
#define _CRC32_H_


#define MAX_FRAME_SIZE 10000
#define BITMASK(X) (1L << (X))


/* CRC Model Abstract Type */
/* ----------------------- */
/* The following type stores the context of an executing instance of the  */
/* model algorithm. Most of the fields are model parameters which must be */
/* set before the first initializing call to cm_ini.                      */
typedef struct {
    uint32_t cm_width;   /* Parameter: Width in bits [8,32].       */
    uint32_t cm_poly;    /* Parameter: The algorithm's polynomial. */
    uint32_t cm_init;    /* Parameter: Initial register value.     */
    uint8_t  cm_refin;   /* Parameter: Reflect input bytes?        */
    uint8_t  cm_refot;   /* Parameter: Reflect output CRC?         */
    uint32_t cm_xorot;   /* Parameter: XOR this to output CRC.     */
    uint32_t cm_reg;     /* Context: Context during execution.     */
} cm_t;

typedef cm_t *p_cm_t;


/* Functions That Implement The Model */
/* ---------------------------------- */
/* The following functions animate the cm_t abstraction. */

static void cm_ini (p_cm_t p_cm);
/* Initializes the argument CRC model instance.          */
/* All parameter fields must be set before calling this. */

static void cm_nxt (p_cm_t p_cm, uint32_t ch);
/* Processes a single message byte [0,255]. */

static void cm_blk (p_cm_t p_cm, uint8_t *blk_adr, uint32_t blk_len);
/* Processes a block of message bytes. */

static uint32_t cm_crc (p_cm_t p_cm);
/* Returns the CRC value for the message bytes processed so far. */


/* Functions For Table Calculation */
/* ------------------------------- */
/* The following function can be used to calculate a CRC lookup table.        */
/* It can also be used at run-time to create or check static tables.          */

static uint32_t cm_tab (p_cm_t p_cm, uint32_t index);
/* Returns the i'th entry for the lookup table for the specified algorithm.   */
/* The function examines the fields cm_width, cm_poly, cm_refin, and the      */
/* argument table index in the range [0,255] and returns the table entry in   */
/* the bottom cm_width bytes of the return value.                             */


static uint32_t reflect (uint32_t v, uint32_t b);
/* Returns the value v with the bottom b [0,32] bits reflected. */
/* Example: reflect(0x3e23L,3) == 0x3e26                        */

static uint32_t widmask (p_cm_t);
/* Returns a longword whose value is (2^p_cm->cm_width)-1.     */
/* The trick is to do this portably (e.g. without doing <<32). */


#endif  // _CRC32_H_

int32_t main(uint16_t argc, char *argv[]) {

  cm_t cm;
  p_cm_t p_cm = &cm;
  memset(p_cm, 0, sizeof(cm));

  p_cm->cm_width  = 32;
  p_cm->cm_poly   = 0x04C11DB7;
  p_cm->cm_init   = 0xFFFFFFFF;
  p_cm->cm_refin  = 1;
  p_cm->cm_refot  = 1;
  p_cm->cm_xorot  = 0xFFFFFFFF;

  FILE *fp = NULL;

  static uint16_t idx = 1;

  do {

    if (argc > 1 && (fp=fopen(argv[idx], "r")) == NULL) {
       fprintf(stderr, "%s: can't open %s\n", argv[0], argv[idx]);
       continue;
    }

    cm_ini(p_cm);

    printf("%s: ", argv[idx]);

    static uint32_t file_ret   = 0;
    static uint16_t frame_sz   = 0;
    static uint8_t *crc_buffer = NULL;

    crc_buffer = (uint8_t*)calloc(MAX_FRAME_SIZE, 1);

    if (crc_buffer == NULL) {
      printf("Failed to calloc() CRC buffer!\n");
      exit(-1);
    }

    while (file_ret != EOF && (frame_sz < MAX_FRAME_SIZE)) {

      file_ret = fscanf(fp, "%" SCNx8, crc_buffer + frame_sz);

      if (file_ret == EOF) break;
      if (file_ret <= 0) {
        perror("Error reading packet file");
        exit(-1);
      }

      printf("0x%" PRIx8 " ", crc_buffer[frame_sz]);
      frame_sz += 1;

    }

    printf ("\nFile length: %u bytes\n", frame_sz);

    if (fclose(fp) != 0) {
      perror("Error closing file");
      continue;
    }

    int16_t max = frame_sz;

    // If the frame has a 4 byte FCS value at the end,
    // exclude this from the CRC calculation:
    int8_t has_crc = 1;
    if (has_crc) max -= 4;

    uint8_t j;
    for (j = 0; j < max; j += 1) {
      cm_nxt(p_cm, crc_buffer[j]);
    }

    uint32_t crc = cm_crc(p_cm) & 0xffffffff;
    uint32_t frame_fcs = (crc_buffer[frame_sz - 1] << 24) |
                         (crc_buffer[frame_sz - 2] << 16) |
                         (crc_buffer[frame_sz - 3] << 8) |
                          crc_buffer[frame_sz - 4];

    if (has_crc) {
      printf("Calculated CRC: 0x%x, Frame FCS: 0x%x\n", crc, frame_fcs);
      (crc == frame_fcs) ? printf("Matched!\n") : printf("Not matched!\n");
    } else {
      printf("Calculated CRC: 0x%x\n", crc);
      printf("Calculated CRC wire: 0x%x\n", htonl(crc));
      std::bitset<32> crcbs(crc);
      std::cout << crcbs << std::endl;
      auto str = crcbs.to_string();
      std::reverse(str.begin(), str.end());
      std::cout << str << std::endl;

      std::bitset<32> crcwbs(htonl(crc));
      std::cout << crcwbs << std::endl;
      str = crcwbs.to_string();
      std::reverse(str.begin(), str.end());
      std::cout << str << std::endl;
    }

  } while (++idx < argc);

  exit(0);
}


static uint32_t reflect(uint32_t v, uint32_t b) {

  static int   i;
  static uint32_t t;

  t = v;

  for (i=0; i < b; i++) {

    if (t & 1L) {
       v|=  BITMASK((b - 1) - i);
    } else {
       v&= ~BITMASK((b - 1) - i);
    }

    t>>=1;

  }

  return v;

}


static uint32_t widmask(p_cm_t p_cm) {

  return (((1L << (p_cm->cm_width - 1)) - 1L) << 1) | 1L;

}


static void cm_ini(p_cm_t p_cm) {

  p_cm->cm_reg = p_cm->cm_init;

}


static void cm_nxt(p_cm_t p_cm, uint32_t ch) {

  static int   i;
  static uint32_t uch, topbit;

  uch    = ch;
  topbit = BITMASK(p_cm->cm_width - 1);

  if (p_cm->cm_refin) uch = reflect(uch, 8);

  p_cm->cm_reg ^= (uch << (p_cm->cm_width - 8));

  for (i=0; i < 8; i++) {

    if (p_cm->cm_reg & topbit) {
      p_cm->cm_reg = (p_cm->cm_reg << 1) ^ p_cm->cm_poly;
    } else {
       p_cm->cm_reg <<= 1;
    }

    p_cm->cm_reg &= widmask(p_cm);

  }

}


static void cm_blk(p_cm_t p_cm, uint8_t *blk_adr, uint32_t blk_len) {

  while (blk_len--) cm_nxt(p_cm, *blk_adr++);

}


static uint32_t cm_crc(p_cm_t p_cm) {

  if (p_cm->cm_refot) {
    return p_cm->cm_xorot ^ reflect(p_cm->cm_reg, p_cm->cm_width);
  } else {
    return p_cm->cm_xorot ^ p_cm->cm_reg;
  }

}


static uint32_t cm_tab(p_cm_t p_cm, uint32_t index) {

  static uint8_t  i;
  static uint32_t r, topbit, inbyte;

  topbit = BITMASK(p_cm->cm_width - 1);
  inbyte = index;

  if (p_cm->cm_refin) inbyte = reflect(inbyte, 8);

  r = inbyte << (p_cm->cm_width - 8);

  for (i=0; i < 8; i++) {

    if (r & topbit) {
      r = (r << 1) ^ p_cm->cm_poly;
    } else {
       r <<= 1;
     }
  }

  if (p_cm->cm_refin) r = reflect(r, p_cm->cm_width);

  return r & widmask(p_cm);

}

