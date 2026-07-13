#!/bin/bash

URL="http://localhost:5000/api/timeline_post"

echo "1. Testing POST: Creating a random timeline post"

CREATE_RESPONSE=$(curl -s -X POST $URL \
  -d "name=Ida" \
  -d "email=wei.he@mlh.io" \
  -d "content=Just added to my portfolio site!")

echo "Response from server:"
echo "$CREATE_RESPONSE"
echo ""

echo "2. Testing GET: Fetching all timeline posts"
curl -s -X GET $URL
echo -e "\n"

# Bonus
POST_ID=$(echo "$CREATE_RESPONSE" | grep -o '"id": [0-9]*' | awk '{print $2}')

if [ -n "$POST_ID" ]; then
  echo "3. BONUS: Testing DELETE: Removing the test post (ID: $POST_ID)"
  curl -s -X DELETE "$URL/$POST_ID"
  echo -e "\nSuccessfully deleted post $POST_ID. Cleanup complete!"
else
  echo "Could not extract a valid POST ID for deletion. Ensure your POST endpoint returns the created 'id'."
fi