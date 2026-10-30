# Experimental RTL8812BU driver adaptation for Vista SP2 x64

[Download the experimental driver ZIP](Vista-RTL8812BU-experimental-v0.1.zip?raw=true)

**Unsigned and not tested on Windows or physical hardware. This is a test candidate, not a verified working driver or an official TP-Link/Realtek release. It may fail or crash Windows.**

Exact target: `USB\VID_2357&PID_0116`, including revision `0210`. Requires Vista SP2 x64 and an already-installed compatible Microsoft KMDF 1.9+ runtime.

Extract the ZIP and run `PRECHECK.cmd` first. Read the included `README.txt` before attempting installation. It explains the temporary, one-boot unsigned-driver test and rollback. Normal Vista x64 signature enforcement is expected to reject this unsigned build.

The package includes a separate adapted SYS/INF, unchanged OEM power tables, a guarded reproducible binary-patching script, an exact patch manifest, and static review reports. It selects retained NDIS 6.1 paths and adapts registration/general attributes; it is not a full source-level rebuild. Static validation does not establish Wi-Fi functionality or stability.

After a test, report Device Manager's exact status/error, whether networks appear, and the generated `Vista-diagnostic.txt`. Wi-Fi association, data transfer, USB 3.0 and power behavior remain unverified.

The archive SHA-256 is recorded in `SHA256SUMS`.

## Installation failure diagnostics

If Windows reports Code 39 or the driver service is missing, [download the read-only diagnostic helper](Vista-install-diagnostics.zip?raw=true). Extract it, right-click `Collect-Vista.cmd`, and choose **Run as administrator**. Review and share the generated `Vista-install-report.txt` with the person diagnosing the failure. The helper queries the actual adapter binding and recent matching SetupAPI log sections; it does not install/start drivers or change settings. It has been reviewed but not executed on Vista here.
