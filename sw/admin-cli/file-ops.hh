#pragma once

uint8_t file_payload[BUFFER_SIZE];
size_t file_payload_length = 0;

static inline ssize_t read_file(const char* filename) {
  FILE* fileptr = fopen(filename, "rb");
  if (!fileptr) {
    fprintf(stderr, "ERROR file not found\n");
    return -1;
  }
  fseek(fileptr, 0, SEEK_END);
  file_payload_length = ftell(fileptr);
  if (file_payload_length > BUFFER_SIZE) { file_payload_length = BUFFER_SIZE; }
  rewind(fileptr);
  fread(file_payload, file_payload_length, 1, fileptr);
  fclose(fileptr);
  return 0;
}

static inline void fake_file(const char* payload, size_t payload_length) {
  memcpy(file_payload, payload, payload_length);
  file_payload_length = payload_length;
}
