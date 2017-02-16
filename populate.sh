# Path to the "Delimited Test File" directory for the UNOS data
ORIGINAL_UNOS_DATA="<path_to_UNOS_data>/Delimited\ Test\ File\ 201406/Delimited\ Test\ File/"

# Path to localized working directory for the data
DIRECTORY="/mnt/project/organ/test/organ_data_201503"

# Generate a symbolic link between the original UNOS data and the working data
ln -s $ORIGINAL_UNOS_DATA $DIRECTORY

# Describe the client and the database to be used.
CLIENT="organ-db.etlab.mitre.org"
DB="organs_201503"

# Import Donor Information
sh transplant2mongo/import_scripts/donor_ops.sh $DIRECTORY $CLIENT $DB
# Add Age groups to the donors in the Database
python import_scripts/age_groups.py $CLIENT $DB Living_Donor AGE_DON AGE_BIN
python import_scripts/age_groups.py $CLIENT $DB Deceased_Donor AGE_DON AGE_BIN

# Import Intestine Information
sh transplant2mongo/import_scripts/intestine_ops.sh $DIRECTORY $CLIENT $DB
# Add age groupings to the documents in the database
python import_scripts/age_groups.py $CLIENT $DB Intestine INIT_AGE INIT_AGE_BIN
python import_scripts/age_groups.py $CLIENT $DB Intestine AGE AGE_BIN

# Import Liver Information
sh transplant2mongo/import_scripts/liver_ops.sh $DIRECTORY $CLIENT $DB
# Add age groupings to the documents in the database
python import_scripts/age_groups.py $CLIENT $DB Liver INIT_AGE INIT_AGE_BIN
python import_scripts/age_groups.py $CLIENT $DB Liver AGE AGE_BIN

# Import Thoracic Information
sh transplant2mongo/import_scripts/thoracic_ops.sh $DIRECTORY $CLIENT $DB
# Add age groupings to the documents in the database
python import_scripts/age_groups.py $CLIENT $DB Thoracic INIT_AGE INIT_AGE_BIN
python import_scripts/age_groups.py $CLIENT $DB Thoracic AGE AGE_BIN

# Import Kidney/Pancreas Information
sh transplant2mongo/import_scripts/kidpan_ops.sh $DIRECTORY $CLIENT $DB
# Add age groupings to the documents in the database
python import_scripts/age_groups.py $CLIENT $DB Kidney_Pancreas INIT_AGE INIT_AGE_BIN
python import_scripts/age_groups.py $CLIENT $DB Kidney_Pancreas AGE AGE_BIN