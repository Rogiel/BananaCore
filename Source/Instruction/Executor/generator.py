#!/usr/bin/env python
##
##  BananaCore
##
##  Created by Rogiel Sulzbach.
##  Copyright (c) 2015 Rogiel Sulzbach. All rights reserved.
##

__author__ = 'Rogiel Sulzbach'

import argparse
import os
import uuid
import datetime

def parse_template(input_file, output_file, vars):
    print(output_file)
    with open(input_file, 'r') as ftemp:
        templateString = ftemp.read()
    with open(output_file, 'w') as f:
        f.write(templateString.format(**vars))

# parse command line
parser = argparse.ArgumentParser(description='Creates a new entity from a template')
parser.add_argument('name', metavar='service_name',
                   help='the entity name')
args = parser.parse_args()

current_path = os.path.dirname(os.path.realpath(__file__))
output_directory = current_path

template_vars = {
    'EntityName': args.name + 'InstructionExecutor'
}

output_file = "{0}/{1}.vhd".format(output_directory, template_vars['EntityName']);

# if os.path.exists(output_file):
#     print("File {0} already exists... skipping.".format(output_file))
# else:
parse_template(current_path + "/__TEMPLATE__.vhd", "{0}/{1}.vhd".format(output_directory, template_vars['EntityName']), template_vars)
    # print("Done.")