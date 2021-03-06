#################################################################
#
# Makefile for transplant2mongo
#
# To use the Makefile with a different MongoDB server location,
# UNOS Data Source, database name, or components, please edit
# the corresponding lines below.  Full instructions are in the
# README.md file.
#
#################################################################

#################################################################
# User-defined parameters
#
# Path to the "Delimited Test File" directory for the UNOS data
# obtained from the OPTN. Edit to use another directory.
UNOS_DATA=sample-data/Delimited Text File/

# Define the database components to be made based on data obtained
# from the OPTN. Default assumes all components were obtained
# from the OPTN
COMPONENTS=deceased living intestine kidpan liver thoracic

# MongoDB server address
SERVER=localhost:27017

# DB name
DB=organ_data

# Path to localized working directory for the data
LINKED_DIRECTORY=organ_data_link
#################################################################

# Set the ctype to allow "tr" to work on Mac
export LC_CTYPE=C

# Define the Python and MongoDB Libraries to use
MONGO := $(shell command -v mongo 2> /dev/null)
PYTHON := $(shell command -v python 2> /dev/null)

all: prep $(COMPONENTS) clean

prep:
	@echo "Preparing for data import..."

	@echo "$(MONGO)"

	@echo "- Check that mongo is available ..."
	$(if $(MONGO),,$(error Must install or set mongo in PATH))
	@echo " - MongoDB is available."

	$(if $(PYTHON),,$(error Must set Python in PATH))
	@echo " - Python is installed and in the PATH"

	@echo "- Looking for a running MongoDB Server at $(SERVER)"
	@mongo --eval 'db.stats()' > /dev/null 2>&1
	@echo " - MongoDB server is running at $(SERVER)."

	@echo "- Dropping Database"
	@- mongo $(SERVER)/$(DB) --eval "db.dropDatabase()"

	@echo "- Creating Links and Directories"
	@- ln -sf "$(UNOS_DATA)" $(LINKED_DIRECTORY)
	@- mkdir -p data

deceased:
	@echo ""
	@echo "--------------------------------------"
	@echo "Beginning Deceased Donor Data Import"

	@echo "- Copying over data from files to local directory..."
	@cp -r "$(LINKED_DIRECTORY)"/"Deceased Donor"/* data/.

	@echo "- Flattening data files..."
	@mv data/*/** data/.

	@echo "- Parsing Deceased Donor data and inserting into MongoDB..."
	@python import_scripts/add_patients.py $(SERVER) $(DB) DECEASED_DONOR_DATA Deceased_Donor -u DONOR_ID

	@echo "- Parsing inotropic medication data for Deceased Donors and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) DECEASED_DONOR_INOTROPIC_MEDS Inotropic_Meds Deceased_Donor DONOR_ID

	@echo "- Cleaning up data files..."
	@rm data/"DECEASED_DONOR"*

	@echo "- Creating Age groupings for the donors in the database"
	@python import_scripts/age_groups.py $(SERVER) $(DB) Deceased_Donor AGE_DON AGE_BIN

	@echo ""
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
	@python import_scripts/add_patients.py $(SERVER) $(DB) LIVING_DONOR_DATA Living_Donor -u DONOR_ID

	@echo "- Parsing Follow-Up data for Living Donors and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) LIVING_DONOR_FOLLOWUP_DATA Living_Donor_Follow Living_Donor DONOR_ID -m

	@echo "- Cleaning up data files..."
	@rm data/"LIVING_DONOR"*

	@echo "- Creating Age groupings for the donors in the database"
	@python import_scripts/age_groups.py $(SERVER) $(DB) Living_Donor AGE_DON AGE_BIN

	@echo ""
	@echo "Living Donor Data Import Complete"
	@echo "--------------------------------------"

intestine:
	@echo ""
	@echo "--------------------------------------"
	@echo "Beginning Intestine Data Import"

	@echo "- Copying over data from files to local directory..."
	@cp -r $(LINKED_DIRECTORY)/Intestine/* data/.

	@echo "- Flattening data files..."
	@mv data/*/** data/.
	@rm -rf data/*/

	# Intestine Data
	@echo "- Parsing INTESTINE data and inserting into MongoDB..."
	@python import_scripts/add_patients.py $(SERVER) $(DB) INTESTINE_DATA Intestine

	# Intestine HLA Data
	@echo "- Parsing HLA data for INTESTINE and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) INTESTINE_ADDTL_HLA Intestine_HLA Intestine TRR_ID_CODE

	# Intestine Immunosuppression Discharge
	@echo "- Parsing Immunosuppression Discharge data for INTESTINE and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) INTESTINE_IMMUNO_DISCHARGE_DATA Intestine_Immuno_Discharge Intestine TRR_ID_CODE

	# Intestine Immunosuppression Followup
	@echo "- Parsing Immunosuppression Follow-up data for INTESTINE and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) INTESTINE_IMMUNO_FOLLOWUP_DATA Intestine_Immuno_Followup Intestine TRR_ID_CODE -m

	# Intestine Followup Data
	@echo "- Parsing Follow-up data for INTESTINE and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) INTESTINE_FOLLOWUP_DATA Intestine_Followup Intestine TRR_ID_CODE -m

	# Intestine Malignancy Followup Data
	@echo "- Parsing Malignancy Follow-up data for INTESTINE and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) INTESTINE_MALIG_FOLLOWUP_DATA Intestine_Malig_Followup Intestine TRR_ID_CODE -m

	# Intestine PRA and Crossmatch Data
	@echo "- Parsing PRA and Crossmatch data for INTESTINE and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) INTESTINE_PRA_CROSSMATCH_DATA Intestine_PRA Intestine TRR_ID_CODE

	# Intestine Waiting List History
	@echo "- Parsing Waiting List History data for INTESTINE and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) INTESTINE_WLHISTORY_DATA Intestine_WL_History Intestine WL_ID_CODE -m

	# Clear Files
	@echo "- Cleaning up data files..."
	@rm data/INTESTINE*

	# Add age groupings to the documents in the database
	@echo "- Creating Age groupings for the patients in the database"
	@python import_scripts/age_groups.py $(SERVER) $(DB) Intestine INIT_AGE INIT_AGE_BIN
	@python import_scripts/age_groups.py $(SERVER) $(DB) Intestine AGE AGE_BIN

	@echo ""
	@echo "Intestine Data Import Complete"
	@echo "--------------------------------------"

kidpan:
	@echo ""
	@echo "--------------------------------------"
	@echo "Beginning Kiney and Pancreas Data Import"

	@echo "- Copying over data from files to local directory..."
	@cp -r "$(LINKED_DIRECTORY)"/"Kidney_ Pancreas_ Kidney-Pancreas"/* data/.

	@echo "- Flattening data files..."
	@mv data/*/** data/.
	@rm -rf data/*/

	# Send the Kidney-Pancreas Data into Mongo
	@echo "- Parsing KIDPAN data and inserting into MongoDB..."
	@python import_scripts/add_patients.py $(SERVER) $(DB) KIDPAN_DATA Kidney_Pancreas

	# Kidney-Pancreas HLA
	@echo "- Parsing HLA data for KIDPAN and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) KIDPAN_ADDTL_HLA Kidney_Pancreas_HLA Kidney_Pancreas TRR_ID_CODE

	# Kidney-Pancreas Immunosuppression Discharge
	@echo "- Parsing Immunosuppression Discharge data for KIDPAN and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) KIDPAN_IMMUNO_DISCHARGE_DATA Kidney_Pancreas_Immuno_Discharge Kidney_Pancreas TRR_ID_CODE

	# Kidney-Pancreas Immunosuppression Followup
	@echo "- Parsing Immunosuppression Follow-up data for KIDPAN and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) KIDPAN_IMMUNO_FOLLOWUP_DATA Kidney_Pancreas_Immuno_Followup Kidney_Pancreas TRR_ID_CODE -m

	# Kidney-Pancreas Followup Data
	@echo "- Parsing Follow-up data for KIDPAN and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) KIDPAN_FOLLOWUP_DATA Kidney_Pancreas_Followup Kidney_Pancreas TRR_ID_CODE -m
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) KIDNEY_FOLLOWUP_DATA Kidney_Followup Kidney_Pancreas TRR_ID_CODE -m
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) PANCREAS_FOLLOWUP_DATA Pancreas_Followup Kidney_Pancreas TRR_ID_CODE -m

	# Kidney-Pancreas Malignancy Followup Data
	@echo "- Parsing Malignancy Follow-up data for KIDPAN and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) KIDPAN_MALIG_FOLLOWUP_DATA Kidney_Pancreas_Malig_Followup Kidney_Pancreas TRR_ID_CODE -m
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) KIDNEY_MALIG_FOLLOWUP_DATA Kidney_Malig_Followup Kidney_Pancreas TRR_ID_CODE -m
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) PANCREAS_MALIG_FOLLOWUP_DATA Pancreas_Malig_Followup Kidney_Pancreas TRR_ID_CODE -m

	# Kidney/Pancreas PRA and Crossmatch Data
	@echo "- Parsing PRA and Crossmatch data for KIDPAN and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) KIDPAN_PRA_CROSSMATCH_DATA Kidney_Pancreas_PRA Kidney_Pancreas TRR_ID_CODE

	# Kidney/Pancreas Waiting List History
	@echo "- Parsing Waiting List History data for KIDPAN and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) KIDPAN_WLHISTORY_DATA Kidney_Pancreas_WL_History Kidney_Pancreas WL_ID_CODE -m

	# Clear Files
	@echo "- Cleaning up data files..."
	@rm data/KIDPAN*
	@rm data/KIDNEY*
	@rm data/PANCREAS*

	# Add age groupings to the documents in the database
	@echo "- Creating Age groupings for the patients in the database"
	@python import_scripts/age_groups.py $(SERVER) $(DB) Kidney_Pancreas INIT_AGE INIT_AGE_BIN
	@python import_scripts/age_groups.py $(SERVER) $(DB) Kidney_Pancreas AGE AGE_BIN

	@echo ""
	@echo "Kidney-Pancreas Data Import Complete"
	@echo "--------------------------------------"

liver:
	@echo ""
	@echo "--------------------------------------"
	@echo "Beginning Liver Data Import"

	@echo "- Copying over data from files to local directory..."
	@cp -r $(LINKED_DIRECTORY)/Liver/* data/.

	@echo "- Flattening data files..."
	@mv data/*/**/** data/.
	@mv data/*/** data/.
	@rm -rf data/*/

	# Send the Liver Data into Mongo
	@echo "- Parsing LIVER data and inserting into MongoDB..."
	@python import_scripts/add_patients.py $(SERVER) $(DB) LIVER_DATA Liver

	# Explant Data - Only for LIVER Patients
	@echo "- Parsing Explant data for LIVER and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) LIVER_EXPLANT_DATA Liver_Explant Liver TRR_ID_CODE

	# Liver HLA
	@echo "- Parsing HLA data for LIVER and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) LIVER_ADDTL_HLA Liver_HLA Liver TRR_ID_CODE

	# Liver Immunosuppression Discharge
	@echo "- Parsing Immunosuppression Discharge data for LIVER and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) LIVER_IMMUNO_DISCHARGE_DATA Liver_Immuno_Discharge Liver TRR_ID_CODE

	# Liver Immunosuppression Followup
	@echo "- Parsing Immunosuppression Follow-up data for LIVER and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) LIVER_IMMUNO_FOLLOWUP_DATA Liver_Immuno_Followup Liver TRR_ID_CODE -m

	# Remove the unnecessary Vertical Tabs
	@mv data/LIVER_FOLLOWUP_DATA.DAT data/LIVER_FOLLOWUP_DATA_orig.DAT
	@cat data/LIVER_FOLLOWUP_DATA_orig.DAT | tr '\v' ' ' > data/LIVER_FOLLOWUP_DATA.DAT
	@rm data/LIVER_FOLLOWUP_DATA_orig.DAT

	# Liver Followup Data
	@echo "- Parsing Follow-up data for LIVER and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) LIVER_FOLLOWUP_DATA Liver_Followup Liver TRR_ID_CODE -m

	# Liver Malignancy Followup Data
	@echo "- Parsing Malignancy Follow-up data for LIVER and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) LIVER_MALIG_FOLLOWUP_DATA Liver_Malig_Followup Liver TRR_ID_CODE -m

	# Liver PRA and Crossmatch Data
	@echo "- Parsing PRA and Crossmatch data for LIVER and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) LIVER_PRA_CROSSMATCH_DATA Liver_PRA Liver TRR_ID_CODE

	# Liver Waiting List History
	@echo "- Parsing Waiting List History data for LIVER and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) LIVER_WLHISTORY_DATA Liver_WL_History Liver WL_ID_CODE -m

	# Waiting List Exception History - Only for Liver
	@echo "- Parsing Waiting List Exception History data for LIVER and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) LIVER_EXCEPTION_DATA Liver_Exception Liver WL_ID_CODE -m

	# Clear Files
	@echo "- Cleaning up data files..."
	@rm data/LIVER*

	# Add age groupings to the documents in the database
	@echo "- Creating Age groupings for the patients in the database"
	@python import_scripts/age_groups.py $(SERVER) $(DB) Liver INIT_AGE INIT_AGE_BIN
	@python import_scripts/age_groups.py $(SERVER) $(DB) Liver AGE AGE_BIN

	@echo ""
	@echo "Liver Data Import Complete"
	@echo "--------------------------------------"

thoracic:
	@echo ""
	@echo "--------------------------------------"
	@echo "Beginning Thoracic Data Import"

	@echo "- Copying over data from files to local directory..."
	@cp -r $(LINKED_DIRECTORY)/Thoracic/* data/.

	@echo "- Flattening data files..."
	@mv data/*/**/** data/.
	@mv data/*/** data/.
	@rm -rf data/*/

	# Send the Thoracic data into Mongo
	@echo "- Parsing THORACIC data and inserting into MongoDB..."
	@python import_scripts/add_patients.py $(SERVER) $(DB) THORACIC_DATA Thoracic

	# Thoracic HLA
	@echo "- Parsing HLA data for THORACIC and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) THORACIC_ADDTL_HLA Thoracic_HLA Thoracic TRR_ID_CODE

	# Thoracic Immunosuppression Discharge
	@echo "- Parsing Immunosuppression Discharge data for THORACIC and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) THORACIC_IMMUNO_DISCHARGE_DATA Thoracic_Immuno_Discharge Thoracic TRR_ID_CODE

	# Thoracic Immunosuppression Followup
	@echo "- Parsing Immunosuppression Follow-up data for THORACIC and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) THORACIC_IMMUNO_FOLLOWUP_DATA Thoracic_Immuno_Followup Thoracic TRR_ID_CODE -m

	# Thoracic Followup Data
	@echo "- Parsing Follow-up data for THORACIC and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) THORACIC_FOLLOWUP_DATA Thoracic_Followup Thoracic TRR_ID_CODE -m

	# Thoracic Malignancy Followup Data
	@echo "- Parsing Malignancy Follow-up data for THORACIC and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) THORACIC_MALIG_FOLLOWUP_DATA Thoracic_Malig_Followup Thoracic TRR_ID_CODE -m

	# Thoracic PRA and Crossmatch Data
	@echo "- Parsing PRA and Crossmatch data for THORACIC and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) THORACIC_PRA_CROSSMATCH_DATA Thoracic_PRA Thoracic TRR_ID_CODE

	# Thoracic Waiting List History
	@echo "- Parsing Waiting List History data for THORACIC and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) THORACIC_WLHISTORY_DATA Thoracic_WL_History Thoracic WL_ID_CODE -m

	# Thoracic MCS Device Data
	@echo "- Parsing MSC Device data for THORACIC and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) THORACIC_MCS_DEVICE Thoracic_MCS_DEVICE Thoracic WL_ID_CODE -m

	# Thoracic WL-LAS Data
	@echo "- Parsing Waiting List LAS data for THORACIC and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) THORACIC_LAS_AUDIT_DATA Thoracic_LAS_Audit Thoracic WL_ID_CODE -m
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) THORACIC_LAS_HISTORY_DATA Thoracic_LAS_History Thoracic WL_ID_CODE -m

	# Thoracic WL-Status Justification Data
	@echo "- Parsing Waiting List Status Justification data for THORACIC and inserting into MongoDB..."
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) THORACIC_STAT1A Thoracic_Stat1A Thoracic WL_ID_CODE -m
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) THORACIC_STAT1B Thoracic_Stat1B Thoracic WL_ID_CODE -m
	@python import_scripts/supplemental_data.py $(SERVER) $(DB) THORACIC_VAD_IMPLANT_DATES Thoracic_VAD_Implant Thoracic WL_ID_CODE -m

	# Clear Files
	@echo "- Cleaning up data files..."
	rm data/THORACIC*

	# Add age groupings to the documents in the database
	@echo "- Creating Age groupings for the patients in the database"
	@python import_scripts/age_groups.py $(SERVER) $(DB) Thoracic INIT_AGE INIT_AGE_BIN
	@python import_scripts/age_groups.py $(SERVER) $(DB) Thoracic AGE AGE_BIN

	@echo ""
	@echo "Thoracic Data Import Complete"
	@echo "--------------------------------------"

test-sample-data:
	@echo ""
	@echo "--------------------------------------"
	# Run a test query on the data
	@echo "Running Test Query on Database; Collection = Deceased Donors"
	- mkdir -p tmp
	python query.py --server $(SERVER) --db $(DB) --collection Deceased_Donor --test  > tmp/organ_data_Deceased_Donor.txt
	diff tmp/organ_data_Deceased_Donor.txt test-data/organ_data_Deceased_Donor.txt
	@echo "Test Passed."
	@echo "--------------------------------------"
	@rm -rf tmp

clean:
	- rm -rf $(LINKED_DIRECTORY)
	- rm -rf data
