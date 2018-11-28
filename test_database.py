
"""
Pull a single item from a mongodb database and print to the screen.

Input Parameters:
- client: Location of the database where the files and information
    are being stored in MongoDB.
- database: Location of the database where the files and information
    are being stored in MongoDB.
- collection_name: This is the name of the parent collection for the
    data.  For example, if we want to pull from the Living Donors
    collection then the collection_name would be Living_Donor
- file_name: Name of file to save the aggregated data to
- variable: Variable to search on
- value: Value of the variable to return
"""

import pymongo
import argparse

# Parse in the input arguments
parser = argparse.ArgumentParser(description='Process command line input')
parser.add_argument('client', help='Location of the database where the files '
                                   'and information are being stored in MongoDB.',
    type=str)
parser.add_argument('database', help='Database that will be used to store the data',
    type=str)
parser.add_argument('collection_name', help='Name of the collection to be used',
    type=str)
parser.add_argument('variable', help='Variables to search on', 
    type=str)
parser.add_argument('value', help='Value for the variable', 
    type=str)
args=parser.parse_args()


# Establish a database connection
db = pymongo.MongoClient(args.client)[args.database]
collection = db[args.collection_name]

# Try to convert the value to an int
try:
    value = int(args.value)
except ValueError as verr:
    pass  # do job to handle: s does not contain anything convertible to int
except Exception as ex:
    pass  # do job to handle: Exception occurred while converting to int

print(collection.find_one({args.variable: value}))

