SH_NAME="jar2pom.sh"
OUTPUT=${2:-"out.xml"}
PWD="$( cd "$( dirname "$0" )" && pwd )"

# Print help
if [ "$1" == "" -o "$1" == "-h" -o "$1" == "--help" ];
then
    echo "Usage of $SH_NAME:"
    echo "    sh $SH_NAME [-h|--help]: show help"
    echo "    sh $SH_NAME \$DIRECTORY \$OUTPUT: generate maven xml to \$OUTPUT, $OUTPUT default for out.xml"
    exit
fi

# Init array and output file
echo ""
echo "> Start generating:"
success=()
error=()
skip=()
echo "<!-- GENERATE BY $SH_NAME -->" > $OUTPUT

# Start
for entry in "$1"/*;
do
    # Check jar file
    if [[ "$entry" != *.jar ]];
    then
        echo "$entry -> skip (non-jar)"
        skip+=("$entry -> skip (non-jar)")
        continue
    fi

    # Read jar file
    jar=$( jar -tf "$entry" 2> /dev/null )
    if [ $? -ne 0 ]; 
    then
        echo "$entry -> skip (break-jar)"
        skip+=("$entry -> skip (break-jar)")
        continue
    fi

    # Read pom.properties
    prop=$( echo "$jar" | grep -E "META-INF/maven/.*/pom.properties" )
    if [ "$prop" == "" ];
    then
        echo "$entry -> error (non-maven)"
        error+=("$entry -> error (non-maven)")
    elif [ $( echo "$prop" | wc -l ) != 1 ];
    then
        echo "$entry -> error (multiple-properties)"
        error+=("$entry -> error (multiple-properties)")
    else
        # Get properties content
        content=$( unzip -q -c "$entry" "$prop" )
        ver=$( echo "$content" | grep -P "(?<=version=).+" -o )
        gid=$( echo "$content" | grep -P "(?<=groupId=).+" -o )
        aid=$( echo "$content" | grep -P "(?<=artifactId=).+" -o )
        if [ "$gid" == "" -a "$aid" == "" -a "$ver" == "" ];
        then
            echo "$entry -> error (empty-properties)"
            error+=("$entry -> error (empty-properties)")
        else
            # Write to output
            echo "" >> $OUTPUT
            echo "<!-- $entry -->" >> $OUTPUT
            echo "<dependency>" >> $OUTPUT
            echo "    <groupId>$gid</groupId>" >> $OUTPUT
            echo "    <artifactId>$aid</artifactId>" >> $OUTPUT
            echo "    <version>$ver</version>" >> $OUTPUT
            echo "</dependency>" >> $OUTPUT

            echo "$entry -> $gid:$aid:$ver"
            success+=("$entry")
        fi
    fi
done

# End of output file
echo "" >> $OUTPUT
echo "<!-- END OF DIRECTORY $1 -->" >> $OUTPUT

# Log result
skip_cnt=${#skip[*]}
success_cnt=${#success[*]}
fail_cnt=${#error[*]}

# Success
echo ""
echo "> Success to generate pom for $success_cnt file(s) above."
echo "> You can find it in $PWD/$OUTPUT."

# Skip
if [ $skip_cnt -gt 0 ];
then
    echo ""
    echo "> Skip $skip_cnt non-jar or break-jar file(s):"
    for ((i = 0; i < ${#skip[@]}; i++))
    do
        echo "${skip[$i]}"
    done
fi

# Fail
if [ $fail_cnt -gt 0 ];
then
    echo ""
    echo "> Failed to generate pom for $fail_cnt file(s):"
    for ((i = 0; i < ${#error[@]}; i++))
    do
        echo "${error[$i]}"
    done
fi
