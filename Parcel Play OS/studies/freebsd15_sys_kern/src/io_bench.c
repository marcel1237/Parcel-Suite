/* SPDX-License-Identifier: GPL-2.0-only */
#define _GNU_SOURCE
#include <errno.h>
#include <fcntl.h>
#include <pthread.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/sendfile.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <time.h>
#include <unistd.h>

#define FILE_SIZE (64U * 1024U * 1024U)
#define BUFFER_SIZE (128U * 1024U)

struct receiver_args {
	int fd;
	size_t expected;
};

static uint64_t
now_ns(void)
{
	struct timespec ts;
	clock_gettime(CLOCK_MONOTONIC_RAW, &ts);
	return (uint64_t)ts.tv_sec * 1000000000ULL + (uint64_t)ts.tv_nsec;
}

static void *
receiver(void *opaque)
{
	struct receiver_args *args = opaque;
	char buffer[BUFFER_SIZE];
	size_t received = 0;

	while (received < args->expected) {
		ssize_t n = read(args->fd, buffer, sizeof(buffer));
		if (n <= 0)
			break;
		received += (size_t)n;
	}
	return (void *)(uintptr_t)received;
}

static int
create_source(void)
{
	char template[] = "/tmp/parcel-io-study-XXXXXX";
	char zeros[BUFFER_SIZE] = {0};
	int fd = mkstemp(template);

	if (fd < 0)
		return -1;
	unlink(template);
	for (size_t written = 0; written < FILE_SIZE; written += sizeof(zeros))
		if (write(fd, zeros, sizeof(zeros)) != (ssize_t)sizeof(zeros)) {
			close(fd);
			return -1;
		}
	lseek(fd, 0, SEEK_SET);
	return fd;
}

static int
run_transfer(int source, int use_sendfile)
{
	int sockets[2];
	pthread_t thread;
	struct receiver_args args;
	void *received;
	uint64_t start;
	uint64_t elapsed;
	size_t sent = 0;
	char buffer[BUFFER_SIZE];

	if (socketpair(AF_UNIX, SOCK_STREAM, 0, sockets) != 0)
		return 1;
	args.fd = sockets[1];
	args.expected = FILE_SIZE;
	pthread_create(&thread, NULL, receiver, &args);
	lseek(source, 0, SEEK_SET);
	start = now_ns();
	while (sent < FILE_SIZE) {
		ssize_t n;
		if (use_sendfile) {
			n = sendfile(sockets[0], source, NULL, FILE_SIZE - sent);
		} else {
			ssize_t r = read(source, buffer, sizeof(buffer));
			if (r <= 0)
				break;
			n = write(sockets[0], buffer, (size_t)r);
		}
		if (n <= 0)
			break;
		sent += (size_t)n;
	}
	shutdown(sockets[0], SHUT_WR);
	pthread_join(thread, &received);
	elapsed = now_ns() - start;
	printf("method=%s bytes=%zu received=%zu seconds=%.6f mib_s=%.2f\n",
		use_sendfile ? "sendfile" : "read-write", sent,
		(size_t)(uintptr_t)received, elapsed / 1e9,
		(FILE_SIZE / 1048576.0) / (elapsed / 1e9));
	close(sockets[0]);
	close(sockets[1]);
	return sent == FILE_SIZE && (size_t)(uintptr_t)received == FILE_SIZE ? 0 : 1;
}

int
main(void)
{
	int source = create_source();
	int result = 0;

	if (source < 0) {
		fprintf(stderr, "create source: %s\n", strerror(errno));
		return 1;
	}
	result |= run_transfer(source, 0);
	result |= run_transfer(source, 1);
	close(source);
	return result;
}

