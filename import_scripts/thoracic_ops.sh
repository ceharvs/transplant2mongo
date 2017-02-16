#!/bin/bash

# Read in the directory of the original data and target database as command line args
DIRECTORY=$1
CLIENT=$2
DB=$3

# Specify Organ Information
Organ=Thoracic
ORGAN="${Organ^^}"

# Copy files over from the LIVER Directory
cp -r "$DIRECTORY"/"$Organ"/* data/.

# Flatten the files
mv data/*/**/** data/.
mv data/*/** data/.

# Remove Directories
rm -rf data/*/

# Send the Thoracic data into Mongo 
python import_scripts/send2mongo.py $CLIENT $DB "$ORGAN"_DATA "$Organ" 

# Thoracic HLA
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_ADDTL_HLA "$Organ"_HLA "$Organ" TRR_ID_CODE

# Thoracic Immunosuppression Discharge
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_IMMUNO_DISCHARGE_DATA "$Organ"_Immuno_Discharge "$Organ" TRR_ID_CODE

# Thoracic Immunosuppression Followup
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_IMMUNO_FOLLOWUP_DATA "$Organ"_Immuno_Followup "$Organ" TRR_ID_CODE -m

# Thoracic Followup Data
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_FOLLOWUP_DATA "$Organ"_Followup "$Organ" TRR_ID_CODE -m

# Thoracic Malignancy Followup Data
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_MALIG_FOLLOWUP_DATA "$Organ"_Malig_Followup "$Organ" TRR_ID_CODE -m

# Thoracic PRA and Crossmatch Data
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_PRA_CROSSMATCH_DATA "$Organ"_PRA "$Organ" TRR_ID_CODE

# Thoracic Waiting List History
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_WLHISTORY_DATA "$Organ"_WL_History "$Organ" WL_ID_CODE -m

# Thoracic MCS Device Data
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_MCS_DEVICE "$Organ"_MCS_DEVICE "$Organ" WL_ID_CODE -m 

# Thoracic WL-LAS Data
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_LAS_AUDIT_DATA "$Organ"_LAS_Audit "$Organ" WL_ID_CODE -m 
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_LAS_HISTORY_DATA "$Organ"_LAS_History "$Organ" WL_ID_CODE -m 

# Thoracic WL-Status Justification Data
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_STAT1A "$Organ"_Stat1A "$Organ" WL_ID_CODE -m 
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_STAT1B "$Organ"_Stat1B "$Organ" WL_ID_CODE -m
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_VAD_IMPLANT_DATES "$Organ"_VAD_Implant "$Organ" WL_ID_CODE -m

# Clear Files
rm data/"$ORGAN"*

echo "--------------------------------------"
echo " "
echo "$Organ Data Import Completed"
echo " "
echo "--------------------------------------"
