# Guide for Transplant2Mongo

This Tool allows users to import data from UNOS STAR files to MongoDB using Python.  This tool was developed using OPTN STAR file data as of June 2014 and March 2015.

## Requirements
Performing the installation requires the following components:
* [MongoDB](https://docs.mongodb.com/manual/tutorial/)
* Python 3.6.\* and packages: pymongo, csv, datetime, argparse, codecs, pandas, and tk (for GUI use).
* UNOS STAR File data (this must be obtained directly through UNOS and the OPTN).

## Setup Instructions

Basic instructions for importing the UNOS Star data files into MongoDB.

```
git clone https://github.com/ceharvs/transplant2mongo/
cd transplant2mongo
```

Make sure MongoDB is running on your system:

#TODO Insert intructions on running MongoDB here

Edit `Makefile` to:
* Specify location of database client, data source, and database name
* Specify the COMPONENTS (deceased donor, thoracic, liver, etc.) that need to be imported, base this off of the files you have access to

Run the Makefile to populate the database
```
make all
```

## Test

To test the import, use the default settings for the sample data set.  Once all of the sample data has been loaded, try running the following python script:
```
python test_database.py localhost organ_data Deceased_Donor DONOR_ID 8
```
You should get the following output:
```
{u'AGE_BIN': u'18-34', u'HOME_STATE_DON': u'TN', u'AGE_DON': 32, u'GENDER_DON': u'M', u'ABO': u'O', u'DONOR_ID': 4, u'Inotropic_Meds': {u'MEDICATION': u'Medicine A'}, u'_id': u'4'}

```


## Author Information

Christine Harvey, The MITRE Corporation (ceharvey@mitre.org / ceharvs@gmail.com)

Approved for Public Release; Distribution Unlimited. Case Number 16-2039.

(C)2016 The MITRE Corporation. ALL RIGHTS RESERVED.

The data reported here have been supplied by the United Network for Organ Sharing as the contractor for the Organ Procurement and Transplantation Network. The interpretation and reporting of these data are the responsibility of the author(s) and in no way should be seen as an official policy of or interpretation by the OPTN or the U.S. Government.
