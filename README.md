# Bidirectional conversion between JSON(-LD) and iRODS AVUs

## Introduction

This is a companion repository to the [irods_avu_json](https://github.com/MaastrichtUniversity/irods_avu_json) Python 
module. Please read the README of that repository for an introduction on the goal of these repositories.

This repository contains the iRODS rules, policies and microservices to make the conversion code operational in iRODS.

### Docker
A description of a docker contain running this ruleset, its microservices and python dependencies exists in the
[irods_avu_json-docker](https://github.com/MaastrichtUniversity/irods_avu_json-docker) repository. You can use this
to quickly try out this ruleset. 

## Requirements
The following are required to run.

* iRODS > 4.2.x (For Python rule engine)
* The iRODS Python rule engine
* Python dependencies (see requirements.txt)

## Installation

### Microservices

iRODS 4.2.x is missing the microservices to modify the unit field of an AVU triple. Please vote for 
[this iRODS issue](https://github.com/irods/irods/issues/4185) to  get this fixed. 
 
To get around this, a set of custom iRODS microservices have to be installed. These have been included in this repository.

Build requirements:
* irods-dev
* irods-externals-clang-runtime3.8-0
* irods-externals-clang3.8-0
* cmake

Build instructions:
```bash
mkdir build 
cd build
cmake ../
make
```

Install instructions
```bash
make install
```
 
### Rules and Policies

First make sure that the Python package [irods_avu_json](https://github.com/MaastrichtUniversity/irods_avu_json) and 
other requirements have been installed globally in order for the iRODS Python rule engine to pick it up. 

```bash
sudo pip install -r requirements.txt
```

Finally, copy the rule file `rules/core.py` to `/etc/irods/core.py`.

## Usage

### Rules

#### setJsonToObj(*object, *objectType, *jsonRoot, *json)

#### getJsonFromObj(*object, *objectType, *jsonRoot)

#### setJsonSchemaToObj(*object, *objectType, *jsonSchema, *jsonRoot)

#### getJsonSchemaFromObj(*object, *objectType, *jsonRoot)

### Policies

Whenever an iRODS object (file, collection, resource, user) has an AVU called `$id` set, the value of the AVU determines
the JSON-schema controlling the object and the unit field determines the JSON-root used by the JSON-AVU conversion.  

The policies then implements:

* Direct modification of AVU under control of the JSON-schema set by `$id` AVU is not allowed. 
* Modification of those AVUs is only allowed using setJsonToObj()

Modifications of other AVUs on an iRODS object are not affected by the policies.

## Tests

Each microservice and rule function comes with a little test rule file that can be executed with `irule`.

A more complete test script of the policies is available in `tests/pep_tests.sh`.

## Authors
Paul van Schayck (p.vanschayck@maastrichtuniversity.nl), Ton Smeele, Daniel Theunissen and Lazlo Westerhof 

## Copyright and license

(c) Maastricht University

Apache License 2.0
 