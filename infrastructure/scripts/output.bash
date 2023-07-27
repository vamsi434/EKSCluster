#!/bin/bash
cd ..
echo -e "Key\t\t\t\t\tValue\n---\t\t\t\t\t-----\n$(terraform output -json | jq -r 'keys_unsorted[] as $key | "\($key)\t\(.[$key].value)"' | column -t -s $'\t')"
