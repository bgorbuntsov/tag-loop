#!/bin/bash

filename=res.txt
region_regex="^([a-z]+\-[a-z]+\-[0-9])"

function extractTags {
  if [[ $# -eq 0 ]]; then
    echo "$(tput setaf 1)No arguments$(tput sgr 0)"
    exit 1
  fi
  echo ""
  echo "               --== $1 ==--"
  echo -e "\nListing Resources in '$1' region..."
  aws resourcegroupstaggingapi get-resources --region $1 > $filename
  count=`jq -r '.ResourceTagMappingList[].ResourceARN' $filename | wc -l`
  if [ $count -eq 0 ]; then 
    echo "              NOTHING HERE"
    return
  fi
  let count-=1
  for i in $(seq 0 $count);
  do
    echo "=================================="
    name=`jq -r ".ResourceTagMappingList[$i].ResourceARN" $filename`
    echo $name
    tcount=`jq -r ".ResourceTagMappingList[$i].Tags" $filename | grep "Key" | wc -l`
    if [[ $tcount -eq 0 ]]; then
      echo "$(tput setaf 4)No Tags here$(tput sgr 0)"
    fi
    let tcount-=1
    for j in $(seq 0 $tcount);
    do
      echo "-------------------------------"
      # Extract Tag.Key
      key=`jq -r ".ResourceTagMappingList[$i].Tags[$j].Key" $filename`
      # Extract Tag.Value
      value=`jq -r ".ResourceTagMappingList[$i].Tags[$j].Value" $filename`
      # Save old
      oldkey=$key
      oldvalue=$value
      # Leading and trailing white spaces should be trimmed
      key=`sed 's/^[ \t]*//;s/[ \t]*$//' <<< $key`
      value=`sed 's/^[ \t]*//;s/[ \t]*$//' <<< $value`
      # Convert all to _lowcase_
      key=`tr '[:upper:]' '[:lower:]' <<< $key`
      value=`tr '[:upper:]' '[:lower:]' <<< $value`
      # Replace all spaces with dash sign '-'
      key=`tr -s ' ' '-' <<< $key`
      value=`tr -s ' ' '-' <<< $value`
      # Merge all multiply dashes
      key=`tr -s '-' '-' <<< $key`
      value=`tr -s '-' '-' <<< $value`
      # Capitalised (starts with a capital letter, then all small letters)
      key="$(tr '[:lower:]' '[:upper:]' <<< ${key:0:1})${key:1}"
      value="$(tr '[:lower:]' '[:upper:]' <<< ${value:0:1})${value:1}"
      echo "$(tput setaf 6)Key" $j ":" $oldkey "->" $key "$(tput sgr 0)"
      echo "$(tput setaf 6)Value" $j ":" $oldvalue "->" $value "$(tput sgr 0)"
      if [[ $2 ]]; then
        if [[ $2 -eq "fix" ]]; then
          delresult=$(aws resourcegroupstaggingapi untag-resources --resource-arn-list "$name" --tag-keys "$oldkey")
          if [[ -z "`echo $delresult > jq '.FailedResourcesMap'`" ]]; then
            addresult=$(aws resourcegroupstaggingapi tag-resources --resource-arn-list "$name" --tags "$key"="$value")
            if [[ -z "`echo $addresult > jq '.FailedResourcesMap'`" ]]; then
              echo "$(tput setaf 2)Done$(tput sgr 0)"
            else
              echo "$(tput setaf 1)Failed to set new Value to Tag$(tput sgr 0)"
            fi
          else
            echo "$(tput setaf 1)Failed to rename Tag$(tput sgr 0)"
          fi
        fi
      fi
    done
  done
}

if [[ $# -eq 0 ]]; then
  echo "$(tput setaf 4)No region given. Showing all available$(tput sgr 0)"
  for region in `aws ec2 describe-regions --output text | cut -f4`
  do
    extractTags $region
  done
else
  if [[ $1 =~ $region_regex ]]; then
    if [[ $2 ]]; then
      if [[ $2 = "-fix" ]]; then
        extractTags $1 fix
      else
        echo "$(tput setaf 3)Unknown parameter. Ignored$(tput sgr 0)"
      fi
    else
      extractTags $1
      echo ""
      echo "$(tput setaf 4)* Nothing affected. To fix all tags set region and -fix parameter"
      echo "Example: " $0 "eu-central-1 -fix$(tput sgr 0)"
    fi
  else
    echo "$(tput setaf 3)"
    echo "Wrong input!"
    echo "Example: " $0 "eu-central-1$(tput sgr 0)"
    exit 1
  fi
fi

if [ -f "$filename" ] ; then
  rm -f "$filename"
fi
