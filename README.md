# Bidirectional conversion between JSON(-LD) and iRODS AVUs

## Introduction

This is a companion repository to the [irods_avu_json](https://github.com/MaastrichtUniversity/irods_avu_json) Python 
module. Please read the README of that repository for an introductionn.

This repository contains the iRODS rules, policies and microservices to make the conversion code operational in iRODS.

### Policies

The policies implement:

*
*

## Requirements
The following things are required to run.

* iRODS > 4.2.x (For Python rule engine)
* Python rule engine

## Installation

### Microservices

 iRODS 4.2.x is missing the microservices to modify the unit field of an AVU triple. Please vote for 
 [this iRODS issue](https://github.com/irods/irods/issues/4185) to
 get this fixed. So a set of custom iRODS microservices need to be installed. 
 
### Rules

### Policies 

## Tests

Each microservice comes with a little test rule.