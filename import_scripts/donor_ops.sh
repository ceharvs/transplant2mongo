#!/bin/bash

# Read in the directory of the original data and target database as command line args
DIRECTORY=$1
CLIENT=$2
DB=$3

echo "--------------------------------------"
echo "Beginning Donor Data Import"
echo ""

# Copy files over from the Directories
echo -e "\t- Copying over data from files to local directory..."
cp -r "$DIRECTORY"/"Deceased Donor"/* data/.
cp -r "$DIRECTORY"/"Living Donor"/* data/.

# Flatten files
echo -e "\t- Flattening data files..."
mv data/*/** data/.

# Complete Deceased Donor operations
# Run the Python code to generate the json and save to a file
echo -e "\t- Parsing Deceased Donor data and inserting into MongoDB..."
python import_scripts/add_patients.py $CLIENT $DB DECEASED_DONOR_DATA Deceased_Donor -u DONOR_ID

# Run the Python code to generate the Json and save to a file for the inotropic medications
echo -e "\t- Parsing inotropic medication data for Deceased Donors and inserting into MongoDB..."
python import_scripts/supplemental_data.py $CLIENT $DB DECEASED_DONOR_INOTROPIC_MEDS Inotropic_Meds Deceased_Donor DONOR_ID

# Run the Python code to generate the json and save to a file
echo -e "\t -Parsing Living Donor data and inserting into MongoDB..."
python import_scripts/add_patients.py $CLIENT $DB LIVING_DONOR_DATA Living_Donor -u DONOR_ID

# Run the Python code to generate the json and save to a file
echo -e "\t- Parsing Follow-Up data for Deceased Donors and inserting into MongoDB..."
python import_scripts/supplemental_data.py $CLIENT $DB LIVING_DONOR_FOLLOWUP_DATA Living_Donor_Follow Living_Donor DONOR_ID -m

# Remove files
echo -e "\t- Cleaning up data files..."
rm data/"DECEASED_DONOR"*
rm data/"LIVING_DONOR"*

# Add Age groups to the donors in the Database
echo -e "\t- Creating Age groupings for the donors in the database"
python import_scripts/age_groups.py $CLIENT $DB Living_Donor AGE_DON AGE_BIN
python import_scripts/age_groups.py $CLIENT $DB Deceased_Donor AGE_DON AGE_BIN

echo " "
echo "Donor Data Import Complete"
echo "--------------------------------------"

