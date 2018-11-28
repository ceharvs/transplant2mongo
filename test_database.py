
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
                                   'and information are being stored in MongoDB.')
parser.add_argument('database', help='Database that will be used to store the data')
parser.add_argument('collection_name', help='Name of the collection to be used')
parser.add_argument('variable', help='Variables to search on')
parser.add_argument('value', help='Value for the variable')
args = parser.parse_args()


# Establish a database connection
db = pymongo.MongoClient(args.client)[args.database]
collection = db[args.collection_name]

# Print the output
value = str(args.value)
print(collection.find_one({args.variable: value}))

