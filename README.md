# Circle loop through tags

For each resource, for each tag Key and Value, we need to ensure it is:
1. Capitalised (starts with a capital letter, then all small letters)
2. Replace all spaces with dash sign '-' <br>
2.1 There can be instances of multiple spaces or a space followed by a '-' sign, any such occurrence should be replaced by a single dash <br>
2.2 trailing whitespaces should be trimmed, if they exist

## Prerequisites
1. Run Linux
2. Installed AWS CLI https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html
3. Dependencies for shell script: jq, tr, tput, sed
4. You must be authorised in AWS Account and have rights to view, delete and apply tags to appropriate resources.


## Usage

*./loop.sh aws-region-name [-fix]*

Running without parameters causes walk through all available regions.



