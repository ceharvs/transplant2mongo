# Path to the "Delimited Test File" directory for the UNOS data
ORIGINAL_UNOS_DATA="sample-data/Delimited Text File/"

# Path to localized working directory for the data
LINKED_DIRECTORY="organ_data_link"

# Describe the client and the database to be used.
CLIENT="localhost"
DB="organs_data_12012017"

all: prep donors 

prep:
	- drop db
	- ln -s "$(ORIGINAL_UNOS_DATA)" $(LINKED_DIRECTORY)
	- mkdir data

donors:
	echo -e "--------------------------------------"
	echo -e "Beginning Donor Data Import"
	echo -e ""

	echo -e "\t- Copying over data from files to local directory..."
	cp -r "$DIRECTORY"/"Deceased Donor"/* data/.
	cp -r "$DIRECTORY"/"Living Donor"/* data/.

	echo -e "\t- Flattening data files..."
	mv data/*/** data/.

	echo -e "\t- Parsing Deceased Donor data and inserting into MongoDB..."
	python import_scripts/add_patients.py $CLIENT $DB DECEASED_DONOR_DATA Deceased_Donor -u DONOR_ID

	echo -e "\t- Parsing inotropic medication data for Deceased Donors and inserting into MongoDB..."
	python import_scripts/supplemental_data.py $CLIENT $DB DECEASED_DONOR_INOTROPIC_MEDS Inotropic_Meds Deceased_Donor DONOR_ID

	echo -e "\t -Parsing Living Donor data and inserting into MongoDB..."
	python import_scripts/add_patients.py $CLIENT $DB LIVING_DONOR_DATA Living_Donor -u DONOR_ID

	echo -e "\t- Parsing Follow-Up data for Living Donors and inserting into MongoDB..."
	python import_scripts/supplemental_data.py $CLIENT $DB LIVING_DONOR_FOLLOWUP_DATA Living_Donor_Follow Living_Donor DONOR_ID -m

	echo -e "\t- Cleaning up data files..."
	rm data/"DECEASED_DONOR"*
	rm data/"LIVING_DONOR"*

	echo -e "\t- Creating Age groupings for the donors in the database"
	python import_scripts/age_groups.py $CLIENT $DB Living_Donor AGE_DON AGE_BIN
	python import_scripts/age_groups.py $CLIENT $DB Deceased_Donor AGE_DON AGE_BIN

	echo -e " "
	echo -e "Donor Data Import Complete"
	echo -e "--------------------------------------"

clean:
	- rm -rf $(LINKED_DIRECTORY)
	- rm -rf data
