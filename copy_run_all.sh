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


if [ ! -f ./INCAR ]; then
    echo "error: INCAR file not found!"
    exit 1
fi

if [ ! -f ./POTCAR ]; then
    echo "error: POTCAR file not found!"
    exit 1
fi

if [ ! -f ./KPOINTS ]; then
    echo "error: KPOINTS file not found!"
    exit 1
fi



sim_folder=VASP_FILES

if [ -d "$sim_folder" ];
then
	echo "Simulation folder already exists."
	echo "Proceeding will remove all existing files in the folder."
	read -p "Are you sure? (y or n): " -n 1 -r
	echo    # (optional) move to a new line
	
	if [[ ! $REPLY =~ ^[Yy]$ ]]
	then
		    exit 1
	else
		rm -rf $sim_folder
		echo "All earlier files removed."
	fi
fi

mkdir $sim_folder
echo "New simulation folder created."

echo "Copying files."

for i in $(seq 1 $ii);do
	dirname=SIM${i}
	fullpath=$sim_folder/$dirname
	mkdir -p $fullpath
	
	poscar_name=POSCAR-`printf %03d $i`

 	cp $poscar_name $fullpath/POSCAR	
	cp INCAR $fullpath
	cp POTCAR $fullpath
	cp KPOINTS $fullpath

	curr_path=$(pwd)
	cd $fullpath

	cat>job.mpi<<!
#!/bin/sh
#SBATCH --job-name=ph_$i
#SBATCH --ntasks=4
#SBATCH --output=output.log
#SBATCH --exclude=excelso

echo "Starting batch job $SLURM_JOB_ID"

srun vasp5
!
	
	sbatch job.mpi
	cd $curr_path
done

echo "Done."
