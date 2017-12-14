# Path to the "Delimited Test File" directory for the UNOS data
# EDIT This to use another data path
ORIGINAL_UNOS_DATA=sample-data/Delimited Text File/

# Path to localized working directory for the data
LINKED_DIRECTORY=organ_data_link

# Describe the client and the database to be used.
# Edit this section if you do not want to use the default database
CLIENT=localhost
DB=organs_data_12012017

# Define the database components to be made
COMPONENTS=deceased living

all: prep $(COMPONENTS) 

prep:
	@echo "Preparing for data import..."
	@echo "- Dropping Database"
	@- mongo $(CLIENT)/$(DB) --eval "db.dropDatabase()"
	@echo "- Creating Links and Directories"
	@- ln -s "$(ORIGINAL_UNOS_DATA)" $(LINKED_DIRECTORY)
	@- mkdir data

deceased:
	@echo ""
	@echo "--------------------------------------"
	@echo "Beginning Deceased Donor Data Import"

	@echo "- Copying over data from files to local directory..."
	@cp -r "$(LINKED_DIRECTORY)"/"Deceased Donor"/* data/.

	@echo "- Flattening data files..."
	@mv data/*/** data/.

	@echo "- Parsing Deceased Donor data and inserting into MongoDB..."
	@python import_scripts/add_patients.py $(CLIENT) $(DB) DECEASED_DONOR_DATA Deceased_Donor -u DONOR_ID

	@echo "- Parsing inotropic medication data for Deceased Donors and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(CLIENT) $(DB) DECEASED_DONOR_INOTROPIC_MEDS Inotropic_Meds Deceased_Donor DONOR_ID

	@echo "- Cleaning up data files..."
	@rm data/"DECEASED_DONOR"*

	@echo "- Creating Age groupings for the donors in the database"
	@python import_scripts/age_groups.py $(CLIENT) $(DB) Living_Donor AGE_DON AGE_BIN

	@echo "Deceased Donor Data Import Complete"
	@echo "--------------------------------------"

living:
	@echo ""
	@echo "--------------------------------------"
	@echo "Beginning Living Donor Data Import"

	@echo "- Copying over data from files to local directory..."
	@cp -r "$(LINKED_DIRECTORY)"/"Living Donor"/* data/.

	@echo "- Flattening data files..."
	@mv data/*/** data/.

	@echo " -Parsing Living Donor data and inserting into MongoDB..."
	@python import_scripts/add_patients.py $(CLIENT) $(DB) LIVING_DONOR_DATA Living_Donor -u DONOR_ID

	@echo "- Parsing Follow-Up data for Living Donors and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(CLIENT) $(DB) LIVING_DONOR_FOLLOWUP_DATA Living_Donor_Follow Living_Donor DONOR_ID -m
	
	@echo "- Cleaning up data files..."
	@rm data/"LIVING_DONOR"*

	@echo "- Creating Age groupings for the donors in the database"
	@python import_scripts/age_groups.py $(CLIENT) $(DB) Deceased_Donor AGE_DON AGE_BIN

	@echo "Living Donor Data Import Complete"
	@echo "--------------------------------------"

clean:
	- rm -rf $(LINKED_DIRECTORY)
	- rm -rf data
