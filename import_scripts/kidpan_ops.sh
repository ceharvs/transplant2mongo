#!/bin/bash

# Read in the directory of the original data and target database as command line args
DIRECTORY=$1
CLIENT=$2
DB=$3

# Specity Organ Infromation
Organ="Kidney_ Pancreas_ Kidney-Pancreas"
ORGAN="KIDPAN"

# Copy files over from the LIVER Directory
cp -r "$DIRECTORY"/"$Organ"/* data/.

Organ="Kidney_Pancreas"

# Flatten the files
mv data/*/** data/.

# Remove Directories
rm -rf data/*/

# Send the Kidney-Pancreas Data into Mongo 
python import_scripts/send2mongo.py $CLIENT $DB "$ORGAN"_DATA "$Organ" 

# Kidney-Pancreas HLA
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_ADDTL_HLA "$Organ"_HLA "$Organ" TRR_ID_CODE

# Kidney-Pancreas Immunosuppression Discharge
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_IMMUNO_DISCHARGE_DATA "$Organ"_Immuno_Discharge "$Organ" TRR_ID_CODE

# Kidney-Pancreas Immunosuppression Followup
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_IMMUNO_FOLLOWUP_DATA "$Organ"_Immuno_Followup "$Organ" TRR_ID_CODE -m

# KIDPAN Followup Data
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_FOLLOWUP_DATA "$Organ"_Followup "$Organ" TRR_ID_CODE -m
python import_scripts/add2mongo.py $CLIENT $DB KIDNEY_FOLLOWUP_DATA Kidney_Followup "$Organ" TRR_ID_CODE -m
python import_scripts/add2mongo.py $CLIENT $DB PANCREAS_FOLLOWUP_DATA Pancreas_Followup "$Organ" TRR_ID_CODE -m

# Kidney-Pancreas Malignancy Followup Data
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_MALIG_FOLLOWUP_DATA "$Organ"_Malig_Followup "$Organ" TRR_ID_CODE -m
python import_scripts/add2mongo.py $CLIENT $DB KIDNEY_MALIG_FOLLOWUP_DATA Kidney_Malig_Followup "$Organ" TRR_ID_CODE -m
python import_scripts/add2mongo.py $CLIENT $DB PANCREAS_MALIG_FOLLOWUP_DATA Pancreas_Malig_Followup "$Organ" TRR_ID_CODE -m

# Kidney/Pancreas PRA and Crossmatch Data
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_PRA_CROSSMATCH_DATA "$Organ"_PRA "$Organ" TRR_ID_CODE

# Kidney/Pancreas Waiting List History
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_WLHISTORY_DATA "$Organ"_WL_History "$Organ" WL_ID_CODE -m

# Clear Files
rm data/"$ORGAN"*
rm data/KIDNEY*
rm data/PANCREAS*


echo "---------------------------------------"
echo " "
echo "$Organ Data Import Completed"
echo " "
echo "---------------------------------------"


