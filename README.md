# Guide for Transplant2Mongo

## Requirements
Performing the installation requires the following components:
* [MongoDB](https://docs.mongodb.com/manual/tutorial/)
* Python 2.7.\* and packages: pymongo, csv, datetime, argparse, codecs, pandas.
* UNOS STAR File data (this must be obtained directly through UNOS and the OPTN).

## Setup Instructions

Basic instructions for importing the UNOS Star data files into MongoDB.

```
git clone https://github.com/ceharvs/transplant2mongo/
cd transplant2mongo
```

Edit `Makefile` to:
* Specify location of database client, data source, and database name
* Specify the COMPONENTS (decesed donor, thoracic, liver, etc.) that need to be imported, base this off of the files you have access to

Run the Makefile to populate the database
```
make all
```

## Test

To test the import, use the default settings for the sample data set.

## Author Information

Christine Harvey, The MITRE Corporation (ceharvey@mitre.org / ceharvs@gmail.com)

Approved for Public Release; Distribution Unlimited. Case Number 16-2039.

(C)2016 The MITRE Corporation. ALL RIGHTS RESERVED.
