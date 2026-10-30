Vista installation diagnostics -- read-only helper

Extract both Collect-Vista.cmd and Collect-Vista.vbs to the same writable folder.
Leave the matching USB adapter connected. Right-click Collect-Vista.cmd and
choose Run as administrator so Windows permits reading its installation log.

The helper writes Vista-install-report.txt beside itself. Review that text file
and attach it to the chat. It contains the matching adapter's selected service,
INF name, Device Manager error, relevant installed file versions/sizes, service
queries and up to three matching sections from Windows' SetupAPI install log.
Those log sections can include local file paths and your Windows username.
The report can also contain the USB instance ID and other Realtek installation
sections, and can be partial if Windows denies access to a query or log.

The helper does not install or start any driver, change signature settings,
alter the registry, or contact any network destination. A missing RtlWlanuVista
service is reported as-is; it is not manually created. A load attempt or another
binary patch should wait for the actual installation error.

The script was reviewed in the development environment but cannot be executed
or verified on Vista here. If scripting is blocked, the command file still
captures native sc.exe queries. Report any script error shown in the text file.
