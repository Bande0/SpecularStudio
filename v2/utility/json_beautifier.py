# -*- coding: utf-8 -*-
"""
Created on Wed Apr 21 13:07:44 2021

@author: anlf
"""

import os
import sys
import json
import argparse
from collections import OrderedDict
'''
This is a helper script for "beautification" of auto-generated JSON files

In many cases, auto-generated JSON files will end up having all the data
dumped as a single line of text, which makes for very bad human readability.
This script simply adds the necessary line breaks and whitespaces so that the
resulting JSON file is easier to read for the naked eye.

OBS: As JSON data is handled as dicts in Python, this script will almost sure
change the ordering of elements in the JSON file! If for any reason, this 
behaviour is unwanted then either:
    
    1) Don't choose the --overwrite command line option - in this case, the
    original JSON file will be kept intact, and new one will be created with
    the name "<OLD_JSON_FILE>_pretty.json" filename
    
    Or:
        
    2) Don't use this script :S
    
usage: python json_beautifier.py [-h] [-f FILE] [-o]

optional arguments:
  -h, --help            show this help message and exit
  -f FILE, --file FILE  path to JSON file to be beautified
  -o, --overwrite       Overwrite original file (otherwise a new one called
                        "*_pretty.json" is created)
'''

if __name__ == "__main__":    

    import sys
    sys.argv.append('--file')
    sys.argv.append(r'C:\git\SpecularStudio\v2\test.json')

    parser = argparse.ArgumentParser(description="JSON beautifier - Help")
    parser.add_argument('-f', '--file', action='store', help='path to JSON file to be beautified', required=False)
    parser.add_argument('-o', '--overwrite', action='store_true', help='Overwrite original file (otherwise a new one called "*_pretty.json" is created)', required=False)
    
    args = vars(parser.parse_args(sys.argv[1:]))

    ugly_json = args['file']
        
    json_folder = '\\'.join(ugly_json.split('\\')[0:-1])
    ugly_json_filename = ugly_json.split('\\')[-1]
    
    if 'overwrite' in args and args['overwrite']:
        pretty_json_filename = ugly_json_filename
    else:
        pretty_json_filename = ugly_json_filename.split('.json')[0] + '_pretty.json'

    with open(ugly_json) as json_file:
        ugly_json_data = json.load(json_file)
  
    with open(json_folder + '\\' + pretty_json_filename, 'w') as fp:
        json_string = json.dumps(ugly_json_data, default=lambda o: o.__dict__, sort_keys=False, indent=2)
        fp.write(json_string)
                
                
    