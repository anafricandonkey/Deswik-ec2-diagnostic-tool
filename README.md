# Deswik EC2 Log Diagnostic Tool

## Design Decisions

- **Modular functions** — each step is its own function with CmdletBinding and parameter validation. Means you could swap the mock functions for real AWS calls without touching the parser or report.
- **Warnings over silent skips** — malformed log lines get a Write-Warning instead of being quietly dropped. If the log data is bad you want to know about it.
- **PSCustomObject returns** — the mock EC2 function returns a structured object that matches the shape of real AWS output. Keeps the transition to live calls simple.
- **Try/catch with exit code** — if something fails, you get a clean error message and a non-zero exit code. Useful if this ever runs in a pipeline.
- **Configurable error code** — defaults to 500 but you can pass a different status code to investigate 503s, 502s, etc.

## Known Limitations

Given more time and before sending this through for a PR for production use I would address the following:

- Log filename is hardcoded to `mockIISLog.txt`. Production version would take this as a parameter or derive it from the instance ID.
- Assumes logs come as zip files. Could be gzip or raw text depending on the environment.
- The sc-status field index is hardcoded to position 10 based on the #Fields header in the sample log. Didn't have time to build dynamic field parsing but that'd be the first thing I'd add.
- No validation that the status code field is actually numeric.
- Only handles a single log file. Doesn't cover split logs or time range filtering.
- Mock EC2 data is static. Could be improved with randomised states or a config file.
- Large log files could cause memory issues. Would use `Get-Content -ReadCount` or streaming for production scale.