# Path to the "Delimited Test File" directory for the UNOS data
ORIGINAL_UNOS_DATA="sample-data/Delimited Text File/"

# Path to localized working directory for the data
LINKED_DIRECTORY="organ_data_link"

# Generate a symbolic link between the original UNOS data and the working data
ln -s "$ORIGINAL_UNOS_DATA" $LINKED_DIRECTORY

# Describe the client and the database to be used.
CLIENT="localhost"
DB="organs_data_12012017"

# Make a temporary storage folder for the data
mkdir data

# Import Donor Information
sh import_scripts/donor_ops.sh $LINKED_DIRECTORY $CLIENT $DB

# Import Intestine Information
sh import_scripts/intestine_ops.sh $LINKED_DIRECTORY $CLIENT $DB

# Import Liver Information
#sh import_scripts/liver_ops.sh $LINKED_DIRECTORY $CLIENT $DB

# Import Thoracic Information
#sh import_scripts/thoracic_ops.sh $LINKED_DIRECTORY $CLIENT $DB

# Import Kidney/Pancreas Information
#sh import_scripts/kidpan_ops.sh $LINKED_DIRECTORY $CLIENT $DB

rm -rf data/
