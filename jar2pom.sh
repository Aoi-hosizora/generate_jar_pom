error=()
success=()
for entry in "$1"/*;
do
    # echo "$entry"
    prop=$(jar -tf "$entry" | grep -E "META-INF/maven/.*/pom.properties")
    if [ "$prop" != "" -a $(echo "$prop" | wc -l) == 1 ];
    then
        content=$(unzip -q -c "$entry" "$prop")
        ver=$(echo "$content" | grep -P "(?<=version=).+" -o)
        gid=$(echo "$content" | grep -P "(?<=groupId=).+" -o)
        aid=$(echo "$content" | grep -P "(?<=artifactId=).+" -o)
        if [ "$gid" != "" -a "$aid" != "" ];
        then
            success+=("$entry")
            echo ""
            echo "<!-- $entry -->"
            echo "<dependency>"
            echo "    <groupId>$gid</groupId>"
            echo "    <artifactId>$aid</artifactId>"
            echo "    <version>$ver</version>"
            echo "</dependency>"
            continue
        fi
    fi
    error+=("$entry")
done

success_cnt=${#success[*]}
fail_cnt=${#error[*]}

echo ""
echo "Success to generate pom for $success_cnt file(s) above."

if [ $fail_cnt -gt 0 ];
then
    echo ""
    echo "Failed to generate pom for $fail_cnt file(s):"
    for entry in ${error[*]};
    do
        echo "$entry"
    done
fi
