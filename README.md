# Alpine Calculator

A lightweight Docker-based application that performs line-by-line numerical summation using a Bash script within an Alpine Linux container.

## Components
- `Dockerfile` - Creates an Alpine-based image, installs `bash` and `tzdata` packages, and copies the `calculate_sum.sh` script into the container.
- `calculate_sum.sh` - Processes `/data/numbers.txt` as input, calculates sum of integers per line, and writes results to a timestamped output file.
- `numbers.txt` - Sample input file containing space-separated integers per line.

## Functionality
The `calculate_sum.sh` script executes the following operations:
- Input source: `/data/numbers.txt` (must be mounted from host machine via volume binding).
- Parses each line and computes the sum of valid integers (including negative values). Non-integer tokens (letters, whitespace, decimals) are ignored.
- Outputs each line sum as a corresponding line in the result file.
- Output filename format: `<YYYY-MM-DD>_<HH-MM-SS>-v1.txt` (e.g., `2025-09-29_11-29-05-v1.txt`) written to `/data` directory.

Note: The Dockerfile sets `ENV TZ=Europe/Istanbul`; all timestamp calculations use this timezone.

## File Naming and Versioning Behavior
- The script uses colon (`-`) characters in the time format (e.g., `11-29-05`). Sample output files in this repository demonstrate this format.
- The `version` variable is currently hardcoded to `1`; files with identical timestamps will be truncated/overwritten. For automatic versioning (v1 → v2 ...), implement file existence checking and increment logic in the script.

## Input Format Specification
Example numbers.txt structure:

```
15 23
42 18
7 91
...
```

Each line must contain space-separated integers. The sum of each line will be written to the corresponding line in the output file.

## Usage Instructions
1) Build the Docker image:

```bash
docker build -t <docker-hub-username>/alpine-calculator:<version> .
```

2) Execute the container with volume mount for `numbers.txt` in current directory:

```bash
docker run --rm -v "$(pwd)":/data <docker-hub-username>/alpine-calculator:<version>
```

| Parameter | Description |
|-|-|
| `docker` | Docker CLI for container management operations. |
| `run` | Creates and starts a new container instance. |
| `--rm` | Automatically removes container upon completion (cleanup). |
| `-v` | Volume mount flag for host-to-container path binding. |
| `"$(pwd)"` | Shell expansion for current working directory path; quotes handle spaces safely. |
| `:/data` | Container target mount point where script reads/writes `/data/numbers.txt`. |
| `alpine-calculator` | Docker image name to execute; runs the default `CMD` instruction. |

Post-execution generates output file `YYYY-MM-DD_HH:MM:SS-v1.txt` in `$(pwd)` directory. Each line contains the sum of corresponding input line integers.

3) Push image to Docker Hub repository:

```bash
docker push <docker-hub-username>/alpine-calculator:<version>
```

4) Pull image from Docker Hub registry:

```bash
docker pull <docker-hub-username>/alpine-calculator:<version>
```

## Edge Cases and Error Handling
- If `/data/numbers.txt` does not exist, the script creates an empty output file and exits successfully (exit code 0).
- Input file trailing newline behavior affects output file newline formatting. The script preserves input newline structure without adding extra newlines when input lacks trailing newline.
- Script processes only integers matching regex pattern `^-?[0-9]+$`; decimal and non-numeric formats are ignored.

## Troubleshooting
- If output files are not created in mounted directory, verify Docker mount permissions (`docker run -v` requires write access to target directory).
> **Docker Desktop → `Settings` → `Resources` → `File Sharing` → `Browse` → `Open` → Add (`+`) → `Apply`**
- If timestamps differ from expected values, check host machine timezone settings and container `TZ` environment variable (`ENV TZ`).

## License
This project serves as a demonstration example; adapt and modify according to your requirements.
