# Torbox Availability Scanner
Scans files cached on Torbox and outputs hashes of cached files ready to be added

```
curl -s https://raw.githubusercontent.com/Reasonable-Grape2698/torbox_dmm_availability_scanner/refs/heads/main/script.sh | bash -s -- -a (APIKEY)
```

| Flag | Description |
| ---- | ----------- |
| -a | **Required** API Key
| -o | Output file (default output.txt)
| -i | Input file (Default dmm.json)
