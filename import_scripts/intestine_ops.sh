#!/bin/bash

# Read in the directory of the original data and target database as command line args
DIRECTORY=$1
CLIENT=$2
DB=$3

# Specify Organ Information
Organ=Intestine
ORGAN="${Organ^^}"

echo "--------------------------------------"
echo "Beginning $ORGAN Data Import"
echo ""

# Copy files over from the LIVER Directory
echo -e "\t- Copying over data from files to local directory..."
cp -r "$DIRECTORY"/"$Organ"/* data/.

# Flatten the files and remove sub-directories
echo -e "\t- Flattening data files..."
mv data/*/** data/.
rm -rf data/*/

# Send the Intestine Data into Mongo 
echo -e "\t- Parsing $ORGAN data and inserting into MongoDB..."
python import_scripts/add_patients.py $CLIENT $DB "$ORGAN"_DATA "$Organ" 

# Intestine HLA
echo -e "\t- Parsing HLA data for $ORGAN and inserting into MongoDB..."
python import_scripts/supplemental_data.py $CLIENT $DB "$ORGAN"_ADDTL_HLA "$Organ"_HLA "$Organ" TRR_ID_CODE

# Intestine Immunosuppression Discharge
echo -e "\t- Parsing Immunosuppression Discharge data for $ORGAN and inserting into MongoDB..."
python import_scripts/supplemental_data.py $CLIENT $DB "$ORGAN"_IMMUNO_DISCHARGE_DATA "$Organ"_Immuno_Discharge "$Organ" TRR_ID_CODE

# Intestine Immunosuppression Followup
echo -e "\t- Parsing Immunosuppression Follow-up data for $ORGAN and inserting into MongoDB..."
python import_scripts/supplemental_data.py $CLIENT $DB "$ORGAN"_IMMUNO_FOLLOWUP_DATA "$Organ"_Immuno_Followup "$Organ" TRR_ID_CODE -m

# Intestine Followup Data
echo -e "\t- Parsing Follow-up data for $ORGAN and inserting into MongoDB..."
python import_scripts/supplemental_data.py $CLIENT $DB "$ORGAN"_FOLLOWUP_DATA "$Organ"_Followup "$Organ" TRR_ID_CODE -m

# Intestine Malignancy Followup Data
echo -e "\t- Parsing Malignancy Follow-up data for $ORGAN and inserting into MongoDB..."
python import_scripts/supplemental_data.py $CLIENT $DB "$ORGAN"_MALIG_FOLLOWUP_DATA "$Organ"_Malig_Followup "$Organ" TRR_ID_CODE -m

# Intestine PRA and Crossmatch Data
echo -e "\t- Parsing PRA and Crossmatch data for $ORGAN and inserting into MongoDB..."
python import_scripts/supplemental_data.py $CLIENT $DB "$ORGAN"_PRA_CROSSMATCH_DATA "$Organ"_PRA "$Organ" TRR_ID_CODE

# Intestine Waiting List History
echo -e "\t- Parsing Waiting List History data for $ORGAN and inserting into MongoDB..."
python import_scripts/supplemental_data.py $CLIENT $DB "$ORGAN"_WLHISTORY_DATA "$Organ"_WL_History "$Organ" WL_ID_CODE -m

# Clear Files
echo -e "\t- Cleaning up data files..."
rm data/"$ORGAN"*

# Add age groupings to the documents in the database
echo -e "\t- Creating Age groupings for the patients in the database"
python import_scripts/age_groups.py $CLIENT $DB Intestine INIT_AGE INIT_AGE_BIN
python import_scripts/age_groups.py $CLIENT $DB Intestine AGE AGE_BIN

echo " "
echo "$Organ Data Import Completed"
echo "--------------------------------------"
