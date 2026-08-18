Summary: The Linux kernel (the core of the Linux operating system).
Name: kernel
%define kversion 2.2.5
%define pcmciaver 3.0.9
%define ibcsver 2.1-981105
Version: %{kversion}
Release: 23cl
Serial: 1
%define KVERREL %{PACKAGE_VERSION}-%{PACKAGE_RELEASE}
Copyright: GPL
Group: System Environment/Kernel
ExclusiveArch: i386 i586 i686 alpha sparc sparc64
ExclusiveOS: Linux
Obsoletes: kernel-modules, kernel-sparc

Source0: ftp://ftp.kernel.org/pub/linux/kernel/v2.2/linux-%{kversion}.tar.bz2
Source1: ftp://hyper.stanford.edu/pub/pcmcia/pcmcia-cs-%{pcmciaver}.tar.gz
Source2: ftp://tsx-11.mit.edu/pub/linux/BETA/ibcs2/ibcs-%{ibcsver}.tar.gz
Source3: linux-2.2.4-DAC960.tar.gz
Source4: README.kernel-sources

Source10: pcmcia-cs-2.8.8-network.script
Source11: module-info
Source12: installkernel
Source13: rhkmvtag.c
Source14: kernel-2.2-BuildASM.sh

Source20: kernel-2.2-i386.config
Source21: kernel-2.2-i386-smp.config
Source22: kernel-2.2-i386-BOOT.config
Source23: kernel-2.2-alpha.config
Source24: kernel-2.2-alpha-smp.config
Source25: kernel-2.2-sparc.config
Source26: kernel-2.2-sparc-smp.config
Source27: kernel-2.2-sparc64.config
Source28: kernel-2.2-sparc64-smp.config
Source29: kernel-2.2-i686.config
Source30: kernel-2.2-i686-smp.config
Source31: kernel-2.2-alpha-BOOT.config
Source32: kernel-2.2-sparc-BOOT.config
Source33: kernel-2.2-sparc64-BOOT.config
Source34: kernel-2.2-i586.config
Source35: kernel-2.2-i586-smp.config

Patch0: linux-2.2.5-sparc.patch
Patch1: aic7xxx-5.1.16-2.2.5.patch.gz
Patch2: i386-2.2.3-compression.patch
Patch3: linux-2.2.5-ramdisk.patch
Patch4: linux-2.2.4-DAC960.patch
Patch5: linux-2.2.5-accessSuSv2.patch
Patch6: smart2-0.9.9-for-2.2.3.patch
Patch7: fdset-2.2.4.diff
Patch8: nfsd-2.2.5-file.patch
Patch9: nfsd-2.2.5-1.patch
Patch10: linux-2.2.3-tlan.patch
Patch11: linux-2.2.5-defrag.patch
Patch14: linux-2.2.5-alpha-smp.patch
Patch15: linux-2.2.5-nohang.patch
Patch16: linux-2.2.5-pci2000.patch
Patch17: linux-2.2.5-alan.patch
Patch18: linux-2.2.5-sparc64-aic.patch
Patch19: linux-2.2.5-raid-0.90-B.patch
Patch20: linux-2.2.5-alan2.patch
Patch21: linux-2.2.5-aarp.patch
Patch23: linux-2.2.5-dac960include.patch
Patch24: linux-2.2.5-tokenring.patch
Patch25: kernel-2.2.6-alpha.patch
Patch26: kernel-2.2.6-ftruncate.patch
Patch27: kernel-2.2.6-mmap.patch
Patch28: kernel-2.2.6-shm.patch
Patch29: kernel-2.2.6-x86.patch
Patch30: linux-2.2.5-networking.patch
Patch31: linux-2.2.5-silly.patch
Patch32: linux-2.2.5-alpha.patch
Patch33: linux-2.2.5-alphasem.patch
Patch34: linux-2.2.6-nbd.patch
Patch35: megaraid-1.0.0.patch
Patch36: linux-2.2.5-ipv4-DoS-fix.patch

Patch40: ibcs-2.1-rh.patch
Patch41: pcmcia-cs-%{pcmciaver}-script.patch

# Conectiva patches
Patch50: linux-2.2.10-loopback-mtu.patch
Patch51: linux-2.2.10-scsi-spinlocks.patch

BuildRoot: /var/tmp/kernel-%{KVERREL}-root
Provides: module-info
Autoreqprov: no
Requires: initscripts >= 3.64

%package source
Requires: kernel-headers = %{kversion}
Summary: The source code for the Linux kernel.
Group: Development/System

%package headers
Summary: Header files for the Linux kernel.
Group: Development/System

%package doc
Summary: Various documentation bits found in the kernel source.
Group: Documentation

%package pcmcia-cs
Summary: The daemon and device drivers for using PCMCIA adapters.
Group: System Environment/Kernel
Obsoletes: pcmcia-cs

%package ibcs
Obsoletes: iBCS
Summary: Files which allow iBCS2 programs to run.
Group: System Environment/Kernel

%description
The kernel package contains the Linux kernel (vmlinuz), the core of your
Red Hat Linux operating system.  The kernel handles the basic functions
of the operating system:  memory allocation, process allocation, device
input and output, etc.

%description source
The kernel-source package contains the source code files for the Linux
kernel. These source files are needed to build most C programs, since
they depend on the constants defined in the source code. The source
files can also be used to build a custom kernel that is better tuned to
your particular hardware, if you are so inclined (and you know what you're
doing).

%description headers
Kernel-headers includes the C header files for the Linux kernel.  The
header files define structures and constants that are needed for building
most standard programs.  The header files are also needed for rebuilding
the kernel.

%description doc
This package contains documentation files form the kernel source. Various
bits of information about the Linux kernel and the device drivers shipped
with it are documented in these files. You also might want install this
package if you need a reference to the options that can be passed to Linux
kernel modules at load time.

%description pcmcia-cs
Many laptop machines (and some non-laptops) support PCMCIA cards for
expansion. Also known as "credit card adapters," PCMCIA cards are small
cards for everything from SCSI support to modems. PCMCIA cards are hot
swappable (i.e., they can be exchanged without rebooting the system) and
quite convenient to use. The kernel-pcmcia-cs package contains a set of
loadable kernel modules that implement an applications program interface,
a set of client drivers for specific cards and a card manager daemon that
can respond to card insertion and removal events by loading and unloading
drivers on demand.  The daemon also supports hot swapping, so that the
cards can be safely inserted and ejected at any time.

Install the kernel-pcmcia-cs package if your system uses PCMCIA cards.

%description ibcs
This package allows you to run programs in the iBCS2 (Intel Binary
Compatibility Standard, version 2) and related executable formats. 
iBCS is a standard for binary portability between UNIX and UNIX-like
systems.

%package smp
Summary: Kernel version %{version} compiled for SMP machines.
Group: System Environment/Kernel

%description smp
This package includes a SMP version of the Linux %{version} kernel. It is
required only on machines with two or more CPUs, although it should work
fine on single-CPU boxes.

%package BOOT
Summary: Kernel version %{version} used on the installation boot disks.
Group: System Environment/Kernel

%description BOOT
This package includes a trimmed down version of the Linux %{version} kernel.
This kernel is used on the installation boot disks only and should not be
used for an installed system, as many features in this kernel are turned off
because of the size constraints.

%prep
%setup -q -n linux -a 1 -a 2 -b 3
%patch0 -p1
%patch1 -p1
%patch2 -p1
%patch3 -p1
%patch4 -p1
%patch5 -p0
%patch6 -p1
%patch7 -p1
%patch8 -p0
%patch9 -p0
%patch10 -p1
%patch11 -p1
%patch14 -p1
%patch15 -p1
%patch16 -p1
%patch17 -p1
%patch18 -p1
%patch19 -p1
%patch20 -p1
%patch21 -p1
%patch23 -p1
%patch24 -p1
%patch25 -p1
%patch26 -p1
%patch27 -p1
%patch28 -p1
%patch29 -p1
%patch30 -p1
%patch31 -p1
%patch32 -p1
%patch33 -p1
%patch34 -p0
%patch36 -p1

%patch50 -p1
%patch51 -p1

%ifarch i386 i586 i686
%patch40 -p0
%patch41 -p0
cp ibcs/CONFIG.i386 ibcs/CONFIG
%else
rm -rf pcmcia-cs-%{pcmciaver}
rm -rf ibcs
%endif

# Bring in the Red Hat Kernel Module Version Tag program
cp $RPM_SOURCE_DIR/rhkmvtag.c .

# Basically, this sucks. Shipping kernel source with procompiled binaries,
# that is. And having 'make mrproper' not cleaning that up either
make clean -C scripts/ksymoops

###
### build
###
%build

BuildKernel() {
    # is this a special kernel we want to build?
    if [ -n "$1" ] ; then
	Config=%{_target_cpu}-$1
	KernelVer=%{version}-%{release}$1
	echo BUILDING A KERNEL FOR $1...
    else
	Config=%{_target_cpu}
	KernelVer=%{version}-%{release}
	echo BUILDING THE NORMAL KERNEL...
    fi
%ifarch sparc64
    cp $RPM_SOURCE_DIR/kernel-2.2-$Config.config arch/%{_target_cpu}/defconfig
%else
    cp $RPM_SOURCE_DIR/kernel-2.2-$Config.config arch/%{_arch}/defconfig
%endif
    # make sure EXTRAVERSION says what we want it to say
    perl -p -i -e "s/^EXTRAVERSION.*/EXTRAVERSION = -%{release}$1/" Makefile
    rm -f .config
    make mrproper
    make oldconfig
    make dep 
    make include/linux/version.h 
%ifarch i386 i586 i686
    make -j 4 bzImage MAKE="make -j 4"
%else
    make boot
%endif
    make -j 4 modules MAKE="make -j 4"
    mkdir -p $RPM_BUILD_ROOT/boot
    install -m 644 System.map $RPM_BUILD_ROOT/boot/System.map-$KernelVer
     install -m 644 $RPM_SOURCE_DIR/module-info $RPM_BUILD_ROOT/boot/module-info-$KernelVer
%ifarch i386 i586 i686
     cp arch/i386/boot/bzImage $RPM_BUILD_ROOT/boot/vmlinuz-$KernelVer
     cp vmlinux $RPM_BUILD_ROOT/boot/vmlinux-$KernelVer
%else
     gzip -cfv vmlinux > vmlinuz
     install -m 755 vmlinux $RPM_BUILD_ROOT/boot/vmlinux-$KernelVer
     install -m 644 vmlinuz $RPM_BUILD_ROOT/boot/vmlinuz-$KernelVer
%endif
     mkdir -p $RPM_BUILD_ROOT/lib/modules/$KernelVer/{block,cdrom,fs,ipv4,misc,net,scsi,video}
     make INSTALL_MOD_PATH=$RPM_BUILD_ROOT modules_install KERNELRELEASE=$KernelVer
     #Identify the modules directory with the Red Hat Kernel Module Version Tag
%ifnarch sparc64
     cc -o rhkmvtag rhkmvtag.c init/version.o
     ./rhkmvtag > $RPM_BUILD_ROOT/lib/modules/$KernelVer/.rhkmvtag
     rm -f rhkmvtag
%endif
}

BuildiBCS() {
    if [ -z "$2" ] ; then
	echo "BUILDING FOR NORMAL KERNEL..."
    else
	echo "BUILDING FOR $2..."
    fi
    make -C ibcs/iBCSemul KERNEL=$RPM_BUILD_DIR/linux SMP=$1 all
    install -m644 ibcs/iBCSemul/iBCS \
	$RPM_BUILD_ROOT/lib/modules/%{KVERREL}$2/misc/iBCS.o
    make -C ibcs clean 
}

BuildPCMCIA() {
    if [ -z "$1" ] ; then
	echo "BUILDING FOR NORMAL KERNEL..."
    else
	echo "BUILDING FOR $1..."
    fi
    make -C pcmcia-cs-%{pcmciaver} config <<EOF
$RPM_BUILD_DIR/linux
$RPM_BUILD_ROOT
$RPM_BUILD_ROOT/lib/modules/%{KVERREL}$1
gcc
ld
$RPM_OPT_FLAGS
y
y
y
2
y
/etc/rc.d
EOF
    make -C pcmcia-cs-%{pcmciaver} all
    mkdir -p $RPM_BUILD_ROOT/lib/modules/%{KVERREL}$1/pcmcia
    make -C pcmcia-cs-%{pcmciaver} install
}

###
# DO it...
###

rm -rf $RPM_BUILD_ROOT

#SMP-ENABLED KERNEL
BuildKernel smp
%ifarch i386 i586 i686
BuildiBCS yes smp
# pcmcia does not compile on the smp kernels
#BuildPCMCIA smp
%endif

%ifnarch i586 i686
# BOOT kernel
BuildKernel BOOT
%ifarch i386
BuildPCMCIA BOOT
%endif
%endif

# NORMAL KERNEL
BuildKernel
%ifarch i386 i586 i686
BuildiBCS no
BuildPCMCIA
%endif

###
### install
###

%install
mkdir -p $RPM_BUILD_ROOT/usr/include
ln -sf ../src/linux/include/linux $RPM_BUILD_ROOT/usr/include/linux

mkdir -p $RPM_BUILD_ROOT/usr/src/linux-%{kversion} 

mkdir -p $RPM_BUILD_ROOT/{boot,sbin}
install -m 755 $RPM_SOURCE_DIR/installkernel $RPM_BUILD_ROOT/sbin/installkernel

%ifarch i386 i586 i686 
mkdir -p $RPM_BUILD_ROOT/etc/pcmcia
mkdir -p $RPM_BUILD_ROOT/etc/sysconfig
# Install our own network up/down script
install -m755 $RPM_SOURCE_DIR/pcmcia-cs-2.8.8-network.script \
        $RPM_BUILD_ROOT/etc/pcmcia/network

# We need our own default /etc/sysconfig/pcmcia
cat > $RPM_BUILD_ROOT/etc/sysconfig/pcmcia <<EOF
PCMCIA=no
PCIC=
PCIC_OPTS=
CORE_OPTS=
EOF

# Finally strip some binaries
for file in cardmgr cardctl probe scsi_info ftl_format ftl_check ; do
    strip $RPM_BUILD_ROOT/sbin/$file
done

# iBCS stuff
mkdir -p $RPM_BUILD_ROOT/usr/man/man9
install -m 644 ibcs/Doc/iBCS.9 $RPM_BUILD_ROOT/usr/man/man9

mkdir -p $RPM_BUILD_ROOT/dev/inet
install -m755 ibcs/MAKEDEV.ibcs $RPM_BUILD_ROOT/dev/MAKEDEV.ibcs
pushd $RPM_BUILD_ROOT ; {
  mknod ./dev/socksys c 30 0
  ln -s socksys ./dev/nfsd
  ln -s null ./dev/X0R
  mknod ./dev/spx c 30 1
  mknod ./dev/inet/ip c 30 32
  mknod ./dev/inet/icmp c 30 33
  mknod ./dev/inet/ggp c 30 34
  mknod ./dev/inet/ipip c 30 35
  mknod ./dev/inet/tcp c 30 36
  mknod ./dev/inet/egp c 30 37
  mknod ./dev/inet/pup c 30 38
  mknod ./dev/inet/udp c 30 39
  mknod ./dev/inet/idp c 30 40
  mknod ./dev/inet/rawip c 30 41
  ln -s udp ./dev/inet/arp
  ln -s udp ./dev/inet/rip
  cd ./dev/inet
  for i in *; do
    ln -s inet/$i ../$i
  done
} ; popd
%endif

mkdir -p $RPM_BUILD_ROOT/usr/src/linux-%{kversion}
tar cf - . | tar xf - -C $RPM_BUILD_ROOT/usr/src/linux-%{kversion}
ln -sf linux-%{kversion} $RPM_BUILD_ROOT/usr/src/linux
install -m 644 %{SOURCE4}  $RPM_BUILD_ROOT/usr/src/linux-%{kversion}

%ifarch sparc sparc64
ln -s ../src/linux/include/asm-sparc $RPM_BUILD_ROOT/usr/include/asm-sparc
ln -s ../src/linux/include/asm-sparc64 $RPM_BUILD_ROOT/usr/include/asm-sparc64
mkdir $RPM_BUILD_ROOT/usr/include/asm
cp -a $RPM_SOURCE_DIR/kernel-2.2-BuildASM.sh $RPM_BUILD_ROOT/usr/include/asm/BuildASM
$RPM_BUILD_ROOT/usr/include/asm/BuildASM $RPM_BUILD_ROOT/usr/include
%else
ln -sf ../src/linux/include/asm $RPM_BUILD_ROOT/usr/include/asm
%endif

#clean up the destination
%ifarch i386 i586 i686
make clean -C $RPM_BUILD_ROOT/usr/src/linux-%{kversion}/pcmcia-cs-%{pcmciaver}
make -C $RPM_BUILD_ROOT/usr/src/linux-%{kversion}/ibcs clean
%endif

make mrproper -C $RPM_BUILD_ROOT/usr/src/linux-%{kversion}
make oldconfig -C $RPM_BUILD_ROOT/usr/src/linux-%{kversion}
make symlinks -C $RPM_BUILD_ROOT/usr/src/linux-%{kversion}
make include/linux/version.h -C $RPM_BUILD_ROOT/usr/src/linux-%{kversion}

#this generates modversions info which we want to include and we may as
#well include the depends stuff as well, after we fix the paths
make depend -C $RPM_BUILD_ROOT/usr/src/linux-%{kversion}
find $RPM_BUILD_ROOT/usr/src/linux-%{kversion} -name ".*depend" | \
while read file ; do
    mv $file $file.old
    sed -e "s|[^ ]*\(/usr/src/linux\)|\1|g" < $file.old > $file
    rm -f $file.old
done

###
### clean
###

%clean
rm -rf $RPM_BUILD_ROOT

###
### scripts
###

# do this for upgrades...in case the old modules get removed we have
# loopback in the kernel so that mkinitrd will work.
%pre
/sbin/modprobe loop 2> /dev/null > /dev/null
exit 0

%post
cd /boot
ln -sf vmlinuz-%{KVERREL} vmlinuz
ln -sf System.map-%{KVERREL} System.map
ln -sf module-info-%{KVERREL} module-info

%ifarch i386 i586 i686
if [ -x /sbin/lilo -a -f /etc/lilo.conf ]; then
	/sbin/lilo > /dev/null 2>&1
	exit 0
fi
%endif

%post headers
cd /usr/src
rm -f linux
ln -snf linux-%{kversion} linux

%post source
cd /usr/src
rm -f linux
ln -snf linux-%{kversion} linux

%postun headers
if [ -L /usr/src/linux ]; then 
    if [ `ls -l /usr/src/linux | awk '{ print $11 }'` = "linux-%{kversion}" ]; then
	[ $1 = 0 ] && rm -f /usr/src/linux
    fi
fi
exit 0

%postun source
if [ -L /usr/src/linux ]; then 
    if [ `ls -l /usr/src/linux | awk '{ print $11 }'` = "linux-%{kversion}" ]; then
	[ $1 = 0 ] && rm -f /usr/src/linux
    fi
fi
exit 0

%ifarch i386 i586 i686
%post pcmcia-cs
/sbin/chkconfig --add pcmcia

%preun pcmcia-cs
if [ $1 = 0 ]; then
    /sbin/chkconfig --del pcmcia
fi
exit 0

%triggerpostun -- kernel-pcmcia-cs < 2.2.5
if [ -f /etc/rc.d/init.d/pcmcia ] ; then
    /sbin/chkconfig --add pcmcia
fi

%endif

###
### file lists
###

%files
/boot/vmlinux-%{KVERREL}
/boot/vmlinuz-%{KVERREL}
/boot/System.map-%{KVERREL}
/boot/module-info-%{KVERREL}
/sbin/installkernel
%dir /lib/modules
/lib/modules/%{KVERREL}

# this one should be really built only for the basic architecture
%ifarch i386 alpha sparc
%files source
/usr/src/linux-%{kversion}/COPYING
/usr/src/linux-%{kversion}/CREDITS
/usr/src/linux-%{kversion}/Documentation
/usr/src/linux-%{kversion}/MAINTAINERS
/usr/src/linux-%{kversion}/Makefile
/usr/src/linux-%{kversion}/README
/usr/src/linux-%{kversion}/REPORTING-BUGS
/usr/src/linux-%{kversion}/Rules.make
/usr/src/linux-%{kversion}/arch/%{_arch}
/usr/src/linux-%{kversion}/arch/sparc64
/usr/src/linux-%{kversion}/drivers
/usr/src/linux-%{kversion}/fs
/usr/src/linux-%{kversion}/init
/usr/src/linux-%{kversion}/ipc
/usr/src/linux-%{kversion}/kernel
/usr/src/linux-%{kversion}/lib
/usr/src/linux-%{kversion}/mm
/usr/src/linux-%{kversion}/modules
/usr/src/linux-%{kversion}/net
/usr/src/linux-%{kversion}/scripts
%ifarch i386
/usr/src/linux-%{kversion}/ibcs
/usr/src/linux-%{kversion}/pcmcia-cs-%{pcmciaver}
%endif
%endif

%ifarch i386
%files pcmcia-cs
%doc pcmcia-cs-%{pcmciaver}/doc/PCMCIA-HOWTO 
%doc pcmcia-cs-%{pcmciaver}/doc/PCMCIA-PROG
%doc pcmcia-cs-%{pcmciaver}/SUPPORTED.CARDS 
%doc pcmcia-cs-%{pcmciaver}/CHANGES 
%doc pcmcia-cs-%{pcmciaver}/COPYING 
%doc pcmcia-cs-%{pcmciaver}/README
/sbin/cardctl
/sbin/cardmgr
/sbin/ftl_check
/sbin/ftl_format
/sbin/ifport
/sbin/ifuser
/sbin/pcinitrd
/sbin/probe
/sbin/scsi_info
/usr/man/*/*
%config /etc/rc.d/init.d/pcmcia
%config /etc/sysconfig/pcmcia
%dir /etc/pcmcia
/etc/pcmcia/cdrom
/etc/pcmcia/config
/etc/pcmcia/ftl
/etc/pcmcia/ide
/etc/pcmcia/memory
/etc/pcmcia/network
/etc/pcmcia/scsi
/etc/pcmcia/serial
/etc/pcmcia/shared
/etc/pcmcia/cis
%config /etc/pcmcia/config.opts
%config /etc/pcmcia/cdrom.opts
%config /etc/pcmcia/ftl.opts
%config /etc/pcmcia/ide.opts
%config /etc/pcmcia/memory.opts
%config /etc/pcmcia/scsi.opts
%config /etc/pcmcia/serial.opts
%endif

# again a package that makes no sense to have a optimized version for
%ifarch i386 alpha sparc
%files headers
%dir /usr/src/linux-%{kversion}
%ifarch sparc
/usr/src/linux-%{kversion}/include/asm-sparc
/usr/src/linux-%{kversion}/include/asm-sparc64
/usr/include/asm-sparc
/usr/include/asm-sparc64
%else
/usr/src/linux-%{kversion}/include/asm-%{_arch}
%endif
/usr/src/linux-%{kversion}/include/asm
/usr/src/linux-%{kversion}/include/asm-generic
/usr/src/linux-%{kversion}/include/linux
/usr/src/linux-%{kversion}/include/net
/usr/src/linux-%{kversion}/include/scsi
/usr/src/linux-%{kversion}/include/video
/usr/include/asm
/usr/include/linux
%endif
/usr/src/linux-%{kversion}/README.kernel-sources

%files smp
/boot/vmlinux-%{KVERREL}smp
/boot/vmlinuz-%{KVERREL}smp
/boot/System.map-%{KVERREL}smp
/boot/module-info-%{KVERREL}smp
/sbin/installkernel
%dir /lib/modules
/lib/modules/%{KVERREL}smp

%ifarch i386 alpha sparc
%files doc
%doc Documentation/*
%endif

%ifnarch i586 i686
%files BOOT
/boot/vmlinux-%{KVERREL}BOOT
/boot/vmlinuz-%{KVERREL}BOOT
/boot/System.map-%{KVERREL}BOOT
/sbin/installkernel
%dir /lib/modules
/lib/modules/%{KVERREL}BOOT
%endif

%ifarch i386
%files ibcs
%defattr(-,root,root)
%doc ibcs/{README,RELEASE,CREDITS,Doc}
/usr/man/man9/iBCS.9
/dev/MAKEDEV.ibcs
/dev/inet
/dev/socksys
/dev/nfsd
/dev/X0R
/dev/spx
/dev/arp
/dev/egp
/dev/ggp
/dev/icmp
/dev/idp
/dev/ip
/dev/ipip
/dev/pup
/dev/rawip
/dev/rip
/dev/tcp
/dev/udp
%endif

%changelog
* Thu Jul 01 1999 Arnaldo Carvalho de Melo <acme@conectiva.com>
- backed off from 2.2.10, applied Marcelo's scsi-spinlocks and 
  loopback mtu 0 patches

* Tue Jun  1 1999 Matt Wilson <msw@redhat.com>
- added remote crash fix from Alan Cox

* Mon May 17 1999 Matt Wilson <msw@redhat.com>
- rebuilt against fixed egcs to fix sparc crashes

* Mon Apr 26 1999 Cristian Gafton <gafton@redhat.com>
- alpha patches form Jay Estabrook
- semaphore patches from rth for alpha

* Mon Apr 19 1999 Cristian Gafton <gafton@redhat.com>
- upgraded the defrag patch with stuff from davem

* Sun Apr 18 1999 Cristian Gafton <gafton@redhat.com>
- log debugging information about starting nfsd to syslog instead of console
- make sure the postinstall exits with success for the kernel rpm if lilo
  has issues
- updated sparc jumbo patch
- networking fixes from DaveM
- make pcmcia use a preun instead of a postun. Duh.
- triggerpostun protects upgrades from older verrsions of pcmcia. Duh. Duh.

* Sat Apr 17 1999 Cristian Gafton <gafton@redhat.com>
- added patches for the alpha problems, ftruncate fix, mmap
  and shm fixes from the 2.2.6 kernel
- updated DaveM's sparc patch
- x86 patches also from x86 kernel

* Fri Apr 16 1999 Cristian Gafton <gafton@redhat.com>
- build alpha network drivers as modules
- pcmcia scripts do not use /dev/cuaX anymore for /dev/modem (ttySX instead)
- disable RTC on alpha

* Wed Apr 14 1999 Cristian Gafton <gafton@redhat.com>
- add patch for tokenring
- add the REAME.kernel-sources file to the kernel-headers
- updated again the sparc patch
- add Linus's patch to fix out of memory errors
- fix dac960's driver include files

* Mon Apr 12 1999 Cristian Gafton <gafton@redhat.com>
- new sparc patch (davem)
- new RAID patch (mingo)
- new aic7xxx driver (5.1.15 - dledford)
- aarp patch from alan

* Fri Apr 09 1999 Cristian Gafton <gafton@redhat.com>
- add patch from Alan to make SYS_access SuSv2 compliant
- update Dave Miller's sparc patch
- get rid of the bogus buffer patch (why the heck didn't patch reject it in
  first place?)

* Wed Apr 07 1999 Cristian Gafton <gafton@redhat.com>
- more patches from Alan
- updated the knfsd patches from knfsd 1.2.2

* Mon Apr 05 1999 Cristian Gafton <gafton@redhat.com>
- updated sparc patch from davem
- added patch for sound docs and bttv driver from alan

* Wed Mar 31 1999 Cristian Gafton <gafton@redhat.com>
- add i586 as an other platform
- patch from Alan Cox to fix misc hangups
- updated Doug's driver to 5.1.13
- version 2.2.5

* Fri Mar 26 1999 Cristian Gafton <gafton@redhat.com>
- added BOOT config files for all the arches
- updated config files (again)

* Wed Mar 24 1999 Cristian Gafton <gafton@redhat.com>
- version 2.2.4
- new DAC960 patch
- install a module-info for ech kernel build
- be more selective in building kernel-doc for all arches
- alpha CPUs detection patch

* Sat Mar 13 1999 Cristian Gafton <gafton@redhat.com>
- patch for nbd stuff
- added large fd patch
- added nfsd patches from the knfsd dist

* Sat Mar 13 1999 Matt Wilson <msw@redhat.com>
- disabled vfork() on sparc32
- fixed up sparc64 build
- changed the compression level for bzImages from -9 to -3 on i386

* Fri Mar 12 1999 Matt Wilson <msw@redhat.com>
- build sunlance into the sparc kernels

* Thu Mar 11 1999 Cristian Gafton <gafton@redhat.com>
- version 2.2.3
- make the /usr/src/linux-VER dir owned by kernel-headers instead of
  kernel-source

* Wed Mar 10 1999 Cristian Gafton <gafton@redhat.com>
- update to 2.2.2-ac7
- add config files for i686

* Wed Feb 24 1999 Cristian Gafton <gafton@redhat.com>
- merged in sparc64 changes
- update to 2.2.2
- fix the uname problems in different shapes of kernel being generated
- create a documentation package

* Thu Feb 11 1999 Cristian Gafton <gafton@redhat.com>
- version 2.2.1 w/ ac5
- build the boot kernel for the bootdisks

* Wed Jan 27 1999 Cristian Gafton <gafton@redhat.com>
- ver 2.2.0 final w/ ac1
- move the pcmcia modules to the main kernel package
- also build smp version of the kernel
- enable apm in the kernel by default

* Tue Jan 19 1999 Cristian Gafton <gafton@redhat.com>
- update to 2.2.0 pre 8 w/ ac1

* Sun Dec 27 1998 Mike Wangsmo <wanger@redhat.com>
- put in 133ac3
- fixed PCMCIA to use GET_USE_COUNT instead of module->usecount

* Mon Dec 21 1998 Cristian Gafton <gafton@redhat.com>
- remove the jensen and srm-jensen subpackages, as those should be handled
  by the generic kernel instead.
- use 131ac13
- upgradede to 2.1.131
- removed /usr/include/scsi from kernel-headers

* Mon Nov 23 1998 Cristian Gafton <gafton@redhat.com>
- upgraded to 2.1.129 ac3
- pcmcia-cs 3.0.6
- XXX: disabled the DEPCS, EWRK3 support, as it does not build yet

* Tue Sep 29 1998 Cristian Gafton <gafton@redhat.com>
- upgraded to 2.1.123
- builds jansen and jensen-srm subpackages on alpha

* Thu Aug 13 1998 Cristian Gafton <gafton@redhat.com>
- build of 2.1.115, based on the previous spec from 2.0.35
- build like almost any other package, not dircetly in the buildroot
- sed the buildroot dir out of the .depend files

