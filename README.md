# Transplant2Mongo

[![DOI](https://zenodo.org/badge/82126974.svg)](https://zenodo.org/badge/latestdoi/82126974)

Transplant2Mongo allows users to easily insert the complex set of [UNOS STAR](https://optn.transplant.hrsa.gov/data) tab-separated variable files containing [U.S. organ transplant data](https://optn.transplant.hrsa.gov/) into a Mongo database using Python. 

The intended user is a researcher interested in doing analysis on [UNOS STAR](https://optn.transplant.hrsa.gov/) data. This software parses and inserts the UNOS STAR text files into a Mongo Database such that the database can be easily queried using open-source software.

Transplant2Mongo was has been tested with [UNOS STAR](https://optn.transplant.hrsa.gov/data) files from the [OPTN](https://optn.transplant.hrsa.gov/) obtained in June 2014 and March 2015.

## Requirements

Installation requires the following components:

* [MongoDB](https://docs.mongodb.com/manual/tutorial/) 2.6+
* Python 3.6 and the packages: pymongo, pandas, and tqdm
* [UNOS STAR File data](https://optn.transplant.hrsa.gov/), which must be obtained directly from the [OPTN](https://optn.transplant.hrsa.gov/).

## Setup Instructions

These instructions have been tested on macOS 10.14, MongoDB 3.4, and Python 3.6; and Ubuntu 14.04, MongoDB 2.6, and Python 3.7. 

### Install Required Software

After installing MongoDB using the [installation instructions](https://docs.mongodb.com/manual/administration/install-community/), start it with

```
mongod --dbpath /tmp
```

Next, install Python dependencies using

```
pip install pymongo pandas tqdm
```

### Download Transplant2Mongo

Download `transplant2mongo` from GitHub using

```
git clone https://github.com/ceharvs/transplant2mongo/
cd transplant2mongo
```

### Create and Test Database Using Test Data

The GitHub repository comes with sample data to test the install with.  We suggest running the code with the sample data first to verify the install completed properly and your environment is set up properly.

If you have MongoDB set up on the system you're using, the sample data should properly go into MongoDB using the Makefile. Run the following to populate the sample DB and test. 

From the command line, execute

```
make
```

This will import the test data into a Mongo database. To test the import, execute

```
make test-sample-data
```

The makefile includes progress bars showing the number of files imported and the number of iterations per second.  (With the sample data, these display may show [00:00<00:00, ?it/s], which does not indicate an error - there is just too little time to estimate the progress.)

### Create Database Using Real Data

After verifying the installation using the test data, either modify the `UNOS_DATA` variable in the Makefile to point to the directory of actual STAR files or pass it as a variable, e.g.,

```
make UNOS_DATA=/path/to/Delimited Text File/
```

Parameters in the Makefile include:

* `UNOS_DATA`: The location of the data source, including the 'Delimited Text File' folder. By default, this points to synthetic sample data included in the repository.
* `CLIENT`: The location of database client, by default this is 'localhost' and should be 'localhost' unless the database will be hosted on a remote server. Mongodb must be running at this location.
* `DB`: The name of the database to be used within Mongodb, by default, this is 'organ_data'.
* `COMPONENTS`: The UNOS STAR files that you have access to and are in the `UNOS_DATA` directory. This is a list of file types (which include `deceased living intestine kidpan liver thoracic`) separated by a single space.  The default setting for the Makefile uses all possible components.


## Reviewing and Accessing Data

### Robo 3T

Robo 3T (https://robomongo.org/) can be used to browse the Mongo database. After installation, select "new connection" and use the defaults.

![Robo3T screenshot](Robo3T.png)

### Jupyter Notebook

An example Jupyter notebook, [query-samples.ipynb](https://github.com/ceharvs/transplant2mongo/blob/master/query-examples.ipynb), can be used for analysis and to get started with queries and generating statistical analysis and graphics.

Launch Jupyter Notebooks by running 

```
jupyter notebook query-examples.ipynb
``` 

from the command line within the directory `transplant2mongo`.  This should open a web browser where you can click to open the file.  

### Export a Query

The included Python script, `query.py`, performs sample database queries and prints the output to a CSV file.  By default the output will print to `output.csv`, but this can be altered via command line arguments:

```
python query.py --server localhost --db organ_data --collection Deceased_Donor --attributes ABO AGE_DON GENDER_DON --file_name output.csv
```

The script takes in the client, database name, collection name, and a list of attributes to retrieve and print out to the CSV file.  Running with the `--test` option will only pull the first five entires and won't save the output to a file. 


## Author Information

Christine Harvey, The MITRE Corporation (ceharvey@mitre.org / ceharvs@gmail.com)

Approved for Public Release; Distribution Unlimited. The MITRE Corporation. Case Number 16-2039.

The data reported here have been supplied by the United Network for Organ Sharing as the contractor for the Organ Procurement and Transplantation Network. The interpretation and reporting of these data are the responsibility of the author(s) and in no way should be seen as an official policy of or interpretation by the OPTN or the U.S. Government.
