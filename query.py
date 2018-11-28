
"""
Pull a multiple items from a mongodb database and save to a file.

Input Parameters:
- client: Location of the database where the files and information
    are being stored in MongoDB.
- database: Location of the database where the files and information
    are being stored in MongoDB.
- collection_name: This is the name of the parent collection for the
    data.  For example, if we want to pull from the Living Donors
    collection then the collection_name would be Living_Donor
- file_name: Name of file to save the aggregated data to
- attributes: names of variables that we want to aggregate on

Running with Default Settings:
python query.py localhost organ_data Deceased_Donor ABO AGE_DON GENDER_DON
"""

import pymongo
import argparse
import pandas as pd

# Parse in the input arguments
parser = argparse.ArgumentParser(description='Process command line input')
parser.add_argument('client', help='Location of the database where the files '
                                   'and information are being stored in MongoDB.')
parser.add_argument('database', help='Database that will be used to store the data')
parser.add_argument('collection_name', help='Name of the collection to be used')
parser.add_argument('attributes', help='Attributes or Columns to pull for the Data.',
                    nargs='+')
parser.add_argument('--file_name', default='output.csv', help='Output file to store'
                                                              'results.')
args = parser.parse_args()


# Create a dictionary of the attributes to be selected from the database
select = dict(zip(args.attributes, [1]*len(args.attributes)))

# Establish a database connection
db = pymongo.MongoClient(args.client)[args.database]
collection = db[args.collection_name]

# Convert to a Pandas DataFrame and print to a CSV
pd.DataFrame(list(collection.find({}, select))).to_csv(args.file_name, index=False)
