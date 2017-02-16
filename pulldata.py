
"""
Pull out data from MongoDB based on an input list of parameters to 
pull and send to a csv file.

Input Parameters:
- client: Location of the database where the files and information
    are being stored in MongoDB.
- database: Location of the database where the files and information
	are being stored in MongoDB.
- collection_name: This is the name of the parent collection for the
	data.  For example, if we want to pull from the Living Donors
	collection then the collection_name would be Living_Donor
- file_name: Name of file to save the aggregated data to
- mongo_name: names of variables that we want to aggregate on
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
parser.add_argument('file_name', help='File name to send output to',
	type=str)
parser.add_argument('variables', help='Variables to aggregate on', type=str,
	nargs='+')
args=parser.parse_args()

db = pymongo.MongoClient(args.client)[args.database]

f = open(args.file_name,'w')

# Create ID and string together a header
id = {"YEAR": "$YEAR"}
header = "YEAR,"
pull = { "YEAR": {"$year": "$DON_DATE"}}
for i in range(len(args.variables)):
    # ID for grouping
    id[args.variables[i]] = '$'+args.variables[i]
    # Items to project
    pull[args.variables[i]] = 1
    # Header for the output file
    header += args.variables[i]+','
f.write(header+'count\n')


pipeline = [
    {"$project": pull },
    {"$group": 
    { "_id": id,
      "count":{"$sum":1}}},
    {"$out": args.file_name[:-4]}
]

# Send aggregated data to temporary database
db[args.collection_name].aggregate(pipeline)

# Read in from new database
cursor = db[args.file_name[:-4]].find()

# Send to CSV file
for doc in cursor:
    line =str(doc['_id']['YEAR'])+',' 
    for i in range(len(args.variables)):
        if args.variables[i] in doc['_id']:
            line += str(doc['_id'][args.variables[i]])+','
        else:
            line += 'unknown,'
    line += str(doc['count'])+'\n'
    f.write(line)
f.close()
