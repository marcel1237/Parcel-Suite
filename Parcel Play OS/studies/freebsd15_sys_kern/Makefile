CC ?= cc
CFLAGS ?= -O2 -g -std=c11 -Wall -Wextra -Werror
LDLIBS ?= -pthread -lm

BIN := bin
RESULTS := results

.PHONY: all test run clean

all: $(BIN)/algorithm_tests $(BIN)/scheduler_bench $(BIN)/io_bench

$(BIN) $(RESULTS):
	mkdir -p $@

$(BIN)/algorithm_tests: src/algorithm_tests.c src/algorithms.c src/algorithms.h | $(BIN)
	$(CC) $(CFLAGS) -o $@ src/algorithm_tests.c src/algorithms.c $(LDLIBS)

$(BIN)/scheduler_bench: src/scheduler_bench.c | $(BIN)
	$(CC) $(CFLAGS) -o $@ src/scheduler_bench.c $(LDLIBS)

$(BIN)/io_bench: src/io_bench.c | $(BIN)
	$(CC) $(CFLAGS) -o $@ src/io_bench.c $(LDLIBS)

test: $(BIN)/algorithm_tests
	$(BIN)/algorithm_tests

run: all | $(RESULTS)
	./run_all.sh

clean:
	rm -f $(BIN)/algorithm_tests $(BIN)/scheduler_bench $(BIN)/io_bench

