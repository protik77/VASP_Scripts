#!/bin/bash
#############################################################################
#				VASP RUNNER
#		  	   Written by: Protik Das
#			      pdas001@ucr.edu
#
# This script runs vasp on gordon supercomputer at SDSC.		
# 
# This scripts removes old files from staging area, then copies vasp INPUT
# files to staging are. User needs to give the input of certain variables.
# These are:
#	JOB_NAME  -> Name of the job
#	MODE	  -> Copy mode: scf, ek or hse
#	EXEC_NAME -> Name of the executable (vasp or vasp_ncl)
#	NODE	  -> Number of nodes intended
#	CORE	  -> Number of cores per node
#	TIME	  -> Max time for the job
#	MAIL	  -> Mail address to send job status
#	STT	  -> States to send the mail. 
#		     a for abort, b for begin, e for end
#############################################################################

# User input.
# Name of job
JOB_NAME="test"
# Name of the executable: vasp or vasp_ncl
EXEC_NAME="vasp"
# Copy mode, 'scf', 'ek' or 'hse'
MODE="scf"
# Number of nodes intended.
NODE=1
# Number of cores per node
CORE=16
# Time for the job. Max 48:00:00
TIME=48:00:00
# Mail address to send email
MAIL="pdas001@ucr.edu"
# States to send email aborts (a), begins (b), or ends (e): i.e. abe
STT="e"

# housekeeping
RUN_DIR=/oasis/scratch/$USER/temp_project/
CUR_DIR=$(pwd)
red=`tput setaf 1`
reset=`tput sgr0`

printf "\n\n######  VASP RUNNER is running ######\n\n"

## declare an array variable according to mode
if [ $MODE == "scf" ]; then
   declare -a file_to_copy=("POSCAR" "POTCAR" "KPOINTS" "INCAR")
elif [ $MODE == "ek" ]; then
   declare -a file_to_copy=("POSCAR" "POTCAR" "KPOINTS" "INCAR" "CHGCAR")
elif [ $MODE == "hse" ]; then
   declare -a file_to_copy=("POSCAR" "POTCAR" "KPOINTS" "INCAR" "WAVECAR")
else
   echo "${red}ERROR: Modes supported: scr or ek or hse. Aborting.${reset}"
   exit 1
fi

printf "\n$MODE mode selected. Creating simulation folder. \n"

SIM_FOLDER=$(cat /dev/urandom | tr -cd 'a-z0-9' | head -c 7)

printf "\nName of the semi-unique simulation directory: $SIM_FOLDER.\n"
printf "Copying the name to file \"directory.name\". Just in case you need it.\n"

cat>directory.name<<!
Name of the simulation folder: $SIM_FOLDER
!

printf "Creating simulation directory.. "
cd $RUN_DIR
mkdir $SIM_FOLDER
cd  $SIM_FOLDER
RUN_DIR=$(pwd)
cd $CUR_DIR
printf "done.\n"

## now loop through the above array
echo "Copying INPUT files to simulation directory."
printf "\n"

printf "Checking for required input files.\n"
for i in "${file_to_copy[@]}"
do
   if [ ! -f $i ]; then
       printf "\n"
       echo "${red}ERROR: $i file not found. Aborting.${reset}"
       rm -rf $RUN_DIR
       exit 1
   fi
done

echo "Copying INPUT files to simulation directory."
printf "\n"
printf "Copying: "
for i in "${file_to_copy[@]}"
do
   cp $i $RUN_DIR
   printf "$i, "
done
printf " done.\n"

cat > gordon.mpi<<!
#!/bin/bash
#PBS -q normal
#PBS -l nodes=$NODE:ppn=$CORE:native
#PBS -l walltime=$TIME
#PBS -N $JOB_NAME
#PBS -o output.log
#PBS -e error.log
#PBS -M $MAIL
#PBS -m $STT
#PBS -A TG-DMR130081

cd $RUN_DIR

module load vasp/5.4.1

VASP=\$(which $EXEC_NAME)

mpirun_rsh -np $(($NODE * $CORE)) -hostfile \$PBS_NODEFILE \$VASP
!

echo "Created job script."


JOBID=$(qsub gordon.mpi)
echo "Job is queued. Job ID is: $JOBID"
printf "\nWaiting for the job to be completed."
while qstat $JOBID &> /dev/null; do
    sleep 30
    printf "."
done;

printf "\n"

rsync -azc "$RUN_DIR/" "$CUR_DIR/"

if [[ $? -gt 0 ]] 
then
   printf "\n"
   echo "${red}ERROR: sync of simulation directory was unsucccessful.${reset}"
   echo "Go to: $RUN_DIR and copy the OUTPUT files manually."
else
   printf "\n"
   echo "Sync was successful."
   echo "All output files are copied into current folder."
   printf "\nRemoving $RUN_DIR.. "
   rm -rf $RUN_DIR
   printf "Done\n"
fi

