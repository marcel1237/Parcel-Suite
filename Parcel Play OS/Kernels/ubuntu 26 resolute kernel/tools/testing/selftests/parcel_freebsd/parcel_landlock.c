// SPDX-License-Identifier: GPL-2.0
#include <errno.h>
#include <linux/landlock.h>
#include <stdio.h>
#include <sys/syscall.h>
#include <unistd.h>

int main(void)
{
        long abi;

        puts("TAP version 13");
        puts("1..1");

#ifndef __NR_landlock_create_ruleset
        puts("ok 1 - Landlock syscall number unavailable # SKIP");
        return 4;
#else
        errno = 0;
        abi = syscall(__NR_landlock_create_ruleset, NULL, 0,
                      LANDLOCK_CREATE_RULESET_VERSION);
        if (abi >= 1) {
                printf("ok 1 - Landlock ABI is available (version %ld)\n", abi);
                return 0;
        }
        if (errno == ENOSYS || errno == EOPNOTSUPP) {
                puts("ok 1 - Landlock is unavailable # SKIP");
                return 4;
        }
        printf("not ok 1 - Landlock ABI query failed (errno %d)\n", errno);
        return 1;
#endif
}
