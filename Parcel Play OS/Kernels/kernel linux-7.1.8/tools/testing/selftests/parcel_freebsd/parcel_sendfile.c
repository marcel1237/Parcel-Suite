// SPDX-License-Identifier: GPL-2.0
#define _GNU_SOURCE
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/sendfile.h>
#include <sys/socket.h>
#include <unistd.h>
#define TEST_SIZE 16384
static int fail(const char *op) { fprintf(stderr, "not ok 1 - %s: %s\n", op, strerror(errno)); return 1; }
int main(void)
{
	unsigned char src[TEST_SIZE], dst[TEST_SIZE]; char path[] = "/tmp/parcel-sendfile-XXXXXX";
	size_t done = 0, i; off_t off = 0; int s[2], fd; ssize_t ret;
	puts("TAP version 13"); puts("1..1");
	for (i = 0; i < TEST_SIZE; i++) src[i] = (unsigned char)((i * 31U + 7U) & 0xffU);
	fd = mkstemp(path); if (fd < 0) return fail("mkstemp"); unlink(path);
	if (write(fd, src, sizeof(src)) != (ssize_t)sizeof(src)) return fail("write source");
	if (socketpair(AF_UNIX, SOCK_STREAM, 0, s) < 0) return fail("socketpair");
	if (sendfile(s[0], fd, &off, sizeof(src)) != (ssize_t)sizeof(src)) return fail("sendfile");
	while (done < sizeof(dst)) { ret = read(s[1], dst + done, sizeof(dst) - done); if (ret <= 0) return fail("read socket"); done += (size_t)ret; }
	close(s[0]); close(s[1]); close(fd);
	if (memcmp(src, dst, sizeof(src))) { errno = EIO; return fail("data comparison"); }
	puts("ok 1 - sendfile preserves data over an AF_UNIX socket"); return 0;
}
