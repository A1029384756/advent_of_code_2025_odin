# Advent of Code 2025
This repo holds Odin solutions to 2025s Advent of Code.

## Structure
The repo follows the following structure:
```
|- input/
|- common/
|- d${day}/
|- run.sh
|- test.sh
```

Each day is broken into its own package and holds all Odin files
it requires and any sample input text files. Each day also has
benchmarking and tests set up.

## Helper Scripts
`run.sh` and `test.sh` both do what they say on the tin, run the
"real" programs + benchmarking and run the tests. Usage is fairly
simple and is as follows: `<program>.sh day|all`. For example, if
one wished to run day 17, they would run `./run.sh 17` (same for
`test.sh`). If you wanted to run all days, you would instead run
`./run.sh all` (once again same for `test.sh`).
