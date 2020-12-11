# Build Tool Perfromance Analyzer

## Usage

Clone the repository, leaving ```analyzer-script.ps1``` and ```logPID.py``` in the same directory. Clone one of the example codebases we have set up, then check out the branch ```maven-build```; ```gradle-build```; or ```bazel-build```, or clone a codebase and set it up for the tool you wish to analyze.

By default, the script runs ```mvn package```, ```gradle build```, or ```bazel build //:target```.

Run the PowerShell script as follows and find the performance log and a graph of the results as well as dependencies in ```/results```.

```.\analyzer-script.ps1 "<tool-name>" "<path/to/codebase>" "<name-of-analysis-scenario>" "<num-iterations>" "<BAZEL-ONLY:target-name>" <flags (not required)>```
  
  ### Flags
  ```-clean``` runs the appropriate build tool clean command, forcing the tool to build from scratch\
  ```-cold``` shuts down the build tool prior to running the test, forcing a cold start\
  ```-test``` runs tests with the build (default skips tests)
  
  ### Dependency Graph Plugins
  
  Maven and Gradle require external plugins to generate dependency graphs. 
  
  #### Maven
  
Add
```
<plugin>
  <groupId>com.github.ferstl</groupId>
  <artifactId>depgraph-maven-plugin</artifactId>
  <version>3.3.0</version>
  <configuration>
    <graphFormat>dot</graphFormat>
    <createImage>true</createImage>
    <showDuplicates>true</showDuplicates>
  </configuration>
</plugin>
```
to ```pom.xml```
then run ```mvn depgraph:graph```
then go to ```/target``` to find the generated graph.

#### Gradle

Add
```
plugins {
    id "com.vanniktech.dependency.graph.generator" version "0.5.0"
}
```
to each ```build.gradle```
then run ```gradle generateDependencyGraph```
then go to ```/build/reports/dependency-graph``` to find the generated graph.
