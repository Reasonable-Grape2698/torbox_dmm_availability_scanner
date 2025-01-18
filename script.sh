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

# Format into lines of 150 hashes per call, seperated by commas (curl has a maximum line length, this avoids it)
hashes=$(jq '.[].hash' $input)
tempfile=$(mktemp)
echo $hashes | tr ' ' ',' | tr -d '"' | fold -w 6150 >> $tempfile

# For each line of 150 hashes, curl API
# Format jq.data, too entries[], select key(s) (hashes)
while IFS= read -r line; do
        temp=$(curl -s -H "Authorization: Bearer $apitoken" https://api.torbox.app/v1/api/torrents/checkcached?hash=$line&format=object&list_files=true)
        temp=$(echo $temp | jq .data)
        # If data isn't empty, select key (hash) and output as single lines to output.txt
        if [[ "$temp" != "{}" ]]
        then
                temp=$(echo $temp| jq -r 'to_entries[]' | jq -r ".key")
                echo $temp | tr -d ' ' | fold -w 40 >> $output
                echo $temp | tr -d ' ' | fold -w 40
        fi
done < $tempfile

rm $tempfile
