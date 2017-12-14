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

Edit `populate.sh` to:
* Specify location of database client, data source, and database name
* Comment out import scripts for data that you do not have

Execute `populate.sh` to populate MongoDB
```
sh populate.sh
```

## Test

To test the import, ...

## Author Information

Christine Harvey, The MITRE Corporation (ceharvey@mitre.org / ceharvs@gmail.com)

Approved for Public Release; Distribution Unlimited. Case Number 16-2039.

(C)2016 The MITRE Corporation. ALL RIGHTS RESERVED.
