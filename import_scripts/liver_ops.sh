#!/bin/bash

# Read in the directory of the original data and target database as command line args
DIRECTORY=$1
CLIENT=$2
DB=$3

# Specify Organ Information
Organ=Liver
ORGAN="${Organ^^}"

# Copy files over from the LIVER Directory
cp -r "$DIRECTORY"/"$Organ"/* data/.

# Flatten the files
mv data/*/**/** data/.
mv data/*/** data/.

# Remove Directories
rm -rf data/*/

# Send the Liver Data into Mongo 
python import_scripts/send2mongo.py $CLIENT $DB "$ORGAN"_DATA "$Organ" 

# Explant Data - Only for LIVER Patients
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_EXPLANT_DATA "$Organ"_Explant "$Organ" TRR_ID_CODE

# Liver HLA
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_ADDTL_HLA "$Organ"_HLA "$Organ" TRR_ID_CODE

# Liver Immunosuppression Discharge
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_IMMUNO_DISCHARGE_DATA "$Organ"_Immuno_Discharge "$Organ" TRR_ID_CODE

# Liver Immunosuppression Followup
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_IMMUNO_FOLLOWUP_DATA "$Organ"_Immuno_Followup "$Organ" TRR_ID_CODE -m

# Remove the unnecessary Vertical Tabs
mv data/"$ORGAN"_FOLLOWUP_DATA.DAT data/"$ORGAN"_FOLLOWUP_DATA_orig.DAT
cat data/"$ORGAN"_FOLLOWUP_DATA_orig.DAT | tr '\v' ' ' > data/"$ORGAN"_FOLLOWUP_DATA.DAT
rm data/"$ORGAN"_FOLLOWUP_DATA_orig.DAT
# Liver Followup Data
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_FOLLOWUP_DATA "$Organ"_Followup "$Organ" TRR_ID_CODE -m

# Liver Malignancy Followup Data
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_MALIG_FOLLOWUP_DATA "$Organ"_Malig_Followup "$Organ" TRR_ID_CODE -m

# Liver PRA and Crossmatch Data
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_PRA_CROSSMATCH_DATA "$Organ"_PRA "$Organ" TRR_ID_CODE

# Liver Waiting List History
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_WLHISTORY_DATA "$Organ"_WL_History "$Organ" WL_ID_CODE -m

# Waiting List Exception History - Only for Liver
python import_scripts/add2mongo.py $CLIENT $DB "$ORGAN"_EXCEPTION_DATA "$Organ"_Exception "$Organ" WL_ID_CODE -m

# Clear Files
rm data/"$ORGAN"*

echo "---------------------------------------"
echo " "
echo "$Organ Data Import Completed"
echo " "
echo "---------------------------------------"


