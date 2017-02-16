
"""
Code written to pull organ specific records from the .DAT files and 
transfer the information into MongoDB.  

This script is meant to be used on the major files, such as 
DECEASED_DONOR_DATA.DAT and the LIVER_DATA.DAT files.

Input Parameters:
- client: Location of the database where the data is stored.  This is given
        as a specific path location such as organ-db.website.org.
- database: This is where the database is specified.  Location where the 
        data is stored on the MongoDB Client
- file_name: This is the file name without the extension.  For example
	Deceased_Donor or Liver, which is the file created from the 
	concatenation of the header and the data file. 
- collection_name: The name of the collection that the data will be stored 
	under in the database.
- unique_id: Unique identifier for the data being imported to MongoDB.
	This is an attribute of the data that uniquely identifies a record
	for matching such as DONOR_ID for the donor data.  This argument 
	is optional and is not useful for specific organ data.
"""

__author__ = "Christine Harvey"
__email__ = "ceharvey@mitre.org"
__status__ = "Production"

import csv
import codecs
import pymongo
import argparse
import datetime

# Input argument parsing
parser = argparse.ArgumentParser(description='Process command line arguments')
parser.add_argument('client', help='Location of the database being used',
                    type=str)
parser.add_argument('database', help='Name of the database on the client',
                    type=str)
parser.add_argument('file_name', help='Root name of file containing the data',
                    type=str)
parser.add_argument('collection_name', help='Name of the collection to import to',
                    type=str)
parser.add_argument('-u', '--unique_ID', help='Unique identifier for the data'
                                              ' set to be used as a matching key',
                    nargs='?', const=None, type=str, default=None)
args = parser.parse_args()

# Path to data files
path = 'data/'

def clean_string(string):
    """Clean string and replace unnecessary values"""
    # Replace unnecessary apostrophes
    string = string.replace("'","")
    # Replace random tabs
    string = string.replace("\t","")
    # Replace random \ marks
    string = string.replace("\\","")
    # Remove <> characters
    string = string.replace("<","").replace(">","") 
    return string

def import_header():
    """Read in information from the header file"""
    # Read in the htm file with the headers
    header = []
    with open(path+args.file_name+'.htm') as f:
        # Find the start of the code body
        for line in f:
            if line.strip()=="<tbody>":
                break
        #Continue processing until the end of the body
        for line in f:
            if line.strip()=="</tbody>":
                break
            # Extract the relevant column header information
            # Extract the relevant column header information
            header.append(line.split('</th><td>')[1].split('</td><td>')[0])
    return header

# Set up connection to MongoDB
db = pymongo.MongoClient(args.client)[args.database]
collection = 'db.'+args.collection_name
#bulk = db[args.collection_name].initialize_ordered_bulk_op()

header = import_header()

posts=[]

# Read in the htm file with the headers
with codecs.open(path + args.file_name+".DAT","rb",encoding="utf-8",errors="ignore") as f:
    reader = csv.reader(f, delimiter='\t', quotechar='"')
    
    # Find the person identifier item in headers, this is the unique ID
    if args.unique_ID:
        id_index = header.index(args.unique_ID)
    
    # Put all rows into MongoDB
    for row in reader:
        if args.unique_ID:
             doc = {'_id': row[id_index]}
        else:
             doc = dict()

        for j in range(len(row)):
            # Skip blanks and periods
            if row[j] is "" or row[j] is ".":
                pass
            else:
                # Check if the header contains the word date
                if "DATE" in header[j]:
                    try:
                        doc[header[j]] = datetime.datetime.strptime(row[j],"%m/%d/%Y")
                    except ValueError:
                        try:
                            doc[header[j]] = datetime.datetime.strptime(row[j],"%m/%d/%y")
                        except ValueError:
                            doc[header[j]] = clean_string(row[j])
                # Check if the row is a digit
                elif row[j].isdigit():
                    doc[header[j]] =  int(row[j])
                else:
                    doc[header[j]] =  clean_string(row[j])
        
        posts.append(doc)
        #bulk.insert(doc)
        if len(posts) > 500:
            db[args.collection_name].insert(posts)
            posts = []

#result = bulk.execute()
db[args.collection_name].insert(posts)

print args.file_name + " data has been successfully imported to MongoDB!"
