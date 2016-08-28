/*
 * This is an OpenSSL-compatible implementation of the RSA Data Security,
 * Inc. MD4 Message-Digest Algorithm.
 *
 * Written by Solar Designer <solar@openwall.com> in 2001, and placed in
 * the public domain.  See md4.c for more information.
 */

#ifndef __MD4_H
#define __MD4_H
#include <sys/types.h>

#define	MD4_RESULTLEN (128/8)

struct md4_context {
	u_int32_t lo, hi;
	u_int32_t a, b, c, d;
	unsigned char buffer[64];
	u_int32_t block[MD4_RESULTLEN];
};

 void md4_init(struct md4_context *ctx);
 void md4_update(struct md4_context *ctx, const unsigned char *data, size_t size);
 void md4_final(struct md4_context *ctx, unsigned char result[MD4_RESULTLEN]);


#endif
