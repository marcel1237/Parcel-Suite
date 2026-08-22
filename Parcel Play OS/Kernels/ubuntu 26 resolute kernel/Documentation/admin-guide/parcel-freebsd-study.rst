==============================
Parcel FreeBSD policy studies
==============================

The Parcel Play OS project uses selected FreeBSD ``sys/kern`` components as
sources of hypotheses and comparative tests.  FreeBSD internal APIs are not a
compatibility layer for Linux and source files must not be copied wholesale.

Translation rules
=================

A proposed change must first identify an existing Linux mechanism.  The
preferred mappings are:

* boot tracing: bootconfig, tracefs, ftrace and initcall tracepoints;
* failure testing: the Linux fault-injection framework in a laboratory build;
* scheduler policy: scheduler tracepoints and sched_ext when available;
* sendfile and TLS: the Linux sendfile, splice and kTLS implementations;
* Jail and VNET isolation: namespaces and cgroup v2;
* Capsicum-like restriction: seccomp, Landlock, capabilities and an LSM;
* name cache research: Linux dcache, RCU-walk and pathname lookup profiling.

No change is justified only because FreeBSD implements the concept
differently.  A patch needs a reproducible Linux problem and before/after
measurements.

Production and laboratory kernels
=================================

Destructive diagnostic options belong to a separate laboratory flavour.
Fault injection, KASAN, KCSAN and KCOV must not be enabled automatically in a
production or gaming flavour.  Laboratory testing must use a disposable VM
and a recoverable disk image.

Scheduler studies
=================

FreeBSD ULE runqueues and locking are not portable to Linux.  Scheduler work
starts with workload measurement and cgroup/uclamp policy.  If sched_ext is
available, an eBPF policy is preferred because failure returns tasks to the
built-in scheduler.  Changes to the core scheduler are a last resort.

Small algorithms
================

An isolated algorithm needs a real in-kernel consumer before integration.
Userspace is preferred for policy and tuning.  Kernel implementations must
avoid floating point, define units and overflow behaviour, use Linux helpers,
and include deterministic KUnit tests.

Licensing
=========

Every derived fragment requires a per-file licence review.  Copyright notices
and attribution must be retained when required.  Independent implementation
from documented behaviour and tests is preferred to copying internal code.

Acceptance gates
================

A functional patch requires a fixed Ubuntu baseline, clean build, relevant
selftests, VM boot, security review, performance statistics and a documented
rollback.  The official Ubuntu kernel remains installed as a boot fallback.
An experiment that cannot beat or clarify the baseline remains outside the
