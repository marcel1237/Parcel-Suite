/* SPDX-License-Identifier: GPL-2.0-only */
#include "algorithms.h"

#include <assert.h>
#include <math.h>
#include <stdio.h>

static void
test_pid(void)
{
	struct study_pid pid;
	int first;
	int second;

	study_pid_init(&pid, 100, 50, 2, 5, 2);
	first = study_pid_step(&pid, 80);
	second = study_pid_step(&pid, 90);
	assert(first > 0);
	assert(second < first);
	for (int i = 0; i < 100; i++)
		(void)study_pid_step(&pid, 0);
	assert(pid.integral == 50);
}

static void
test_window(void)
{
	const uint64_t values[] = {42, 7, 99, 15, 63};

	assert(study_window_min(values, 5) == 7);
	assert(study_window_max(values, 5) == 99);
}

static void
test_regression(void)
{
	struct study_regression reg = {0};

	for (int i = 0; i < 1000; i++)
		study_regression_add(&reg, (double)i, 3.0 * i + 11.0);
	assert(fabs(study_regression_slope(&reg) - 3.0) < 1e-9);
}

int
main(void)
{
	test_pid();
	test_window();
	test_regression();
	puts("algorithm_tests: PASS");
	return 0;
}

