#!/bin/bash


# check if argument supplied or not
if [ $# -eq 0 ]
  then
        echo "error: No arguments supplied"
        exit 1
fi


ii=$1

# check if argument is an integer
re='^[0-9]+$'
if ! [[ $ii =~ $re ]] ; then
   echo "error: Argument should be an integer" >&2; exit 1
fi

str2=vasprun.xml
sim_folder=VASP_FILES

for i in $(seq 1 $ii);do
	dirname=SIM${i}
	fullpath=$sim_folder/$dirname/$str2
	full_name="$full_name $fullpath"

done

echo "The full name is: $(full_name)"

full_name="phonopy -f $full_name"

echo "Running phonopy..."

eval $full_name

echo "Done."
