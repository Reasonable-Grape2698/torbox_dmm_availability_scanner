temp=''
input="output.txt"

while getopts a:i:o: flag
do
    case "${flag}" in
        a) apitoken=${OPTARG};;
        i) input=${OPTARG};;
    esac
done

percentile=100
tasks_in_total=$(cat $input | wc -l)
count=0

# For each hash, call API to add torrent and remove from file
while read line; do
        temp=$(curl -s -H "Authorization: Bearer $apitoken" https://api.torbox.app/v1/api/torrents/createtorrent -F magnet="magnet:?xt=urn:btih:$line")

        while [[ "$temp" == "rate limit exceeded." ]];
        do
                echo "Rate limit exceeded. Sleeping 60s and retrying"
                sleep 60
                temp=$(curl -s -H "Authorization: Bearer $apitoken" https://api.torbox.app/v1/api/torrents/createtorrent -F magnet="magnet:?xt=urn:btih:$line")
        done

        sed -i "/$line/d" $input
        count=$(echo $count+1 | bc)
        percent="$(echo "$count" "$tasks_in_total" |awk '{printf "%.2f", $1 * 100 / $2}')"
        echo "$count / $tasks_in_total $percent %"
        sleep 1
done < $input
