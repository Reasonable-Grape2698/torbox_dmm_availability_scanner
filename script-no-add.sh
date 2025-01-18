temp=''
output="output.txt"
input="dmm.json"

while getopts a:i:o: flag
do
    case "${flag}" in
        a) apitoken=${OPTARG};;
        i) input=${OPTARG};;
        o) output=${OPTARG};;
    esac
done

# Format into lines of 150 hashes per call (curl maximum)
hashes=$(jq '.[].hash' $input)
tempfile=$(mktemp)
echo $hashes | tr ' ' ',' | tr -d '"' | fold -w 6150 >> $tempfile
percentile=100
countCached=0

tasks_in_total=$(echo $hashes | tr ' ' ',' | tr -d '"' | fold -w 41 | wc -l)
count=0
# For each line of 150 hashes, curl API
# Format jq.data, too entries[], select key(s)(hashes)
# Format and output as single lines to output.txt
while read line; do
        temp=$(curl -s -H "Authorization: Bearer $apitoken" https://api.torbox.app/v1/api/torrents/checkcached?hash=$line&format=object&list_files=true)
        temp=$(echo $temp | jq .data)
        # If data isn't empty, select key (hash) and output as single lines to output.txt
        if [[ "$temp" != "{}" ]]
        then
                temp=$(echo $temp| jq -r 'to_entries[]' | jq -r ".key")
                echo $temp | tr -d ' ' | fold -w 40 >> $output
        fi
        count=$(echo $count+150 | bc)
        percent="$(echo "$count" "$tasks_in_total" |awk '{printf "%.2f", $1 * 100 / $2}')"
        echo "$count / $tasks_in_total $percent %
done < <(cat $tempfile)

rm $tempfile
