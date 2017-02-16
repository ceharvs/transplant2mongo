#!/bin/bash

# Read in the directory of the original data and target database as command line args
DIRECTORY=$1
CLIENT=$2
DB=$3

# Copy files over from the Directories
cp -r "$DIRECTORY"/"Deceased Donor"/* data/.
cp -r "$DIRECTORY"/"Living Donor"/* data/.

# Flatten files
mv data/*/** data/.

# Complete Deceased Donor operations
# Run the Python code to generate the json and save to a file
python import_scripts/send2mongo.py $CLIENT $DB DECEASED_DONOR_DATA Deceased_Donor -u DONOR_ID

# Run the Python code to generate the Json and save to a file
python import_scripts/add2mongo.py $CLIENT $DB DECEASED_DONOR_INOTROPIC_MEDS Inotropic_Meds Deceased_Donor DONOR_ID

# Run the Python code to generate the json and save to a file
python import_scripts/send2mongo.py $CLIENT $DB LIVING_DONOR_DATA Living_Donor -u DONOR_ID

# Run the Python code to generate the json and save to a file
python import_scripts/add2mongo.py $CLIENT $DB LIVING_DONOR_FOLLOWUP_DATA Living_Donor_Follow Living_Donor DONOR_ID -m

# Remove files
rm data/"DECEASED_DONOR"*
rm data/"LIVING_DONOR"*

echo "--------------------------------------"
echo " "
echo "Donor Data Import Complete"
echo " "
echo "--------------------------------------"

