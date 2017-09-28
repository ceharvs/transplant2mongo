# Guide for Transplant2Mongo

## Requirements
Performing the installation requires the following components:
* MongoDB install
* Python 2.7 or higher
	* pymongo
	* csv
	* datetime
	* argparse
    * codecs
    * pandas
* transplant2mongo repository
* UNOS STAR File data (this must be obtained directly through UNOS and the OPTN).

## Setup Instructions
The following items are basic instructions for setting up your system and environment for importing the UNOS Star files into MongoDB.

1. Clone the transplant2mongo directory.

2. Move to transplant2mongo
```
cd transplant2mongo
```

3. Edit populate.sh to:
  * Specify location of database client, data source, and database name
  * Comment out import scripts for data that you do not have

4. Execute shell script to populate MongoDB
```
sh populate.sh
```

## Author Information

Christine Harvey, The MITRE Corporation (ceharvey@mitre.org / ceharvs@gmail.com)

Approved for Public Release; Distribution Unlimited. Case Number 16-2039.

©2016 The MITRE Corporation. ALL RIGHTS RESERVED.
