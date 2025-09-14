#ifndef OPUS_H
#define OPUS_H

// Minimal opus header for Android build
typedef struct OpusEncoder OpusEncoder;
typedef struct OpusDecoder OpusDecoder;

#define OPUS_OK 0
#define OPUS_BAD_ARG -1
#define OPUS_BUFFER_TOO_SMALL -2
#define OPUS_INTERNAL_ERROR -3
#define OPUS_INVALID_PACKET -4
#define OPUS_UNIMPLEMENTED -5
#define OPUS_INVALID_STATE -6
#define OPUS_ALLOC_FAIL -7

#define OPUS_APPLICATION_VOIP 2048
#define OPUS_APPLICATION_AUDIO 2049
#define OPUS_APPLICATION_RESTRICTED_LOWDELAY 2051

#define OPUS_SET_BITRATE_REQUEST 4002
#define OPUS_GET_BITRATE_REQUEST 4003

int opus_encode(OpusEncoder *st, const short *pcm, int frame_size, unsigned char *data, int max_data_bytes);
int opus_decode(OpusDecoder *st, const unsigned char *data, int len, short *pcm, int frame_size, int decode_fec);

OpusEncoder *opus_encoder_create(int Fs, int channels, int application, int *error);
void opus_encoder_destroy(OpusEncoder *st);

OpusDecoder *opus_decoder_create(int Fs, int channels, int *error);
void opus_decoder_destroy(OpusDecoder *st);

#endif
