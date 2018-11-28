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
                                   'that will be used to store the data', type=str)
parser.add_argument('database', help='Database that will be used to store the data',
                    type=str)
parser.add_argument('collection_name', help='Name of the collection to be used',
                    type=str)
parser.add_argument('age_variable', help='Variable used in the collection to represent age',
                    type=str)
parser.add_argument('bin_variable', help='Variable name used to name age group',
                    type=str)
args = parser.parse_args()

# Set up connection to MongoDB
db = pymongo.MongoClient(args.client)[args.database]
bulk = db[args.collection_name].initialize_ordered_bulk_op()

# Ensure that an index is in place for the variable being used for age
db[args.collection_name].create_index(args.age_variable)

# Find all Under a year old
bulk.find({args.age_variable: {"$lt": 1}}).update({"$set": {args.bin_variable: "<1"}})
bulk.execute()
bulk = db[args.collection_name].initialize_ordered_bulk_op()

# Find all between 1 and 5
bulk.find({args.age_variable: {"$gte": 1, "$lte": 5}}).update({"$set": {args.bin_variable: "1-5"}})
bulk.execute()
bulk = db[args.collection_name].initialize_ordered_bulk_op()

# Find all between 6 and 10
bulk.find({args.age_variable: {"$gte": 6, "$lte": 10}}).update({"$set": {args.bin_variable: "6-10"}})
bulk.execute()
bulk = db[args.collection_name].initialize_ordered_bulk_op()

# Find all between 11 and 17
bulk.find({args.age_variable: {"$gte": 11, "$lte": 17}}).update({"$set": {args.bin_variable: "11-17"}})
bulk.execute()
bulk = db[args.collection_name].initialize_ordered_bulk_op()

# Find all between 18 and 34
bulk.find({args.age_variable: {"$gte": 18, "$lte": 34}}).update({"$set": {args.bin_variable: "18-34"}})
bulk.execute()
bulk = db[args.collection_name].initialize_ordered_bulk_op()

# Find all between 35 and 49
bulk.find({args.age_variable: {"$gte": 35, "$lte": 49}}).update({"$set": {args.bin_variable: "35-49"}})
bulk.execute()
bulk = db[args.collection_name].initialize_ordered_bulk_op()

# Find all between 50 and 64
bulk.find({args.age_variable: {"$gte": 50, "$lte": 64}}).update({"$set": {args.bin_variable: "50-64"}})
bulk.execute()
bulk = db[args.collection_name].initialize_ordered_bulk_op()

# Find all 65+
bulk.find({args.age_variable: {"$gte": 65}}).update({"$set": {args.bin_variable: "65+"}})
bulk.execute()
bulk = db[args.collection_name].initialize_ordered_bulk_op()
