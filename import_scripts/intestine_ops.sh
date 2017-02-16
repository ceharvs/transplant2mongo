#!/bin/bash

# Read in the directory of the original data and target database as command line args
DIRECTORY=$1
CLIENT=$2
DB=$3

# Specify Organ Information
Organ=Intestine
ORGAN="${Organ^^}"

# Copy files over from the LIVER Directory
cp -r "$DIRECTORY"/"$Organ"/* data/.

# Flatten the files
mv data/*/** data/.

# Remove Directories
rm -rf data/*/

# Send the Intestine Data into Mongo 
python import_scripts/send2mongo.py $CLIENT $DB "$ORGAN"_DATA "$Organ" 

# Intestine HLA
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_ADDTL_HLA "$Organ"_HLA "$Organ" TRR_ID_CODE

# Intestine Immunosuppression Discharge
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_IMMUNO_DISCHARGE_DATA "$Organ"_Immuno_Discharge "$Organ" TRR_ID_CODE

# Intestine Immunosuppression Followup
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_IMMUNO_FOLLOWUP_DATA "$Organ"_Immuno_Followup "$Organ" TRR_ID_CODE -m

# Intestine Followup Data
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_FOLLOWUP_DATA "$Organ"_Followup "$Organ" TRR_ID_CODE -m

# Intestine Malignancy Followup Data
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_MALIG_FOLLOWUP_DATA "$Organ"_Malig_Followup "$Organ" TRR_ID_CODE -m

# Intestine PRA and Crossmatch Data
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_PRA_CROSSMATCH_DATA "$Organ"_PRA "$Organ" TRR_ID_CODE

# Intestine Waiting List History
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_WLHISTORY_DATA "$Organ"_WL_History "$Organ" WL_ID_CODE -m

# Clear Files
rm data/"$ORGAN"*

echo "--------------------------------------"
echo " "
echo "$Organ Data Import Completed"
echo " "
echo "--------------------------------------"
