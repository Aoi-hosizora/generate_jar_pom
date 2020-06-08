# Generate_jar_pom

+ A script to generate maven's pom.xml from a directory of jar files

### Function

+ [x] Generate xml file for maven-build jar (read pom.properties file)
+ [x] Filter non-jar(skip), break-jar(skip), non-maven(error), multiple-properties(error) files
+ [ ] Generate for non-maven-build jar

### Usage

```text
Usage of jar2pom.sh:
    sh jar2pom.sh [-h|--help]: show help
    sh jar2pom.sh $DIRECTORY: generate maven xml to out.xml
    sh jar2pom.sh $DIRECTORY $OUTPUT: generate maven xml to $OUTPUT
```

### Result

```xml
<!-- GENERATE BY jar2pom.sh -->

<!-- xxx/commons-io-2.4.jar -->
<dependency>
    <groupId>commons-io</groupId>
    <artifactId>commons-io</artifactId>
    <version>2.4</version>
</dependency>

<!-- END OF DIRECTORY xxx -->
```
