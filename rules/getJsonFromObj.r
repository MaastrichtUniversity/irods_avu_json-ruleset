# This rule return a json string from AVU's set to an object
# Argument 1: The object name (/nlmumc/home/rods/test.file, /nlmumc/home/rods, user@mail.com, demoResc)
# Argument 2: The object type -d for data object
#                             -R for resource
#                             -C for collection
#                             -u for user
# Argument 3:  the JSON namespace according to https://github.com/MaastrichtUniversity/irods_avu_json.

# Example : irule -F getJsonFromObj.r "*object='/nlmumc/home/rods/test.file'" "*objectType='-d'" "*jsonNamespace='root'"


main(){
    # Defining result first is mandatory!
    *result = ""

    # Call the python function
    getJsonFromObj(*object, *objectType, *jsonNamespace, *result)

    # Print
    writeLine("stdout", *result)
}

INPUT *object=$'/nlmumc/home/rods/test.file', *objectType=$'-d', *jsonNamespace=$'root'
OUTPUT ruleExecOut
