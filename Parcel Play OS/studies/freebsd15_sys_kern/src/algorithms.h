/* SPDX-License-Identifier: GPL-2.0-only */
#ifndef PARCEL_STUDY_ALGORITHMS_H
#define PARCEL_STUDY_ALGORITHMS_H

#include <stddef.h>
#include <stdint.h>

struct study_pid {
	int setpoint;
	int integral_bound;
	int kp_divisor;
	int ki_divisor;
	int kd_divisor;
	int error;
	int previous_error;
	int integral;
};

void study_pid_init(struct study_pid *pid, int setpoint, int bound,
	int kp_divisor, int ki_divisor, int kd_divisor);
int study_pid_step(struct study_pid *pid, int input);

uint64_t study_window_min(const uint64_t *values, size_t count);
uint64_t study_window_max(const uint64_t *values, size_t count);

struct study_regression {
	size_t count;
	double mean_x;
	double mean_y;
	double covariance;
	double variance_x;
};

void study_regression_add(struct study_regression *reg, double x, double y);
double study_regression_slope(const struct study_regression *reg);

#endif

