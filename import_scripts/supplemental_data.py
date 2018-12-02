
"""
Code written to pull organ specific records from the .DAT files and
transfer the information into MongoDB.

This script is meant to be used on the sub-folders of the main 
areas such as LIVING_DONOR_FOLLOWUP_DATA.DAT.  This script adds
this information to the database as sub-documents of the main item.

Input Parameters:
- client: Location of the database where the files and information 
    are being stored in MongoDB.
- database: MongoDB database in client where the data collections are
        stored.
- file_name: This is the file name without the extension.  For example
    Living_Donor_Follow or Liver_Additional_HLA, which is the file 
    created from the concatenation of the header and the data file.  
    The data will be stored under this sub-document in the
    database.
- subdoc_name: This is the name of the sub document that the data will
    be stored under in the database.
- collection_name: This is the name of the parent collection for the
    data.  For example, if this is the Living_Donor_Follow, then 
    the collection_name would be Living_Donor
- unique_ID: Unique identifier for the data being imported to MongoDB.
    This is an attribute of the data that uniquely identifies a
    record for matching. For example, this is the WL_ID_CODE for 
    waiting list data.
- (optional) multiple_records: This is a boolean value representing
    whether items in this data file correspond to more than one
    donor.  An example of this is the Living_Donor_Follow data, 
    since each Living Donor can have multiple Follow-Up records.
"""

__author__ = "Christine Harvey"
__email__ = "ceharvey@mitre.org"
__status__ = "Production"

import csv
import codecs
import pymongo
import datetime
import argparse
import subprocess
from tqdm import tqdm

# Parse in the input arguments
parser = argparse.ArgumentParser(description='Process command line inputs')
parser.add_argument('client', help='MongoDB Client for data storage')
parser.add_argument('database', help='Database that will be used to store the data')
parser.add_argument('file_name', help='Root name of file containing the data')
parser.add_argument('subdoc_name', help='name for the sub document')
parser.add_argument('collection_name', help='Name of the collection to add'
                                            ' the data to')
parser.add_argument('unique_ID', help='Unique identifier for the data set to be'
                                      ' used as a matching key')
parser.add_argument('-m', '--multiple', help='Include option if there are multiple'
                                             ' records per donor or patient, for example: '
                                             'followup data can have multiple records '
                                             'per person or unique_ID', action='store_true')
args = parser.parse_args()

# Specify the path to the data file
path = 'data/'


def clean_string(string):
    """Clean string and replace unnecessary values"""
    # Replace unnecessary apostrophes
    string = string.replace("'", "")
    # Replace random tabs
    string = string.replace("\t", "")
    # Replace random \ marks
    string = string.replace("\\", "")
    # Replace <> marks
    string = string.replace("<", "").replace(">", "")
    return string


def import_header():
    """Read in information from the header file"""
    # Read in the htm file with the headers
    head = []
    with open(path+args.file_name+'.htm') as header_file:
        # Find the start of the code body
        for line in header_file:
            if line.strip() == "<tbody>":
                break
        # Continue processing until the end of the body
        for line in header_file:
            if line.strip() == "</tbody>":
                break
            # Extract the relevant column header information
            head.append(line.split('</th><td>')[1].split('</td><td>')[0])
    return head


# Set up connection to MongoDB
db = pymongo.MongoClient(args.client)[args.database]
bulk = db[args.collection_name].initialize_ordered_bulk_op()

header = import_header()

# Ensure Index for speed
db[args.collection_name].ensure_index(args.unique_ID)

# Check the length of the file
filename = path + args.file_name + ".DAT"
num_lines = subprocess.check_output(['wc', '-l', filename]).decode("utf-8").split(filename)[0].strip()
print("    Importing", num_lines, "lines...")

# Create a progress bar to report status
progress = tqdm(total=int(num_lines), leave=True, desc="    Progress")

# Read in the htm file with the headers
with codecs.open(filename, "rb", encoding="utf-8", errors="ignore") as f:
    reader = csv.reader(f, delimiter='\t', quotechar='"', escapechar="\n")
    
    # Send the first line to an array of headers
    # Find the person identifier item in headers, this is the unique ID
    id_index = header.index(args.unique_ID)
    
    # Counter for lines read in
    lines_read = 0
  
    # Put all row items into MongoDB
    for row in reader:
        # Account for integer and string unique_ID values
        my_id = int(row[id_index]) if row[id_index].isdigit() else row[id_index]
        
        # Initialize the document to be added to the database
        doc = dict()
        subdoc = dict()
        for j in range(len(row)):
            # Skip blanks, periods and the unique_ID being references
            if row[j] is "" or row[j] is "." or j == id_index:
                pass
            else:
                # Check if the header contains the word date, then convert to a 
                # date object
                if "DATE" in header[j]:
                    # Try multiple date formats "MM/DD/YYYY"
                    try:
                        subdoc[header[j]] = datetime.datetime.strptime(row[j], "%m/%d/%Y")
                    except ValueError:
                        try:            
                            # Try "MM/DD/YY"
                            subdoc[header[j]] = datetime.datetime.strptime(row[j], "%m/%d/%y")
                        except ValueError:
                            try:
                                # Try "DDMONYY" such as 03AUG05
                                subdoc[header[j]] = datetime.datetime.strptime(row[j], "%d%b%y")
                            except ValueError:            
                                # print "Invalid Data format: ", row[j] 
                                subdoc[header[j]] = clean_string(row[j])

                elif row[j].isdigit():
                    subdoc[header[j]] = int(row[j])
                else:
                    subdoc[header[j]] = clean_string(row[j])

        # Account for unique identifies for many many corresponding records
        if args.multiple:
            # Account for missing values in this column
            doc[args.subdoc_name] = subdoc 
            bulk.find({args.unique_ID: my_id}).update({"$addToSet": doc})
        else:
            doc[args.subdoc_name] = subdoc
        
            bulk.find({args.unique_ID: my_id}).update({"$set": doc})
        lines_read += 1
        
        # Perform a bulk update to manage the data burden on Python
        if lines_read % 500 == 0:
            bulk.execute()
            bulk = db[args.collection_name].initialize_ordered_bulk_op()

            # Update the progress bar
            progress.update(500)

# Finish the progress bar
progress.update(int(num_lines)-(lines_read % 500))
progress.close()

# Finish bulk operations as long
if lines_read % 500 != 0:
    result = bulk.execute()

# Print progress to the screen
print("     ", lines_read, "lines of data have been imported")
