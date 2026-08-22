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

static int fail(const char *operation)
{
        fprintf(stderr, "not ok 1 - %s: %s\n", operation, strerror(errno));
        return 1;
}

int main(void)
{
        unsigned char source[TEST_SIZE];
        unsigned char received[TEST_SIZE];
        char path[] = "/tmp/parcel-sendfile-XXXXXX";
        size_t done = 0;
        off_t offset = 0;
        int sockets[2] = { -1, -1 };
        int file = -1;
        ssize_t ret;
        size_t i;

        puts("TAP version 13");
        puts("1..1");

        for (i = 0; i < TEST_SIZE; i++)
                source[i] = (unsigned char)((i * 31U + 7U) & 0xffU);

        file = mkstemp(path);
        if (file < 0)
                return fail("mkstemp");
        unlink(path);

        ret = write(file, source, sizeof(source));
        if (ret != (ssize_t)sizeof(source)) {
                close(file);
                return fail("write source");
        }
        if (socketpair(AF_UNIX, SOCK_STREAM, 0, sockets) < 0) {
                close(file);
                return fail("socketpair");
        }

        ret = sendfile(sockets[0], file, &offset, sizeof(source));
        if (ret != (ssize_t)sizeof(source)) {
                close(sockets[0]);
                close(sockets[1]);
                close(file);
                return fail("sendfile");
        }

        while (done < sizeof(received)) {
                ret = read(sockets[1], received + done,
                           sizeof(received) - done);
                if (ret <= 0) {
                        close(sockets[0]);
                        close(sockets[1]);
                        close(file);
                        return fail("read socket");
                }
                done += (size_t)ret;
        }

        close(sockets[0]);
        close(sockets[1]);
        close(file);
        if (memcmp(source, received, sizeof(source)) != 0) {
                errno = EIO;
                return fail("data comparison");
        }

        puts("ok 1 - sendfile preserves data over an AF_UNIX socket");
        return 0;
}
