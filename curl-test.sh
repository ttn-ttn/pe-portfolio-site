#!/usr/bin/env bash
set -euo pipefail

HOST='localhost'
PORT='5000'
ENDPOINT='timeline_post'
URL="http://$HOST:$PORT/api/$ENDPOINT"

NUM_POSTS_OLD=$(curl -sS -X GET "$URL" | jq '.timeline_posts | length')

ID=$(curl -sS -X POST "$URL" -d 'name=Tomas&email=tomas@tomas&content=This is a test' | jq '.id')

COUNT=$(curl -sS -X GET "$URL" -d "id=$ID" | jq '.timeline_posts | length')

(( COUNT == 1 )) || { echo "GET for id $ID returned $COUNT posts, expected 1"; exit 1; }

NUM_POSTS_NEW=$(curl -sS -X GET "$URL" | jq '.timeline_posts | length')

(( NUM_POSTS_NEW == (NUM_POSTS_OLD + 1) )) || { echo "GET returned $NUM_POSTS_NEW posts instead of $((NUM_POSTS_OLD + 1))"; exit 1; }

STATUS=$(curl -sS -o /dev/null -w '%{http_code}' -X DELETE "$URL" -d "id=$ID")

(( STATUS == 200 )) || { echo "DELETE for id $ID failed with status $STATUS"; exit 1; }

STATUS=$(curl -sS -o /dev/null -w '%{http_code}' -X DELETE "$URL" -d "id=$ID")

(( STATUS != 200 )) || { echo "DELETE for id $ID returned status $STATUS, but its deletion had already succeeded"; exit 1; }

COUNT=$(curl -sS -X GET "$URL" -d "id=$ID" | jq '.timeline_posts | length')

(( COUNT == 0 )) || { echo "GET for id $ID returned $COUNT posts, but its deletion had already succeeded"; exit 1; }

echo "Tests for endpoint $ENDPOINT succeeded!"
