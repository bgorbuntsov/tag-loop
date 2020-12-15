# Circle loop through tags

For each resource, for each tag Key and Value, we need to ensure it is:
1. Capitalised (starts with a capital letter, then all small letters)
2. Replace all spaces with dash sign '-'
2.1 There can be instances of multiple spaces or a space followed by a '-' sign, any such occurrence should be replaced by a single dash
2.2 trailing whitespaces should be trimmed, if they exist

## Usage

*./loop.sh <aws-region-name> [-fix]*


