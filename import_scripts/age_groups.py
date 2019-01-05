"""
Add group entry fo age range in MongoDB.

Input Parameters:
- client: Location of the database where the files and information 
    are being stored in MongoDB.
- database: Name of the database where the files and information 
    are being stored in MongoDB.
- collection_name: This is the name of the parent collection for the
    data.  For example, if we are working with Living Donors then
    the collection_name would be Living_Donor
- age_variable: Variable used in this collection to represent the age
    that we are working with, usually AGE or INIT_AGE
- bin_variable: Variable name used to name the age group.  This is often 
    something like AGE_BIN
"""

__author__ = "Christine Harvey"
__email__ = "ceharvey@mitre.org"
__status__ = "Production"

import pymongo
import argparse

# Parse in the input arguments
parser = argparse.ArgumentParser(description='Process command line inputs')
parser.add_argument('client', help='MongoDB Client location containing the database '
                                   'that will be used to store the data')
parser.add_argument('database', help='Database that will be used to store the data')
parser.add_argument('collection_name', help='Name of the collection to be used')
parser.add_argument('age_variable', help='Variable used in the collection to represent age')
parser.add_argument('bin_variable', help='Variable name used to name age group')
args = parser.parse_args()

# Set up connection to MongoDB
db = pymongo.MongoClient(args.client)[args.database]

# Ensure that an index is in place for the variable being used for age
db[args.collection_name].create_index(args.age_variable)

# Define the Age bins used
age_bins = {'<1': [0,1],
            '1-5': [1,5],
            '6-10': [6,10],
            '11-17': [11,17],
            '18-34': [18,34],
            '35-49': [35,49],
            '50-64': [50,64],
            '65+': [65,300]}


# Cycle through the age bins to perform the groupings
for index in age_bins:
    min_age = age_bins[index][0]
    max_age = age_bins[index][1]
    bin_name = index

    # Detail the requested change to make
    requests = [pymongo.UpdateMany({args.age_variable: {"$gte": min_age, "$lte": max_age}},
                                   {"$set": {args.bin_variable: bin_name}})]

    # Perform the operation
    result = db[args.collection_name].bulk_write(requests)
