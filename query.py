
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
parser = argparse.ArgumentParser(description='Process command line '
                                             'input for the query tool')
parser.add_argument('--server', default="localhost:27017",
                    help='Location of the database where the files '
                         'and information are being stored in MongoDB')
parser.add_argument('--db', default='organ_data',
                    help='Database that will be used to store the data')
parser.add_argument('--collection', default='Deceased_Donor',
                    help='Name of the collection to be used')
parser.add_argument('--file_name', default='output.csv',
                    help='Output file to store results')
parser.add_argument('--attributes', default=['ABO', 'AGE_DON', 'GENDER_DON'],
                    help='Attributes or Columns to pull for the Data',
                    nargs='+')
parser.add_argument('--test', help='Run in test mode to perform query only '
                                   'and skip the file output',
                    action='store_true')
args = parser.parse_args()

print("Querying data from %s including attributes: %s" % (args.collection, args.attributes))
# Create a dictionary of the attributes to be selected from the database
select = dict(zip(args.attributes, [1]*len(args.attributes)))

# Establish a database connection
db = pymongo.MongoClient(args.server)[args.db]
collection = db[args.collection]

# Build a query for the results, limit to 5 for the test
if args.test:
    query = collection.find({}, select).limit(5)
else:
    query = collection.find({}, select)

# Pull data and convert to a Pandas DataFrame
results = pd.DataFrame(list(query))
print("%d entries found in the database" % len(results))

# Print results to screen for test mode and to file for general query
if args.test:
    print(results.to_string())
else:
    results.to_csv(args.file_name, index=False)
    print("File successfully written to %s" % args.file_name)

