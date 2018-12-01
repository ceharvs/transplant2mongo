# Transplant2Mongo

[![DOI](https://zenodo.org/badge/82126974.svg)](https://zenodo.org/badge/latestdoi/82126974)


This Tool allows users to import data from UNOS STAR files to MongoDB using Python.  This tool was developed using OPTN STAR file data as of June 2014 and March 2015.

## Requirements
Performing the installation requires the following components:
* [MongoDB](https://docs.mongodb.com/manual/tutorial/)
* Python 3.6.\* and packages: pymongo, csv, datetime, argparse, codecs, and pandas. If you're 
interested in performing analysis and developing graphics, we also suggest the Seaborn package.  
* UNOS STAR File data (this must be obtained directly through UNOS and the OPTN).

## Setup Instructions
Basic instructions for importing the UNOS Star data files into MongoDB.  These instructions have been verified and 
tested on macOS and CentOS 7.

### Install Required Software
Install Python3 with the required libraries above. We suggest the Anaconda Python distribution: 
https://www.anaconda.com/download/

Install and launch Mongo DB, mongod must be running in order for the data to be written to the database.

### Install Source Code from Gitlab
Download the transplant2mongo code from the GitHub repository.

```
git clone https://github.com/ceharvs/transplant2mongo/
cd transplant2mongo
```

### Customize the Makefile
The Makefile can be run using the default setup with sample data before configuring. Once you've verified the 
tests work properly with the sample data, update the Makefile to point to your own STAR files.

Edit the `Makefile` in the following locations:
* UNOS_DATA (line 3): Specify the location of the data source, including the 'Delimited Text File' 
folder. By default, this points to synthetic sample data included in the repository.
* CLIENT (line 10): Specify location of database client, by default this is 'localhost' and should be 'localhost' 
unless the database will be hosted on a remote server. Mongodb must be running at this location.
* DB (line 11): Specify the name of the database to be used within Mongodb, by default, this is 'organ_data'.
* COMPONENTS (line 15): The components are the UNOS STAR files that you have access to, this will be list of file 
types (deceased living intestine kidpan liver thoracic) separated by a single space.  The default setting for the 
Makefile uses all possible components.

Run the Makefile to populate the database.
```
make all
```

## Test

The makefile includes a test which runs at the end of `make all`.  

To test the import separately, use the default settings for the sample data set.  Once all of the sample data 
has been loaded, try running the following python script:
```
python test_database.py localhost organ_data Deceased_Donor ABO AB
```
You should get the following output:
```
{'_id': '6', 
 'DONOR_ID': 6, 
 'ABO': 'AB', 
 'GENDER_DON': 'M', 
 'HOME_STATE_DON': 'CA', 
 'AGE_DON': '55'
 'DON_DATE': '05042011',
 'Inotropic_Meds': 
    {'MEDICATION': 'Medicine A'}
}
```

## Reviewing and Accessing Data

We suggest using Robo 3T (https://robomongo.org/) to browse the data and Jupyter Notebooks to perform analysis.  

### Query to .CSV File
A Python script is included, `query.py`, that performs database queries and prints the output to a 
.CSV file.  By default the output will print to output.csv, but this can be altered via command line arguments:
```
python query.py localhost organ_data Deceased_Donor ABO AGE_DON GENDER_DON --file_name output.csv
```

The script takes in the client, database name, collection name, and a list of attributes to retrieve and print out to
the .CSV file.  

### Jupyter Notebooks
An example notebook is included that can be used for analysis and to get started with queries and generating 
statistical analysis and graphics.  This file, `Quick_Query_Introduction.ipynb`, can be run using Jupyter Notebooks, a 
tool build into the Python distribution.  

Launch Jupyter Notebooks by running `jupyter notebook` from the command line within the github directory.  This should 
open a web browser where you can click to open the file.  

Additional information on how to use Jupyter Notebooks: https://jupyter-notebook-beginner-guide.readthedocs.io 

## Author Information

Christine Harvey, The MITRE Corporation (ceharvey@mitre.org / ceharvs@gmail.com)

Approved for Public Release; Distribution Unlimited. Case Number 16-2039.

(C)2016 The MITRE Corporation. ALL RIGHTS RESERVED.

The data reported here have been supplied by the United Network for Organ Sharing as the contractor for the Organ 
Procurement and Transplantation Network. The interpretation and reporting of these data are the responsibility of the 
author(s) and in no way should be seen as an official policy of or interpretation by the OPTN or the U.S. Government.
