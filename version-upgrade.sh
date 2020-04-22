#!/usr/bin/env bash

increment_version() {
   local usage=" USAGE: $FUNCNAME <version> [<position>] [<leftmost>]
    <version> : The version string.
   <position> : Optional. The position (starting with one) of the number
                within <version> to increment.  If the position does not
                exist, it will be created.  Defaults to last position.
   <leftmost> : The leftmost position that can be incremented.  If does not
                exist, position will be created."

   # Get arguments.
   if [ ${#@} -lt 1 ]; then echo "$usage"; return 1; fi
   local v="${1}"             # version string
   local targetPos=${2-last}  # target position
   local minPos=${3-${2-0}}   # minimum position

   # Split version string into array using its periods.
   local IFSbak; IFSbak=IFS; IFS='.' # IFS restored at end of func to
   read -ra v <<< "$v"               #  avoid breaking other scripts.

   # Determine target position.
   if [ "${targetPos}" == "last" ]; then
      if [ "${minPos}" == "last" ]; then minPos=0; fi
      targetPos=$((${#v[@]}>${minPos}?${#v[@]}:$minPos)); fi
   if [[ ! ${targetPos} -gt 0 ]]; then
      echo -e "Invalid position: '$targetPos'\n$usage"; return 1; fi
   (( targetPos--  )) || true # offset to match array index

   # Make sure minPosition exists.
   while [ ${#v[@]} -lt ${minPos} ]; do v+=("0"); done;

   # Increment target position.
   v[$targetPos]=`printf %0${#v[$targetPos]}d $((10#${v[$targetPos]}+1))`;

   for (( p=$((${#v[@]}-1)); $p>$targetPos; p-- )); do v[$p]=0; done;

   echo "${v[*]}"
   IFS=IFSbak
   return 0
}

STEP=3

while [ "$#" -gt 0 ]; do
  case "$1" in
    -s) STEP="$2"; shift 2;;
    -c) RELEASENAME="$2"; shift 2;;

    --step=*) STEP="${1#*=}"; shift 1;;
    --releasename=*) RELEASENAME="${1#*=}"; shift 1;;
    --step|--releasename) echo "$1 requires an argument" >&2; exit 1;;

    -*) echo "unknown option: $1" >&2; exit 1;;
    *) handle_argument "$1"; shift 1;;
  esac
done

set -e

OLD_VERSION=`cat version`
NEW_VERSION=`increment_version $OLD_VERSION $STEP`

if [ ! -z "${RELEASENAME}" ]; then
    NEW_VERSION=${OLD_VERSION}-${RELEASENAME}
fi


sed -i -e "s/${OLD_VERSION}/${NEW_VERSION}/g" version release.sh deployment/charts/openhab-cloud/Chart.yaml deployment/charts/openhab-cloud/values.yaml
