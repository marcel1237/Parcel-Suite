/* SPDX-License-Identifier: GPL-2.0-only */
/*
 * Independent userspace study of generic algorithms observed in
 * FreeBSD sys/kern/subr_pidctrl.c, subr_filter.c and subr_clockcalib.c.
 * This is not a kernel port and intentionally uses no FreeBSD kernel API.
 */
#include "algorithms.h"

#include <limits.h>
#include <string.h>

static int
clamp_int(long long value, int low, int high)
{
	if (value < low)
		return low;
	if (value > high)
		return high;
	return (int)value;
}

void
study_pid_init(struct study_pid *pid, int setpoint, int bound,
	int kp_divisor, int ki_divisor, int kd_divisor)
{
	memset(pid, 0, sizeof(*pid));
	pid->setpoint = setpoint;
	pid->integral_bound = bound > 0 ? bound : INT_MAX;
	pid->kp_divisor = kp_divisor > 0 ? kp_divisor : 1;
	pid->ki_divisor = ki_divisor > 0 ? ki_divisor : 1;
	pid->kd_divisor = kd_divisor > 0 ? kd_divisor : 1;
}

int
study_pid_step(struct study_pid *pid, int input)
{
	long long next_integral;
	long long output;

	pid->previous_error = pid->error;
	pid->error = pid->setpoint - input;
	next_integral = (long long)pid->integral + pid->error;
	pid->integral = clamp_int(next_integral, -pid->integral_bound,
		pid->integral_bound);
	output = pid->error / pid->kp_divisor;
	output += pid->integral / pid->ki_divisor;
	output += (pid->error - pid->previous_error) / pid->kd_divisor;
	return clamp_int(output, INT_MIN, INT_MAX);
}

uint64_t
study_window_min(const uint64_t *values, size_t count)
{
	size_t i;
	uint64_t result = UINT64_MAX;

	for (i = 0; i < count; i++)
		if (values[i] < result)
			result = values[i];
	return result;
}

uint64_t
study_window_max(const uint64_t *values, size_t count)
{
	size_t i;
	uint64_t result = 0;

	for (i = 0; i < count; i++)
		if (values[i] > result)
			result = values[i];
	return result;
}

void
study_regression_add(struct study_regression *reg, double x, double y)
{
	double dx;
	double dy;
	double n;

	reg->count++;
	n = (double)reg->count;
	dx = x - reg->mean_x;
	reg->mean_x += dx / n;
	dy = y - reg->mean_y;
	reg->mean_y += dy / n;
	reg->variance_x += dx * (x - reg->mean_x);
	reg->covariance += dx * (y - reg->mean_y);
}

double
study_regression_slope(const struct study_regression *reg)
{
	if (reg->count < 2 || reg->variance_x == 0.0)
		return 0.0;
	return reg->covariance / reg->variance_x;
}

