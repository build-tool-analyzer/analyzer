# Build Tool Perfromance Analyzer

## Usage

```.\analyzer-script.ps1 "<tool-name>" "<path/to/codebase>" "<name-of-analysis-scenario>" "<num-iterations>" "<BAZEL-ONLY:target-name>" <flags (not required)>```
  
  ### Flags
  ```-clean``` runs the appropriate build tool clean command, forcing the tool to build from scratch
  ```-cold``` shuts down the build tool prior to running the test, forcing a cold start
  ```-test``` runs tests with the build (default skips tests)
