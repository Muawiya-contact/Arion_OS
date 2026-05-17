# Building Arion OS

This is an overview of the process of building Arion OS from source.

We currently support the following platforms:
- Linux (recommended)
- WSL2 on Windows (tested and working)

---

## Why a Cross-Compiler?

Arion OS targets its own kernel ABI. A standard Linux GCC cannot compile
OS-level code for this platform. We need a GCC configured specifically
for `x86_64-unknown-haiku`. The buildtools compile that cross-compiler
once, locally on your machine.

---

## Required Software

**Tools provided within the build system:**
- `jam` (Haiku's custom Jam 2.5)
- Arion OS cross-compiler (built from buildtools)

**Tools you need to install:**
- `git`
- `gcc` / `g++` and binutils
- `make`
- `bison` (2.4 or better)
- `flex`
- `makeinfo` (part of `texinfo`)
- `autoheader` (part of `autoconf`)
- `automake`
- `awk`
- `nasm`
- `wget`
- `zip` / `unzip`
- `mtools`
- `python3`
- `zlib`
- `zstd`
- Case-sensitive file system (use WSL2 home directory, NOT `/mnt/c/`)

**Install all at once (Ubuntu/WSL2):**
```bash
sudo apt install git nasm autoconf automake texinfo flex bison \
  gawk build-essential unzip zip mtools zstd python3 wget \
  libzstd-dev libsolv-dev liblzma-dev libssl-dev \
  libcurl4-openssl-dev libncurses-dev zlib1g-dev \
  libexpat1-dev libxml2-dev
```

---

## Getting the Source

```bash
# Get Arion OS source (private repo)
git clone https://github.com/Coding-Moves/Arion_OS 

# Get the cross-compiler buildtools (one time only)
git clone https://review.haiku-os.org/buildtools.git
```

---

## Building the Cross-Compiler (One Time Only)

```bash
cd ArionOS
./configure --build-cross-tools x86_64 --cross-tools-source ~/buildtools
```

This takes **30-40 minutes** the first time. You only need to do this once.

---

## Building Jam

Arion OS uses a custom version of Jam (not standard Perforce Jam).
Build it once from the buildtools:

```bash
cd ~/buildtools/jam
make
```

---

## Configuring the Build

From inside your ArionOS directory:

```bash
cd ~/ArionOS
./configure --build-cross-tools x86_64 --cross-tools-source ~/buildtools
```

The configure script generates `generated/build/BuildConfig`.
You only need to re-run configure if you update the source significantly.

---

## Building the OS Image

### VMware image (.vmdk) — recommended for VirtualBox
```bash
HAIKU_REVISION=hrev57937_111 ~/buildtools/jam/bin.linuxx86/jam @vmware-image
```
Output: `generated/haiku.vmdk`

### Raw image
```bash
HAIKU_REVISION=hrev57937_111 ~/buildtools/jam/bin.linuxx86/jam @nightly-raw
```
Output: `generated/haiku.image`

### CD image (.iso)
```bash
HAIKU_REVISION=hrev57937_111 ~/buildtools/jam/bin.linuxx86/jam @cd-image
```
Output: `generated/haiku.iso`

---

## Building Individual Components

To build just one app or driver:
```bash
HAIKU_REVISION=hrev57937_111 ~/buildtools/jam/bin.linuxx86/jam -q Tracker
HAIKU_REVISION=hrev57937_111 ~/buildtools/jam/bin.linuxx86/jam -q Deskbar
```

---

## Important Notes

- Always work inside WSL2's own filesystem (`~/`) not `/mnt/c/`
- The Windows filesystem is case-insensitive and will cause build failures
- The `generated/` folder is large (~15-20 GB) — add it to `.gitignore`
- Subsequent builds are much faster — packages are cached in `generated/download/`
- If build fails at image step, check: `generated/build/haiku-revision`
  must contain `hrev57937_111`

---

## Running Arion OS

### In VirtualBox
1. VM type: `Other/Unknown (64-bit)`
2. RAM: `1024 MB`
3. Storage: Use existing `ArionOS.vmdk`
4. Graphics Controller: `VBoxVGA`, Video Memory: `128 MB`
5. System: `1 CPU`, Paravirtualization: `None`
6. Disable Hyper-V if running alongside WSL2:
   ```powershell
   bcdedit /set hypervisorlaunchtype off
   ```
   Restart PC, then launch VirtualBox.

### On Real Hardware (USB)
1. Build the `.iso` image
2. Flash to USB using [Rufus](https://rufus.ie)
3. Boot from USB on target machine