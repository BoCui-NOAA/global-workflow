#!/bin/bash

INCREMENT=12
FEND=180

# Use leading zero to indicate octal notation, so we need to remove it
AFEND=$((10#${FEND}))

# Calculate the result of dividing FEND by INCREMENT
for fort in {1..4}; do
    numfort=$((20 + fort + 4 * (AFEND / INCREMENT)))
    echo "numfort: $numfort"
    echo "AFEND / INCREMENT: $((AFEND / INCREMENT))"
done

echo
# Output the result
echo "The result of dividing $FEND by $INCREMENT is: $((AFEND / INCREMENT))"

