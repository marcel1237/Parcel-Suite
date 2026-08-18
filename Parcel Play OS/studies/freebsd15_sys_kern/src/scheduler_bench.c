/* SPDX-License-Identifier: GPL-2.0-only */
#define _GNU_SOURCE
#include <errno.h>
#include <pthread.h>
#include <sched.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#define ITERATIONS 20000

struct shared {
	pthread_mutex_t lock;
	pthread_cond_t cond;
	int generation;
	int acknowledged;
	int stop;
	uint64_t sent_ns;
	uint64_t latency[ITERATIONS];
};

static uint64_t
now_ns(void)
{
	struct timespec ts;
	clock_gettime(CLOCK_MONOTONIC_RAW, &ts);
	return (uint64_t)ts.tv_sec * 1000000000ULL + (uint64_t)ts.tv_nsec;
}

static int
compare_u64(const void *a, const void *b)
{
	const uint64_t aa = *(const uint64_t *)a;
	const uint64_t bb = *(const uint64_t *)b;
	return (aa > bb) - (aa < bb);
}

static void *
worker(void *opaque)
{
	struct shared *s = opaque;
	int seen = 0;

	pthread_mutex_lock(&s->lock);
	while (!s->stop) {
		while (s->generation == seen && !s->stop)
			pthread_cond_wait(&s->cond, &s->lock);
		if (s->stop)
			break;
		seen = s->generation;
		s->latency[seen - 1] = now_ns() - s->sent_ns;
		s->acknowledged = seen;
		pthread_cond_signal(&s->cond);
	}
	pthread_mutex_unlock(&s->lock);
	return NULL;
}

int
main(int argc, char **argv)
{
	struct shared s = {
		.lock = PTHREAD_MUTEX_INITIALIZER,
		.cond = PTHREAD_COND_INITIALIZER,
	};
	struct sched_param param = {0};
	pthread_t thread;
	int policy = SCHED_OTHER;
	const char *name = "other";
	double total = 0.0;

	if (argc == 2 && strcmp(argv[1], "batch") == 0) {
		policy = SCHED_BATCH;
		name = "batch";
	} else if (argc != 1 && !(argc == 2 && strcmp(argv[1], "other") == 0)) {
		fprintf(stderr, "usage: %s [other|batch]\n", argv[0]);
		return 2;
	}
	if (sched_setscheduler(0, policy, &param) != 0) {
		fprintf(stderr, "sched_setscheduler(%s): %s\n", name,
			strerror(errno));
		return 1;
	}
	if (pthread_create(&thread, NULL, worker, &s) != 0)
		return 1;
	for (int i = 1; i <= ITERATIONS; i++) {
		pthread_mutex_lock(&s.lock);
		s.sent_ns = now_ns();
		s.generation = i;
		pthread_cond_signal(&s.cond);
		while (s.acknowledged != i)
			pthread_cond_wait(&s.cond, &s.lock);
		pthread_mutex_unlock(&s.lock);
	}
	pthread_mutex_lock(&s.lock);
	s.stop = 1;
	pthread_cond_signal(&s.cond);
	pthread_mutex_unlock(&s.lock);
	pthread_join(thread, NULL);
	qsort(s.latency, ITERATIONS, sizeof(s.latency[0]), compare_u64);
	for (int i = 0; i < ITERATIONS; i++)
		total += (double)s.latency[i];
	printf("policy=%s iterations=%d mean_us=%.3f p50_us=%.3f "
		"p95_us=%.3f p99_us=%.3f max_us=%.3f\n", name, ITERATIONS,
		total / ITERATIONS / 1000.0,
		s.latency[ITERATIONS / 2] / 1000.0,
		s.latency[(ITERATIONS * 95) / 100] / 1000.0,
		s.latency[(ITERATIONS * 99) / 100] / 1000.0,
		s.latency[ITERATIONS - 1] / 1000.0);
	return 0;
}

