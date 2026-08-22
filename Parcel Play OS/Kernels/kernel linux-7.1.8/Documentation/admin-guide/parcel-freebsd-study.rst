==============================
Parcel FreeBSD policy studies
==============================

FreeBSD ``sys/kern`` is used as a source of hypotheses and comparative tests,
not as a Linux compatibility layer. Internal FreeBSD files are not copied.

Translation rules
=================

* boot tracing maps to bootconfig, tracefs and ftrace;
* failure testing maps to Linux fault injection in a laboratory build;
* scheduler studies use tracepoints, cgroup/uclamp and sched_ext;
* sendfile and TLS use Linux sendfile, splice and kTLS;
* Jail and VNET isolation map to namespaces and cgroup v2;
* Capsicum-like restriction maps to seccomp, Landlock, capabilities and LSMs;
* name-cache research uses Linux dcache, RCU-walk and lookup profiling.

FreeBSD ULE, vnode, mbuf, UMA, VNET and locking internals are not portable.
Every functional patch needs a reproducible Linux problem, measurements,
selftests, VM boot, security review, licence review and documented rollback.
