#pragma once

uint8_t file_payload[BUFFER_SIZE];
size_t file_payload_length = 0;

static inline void read_file(const char* filename) {
  FILE* fileptr = fopen(filename, "rb");
  fseek(fileptr, 0, SEEK_END);
  file_payload_length = ftell(fileptr);
  if (file_payload_length > BUFFER_SIZE) { file_payload_length = BUFFER_SIZE; }
  rewind(fileptr);
  fread(file_payload, file_payload_length, 1, fileptr);
  fclose(fileptr);
}
