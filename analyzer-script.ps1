$tool = $args[0]
$path = $args[1]
$name = $args[2]
$iterations = $args[3]

$clean = $false
$cold = $false
$test = $false
$skiptestargs
$target = ""

$i = 4

if($tool -eq "bazel") {
	$target = $args[4]
	$i = 5
}

mkdir -Force results

while($i -lt $args.length) {
	if($args[$i] -eq "-clean") {
		$clean = $true
	}
	if($args[$i] -eq "-cold") {
		$cold = $true
	}
	if($args[$i] -eq "-test") {
		$test = $true
	}
	
	$i = $i + 1
}

$script_home = Get-Location
$process = 0
cd $path

if($tool -eq "bazel") {
	bazel info
	if(!$test) {
		$skiptestargs 
	}
	$arguments = "build //:$target_deploy.jar --javacopt=-XepDisableAllChecks"
}

if($tool -eq "gradle") {
	gradle
	if(!$test) {
		$arguments = "build -x tests"
	}
	$arguments = "build"
}

if($tool -eq "mvn") {
	if(!$test) {
		$arguments = "package -DskipTests"
	}
	$arguments = "package"
}

#Main execution loop 
for ($j = 0; $j -lt $iterations; $j++ ) {
	if($clean) {
		Start-Process $tool -ArgumentList "clean"
	}
	
	if($cold) {
		if($tool -eq "bazel") {
			bazel shutdown
		}
		if($tool -eq "gradle") {
			gradle --stop
		}
		sleep(5)
	}

	$process_id = (Start-Process $tool -ArgumentList $arguments -passthru).ID
    sleep(0.1)
    $java_process=(ps | grep java| tr -s ' ' | cut -d ' ' -f 7)
    python $script_home\logPID.py $process_id $java_process
    sleep(2)
    Rename-Item -Force -Path .\log.txt -NewName $name-$tool-performance-log-$j.txt
    Rename-Item -Force -Path .\img.png -NewName $name-$tool-performance-$j.png
    mv -Force .\$name-$tool-performance-log-$j.txt -Destination $script_home\results
    mv -Force .\$name-$tool-performance-$j.png -Destination $script_home\results
} 

if($tool -eq "bazel") {
	bazel query "deps(//:$target)" --notool_deps --noimplicit_deps --output graph > graph.in
	Get-Content -Path "graph.in" | Out-File -FilePath "newgraph.in" -Encoding ascii
	rm graph.in
	dot "-Tpng" "newgraph.in" -o "$name-bazel-dependencies.png"
	rm newgraph.in
	mv -Force .\$name-bazel-dependencies.png -Destination $script_home\results
}

if($tool -eq "gradle") {
	gradle generateDependencyGraph
	Rename-Item -Force -Path .\build\reports\dependency-graph\dependency-graph.png -NewName $name-gradle-dependencies.png
	mv -Force .\build\reports\dependency-graph\$name-gradle-dependencies.png -Destination $script_home\results
	cd $script_home
}

if($tool -eq "mvn") {
	mvn depgraph:graph
	cd target
	Rename-Item -Force -Path .\dependency-graph.png -NewName $name-maven-dependencies.png
	mv -Force $name-maven-dependencies.png -Destination $script_home\results
	cd $script_home
}

cd $script_home