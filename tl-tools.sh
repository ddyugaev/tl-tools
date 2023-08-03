#!/usr/bin/env bash

delimiter="___________________________________________________________________"
GREEN_COLOR="\033[0;32m"
YELLOW_COLOR="\033[33m"
DEFAULT="\033[0m"

function tl_organize_and_create_demo {
	clear
	# Checking for at least one subdirectory existing
	ls -d */ > /dev/null
	if [ $? -eq 0 ]
	then
		echo -e "${GREEN_COLOR}[OK] ${DEFAULT}At least one subfolder exists"
	else
		echo -e "${YELLOW_COLOR}[SKIP] ${DEFAULT}No subfolders founded"
		exit 1
	fi
	# Create folder structure, move files and create demo
	for i in */;
		do
			echo $delimiter
			dir=$(echo $i | sed 's|/$||');
			rawfiles=$(find "$dir" -type f -maxdepth 1 \( -name "*.ARW" -or -name "*.CR2" -or -name "*.NEF" \))

			if [ ! -d "$dir/Raw" ] && [ ! -z "$rawfiles" ]; then
				echo -e "${GREEN_COLOR}[OK] ${DEFAULT}The folder Raw does NOT exist in $dir"
				echo -e "${GREEN_COLOR}[OK] ${DEFAULT}Creating Raw folder in $dir"
				mkdir -p "$dir/Raw"
				cr2file=$(find "$dir" -maxdepth 1 -type f -name "*.CR2")
				arwfile=$(find "$dir" -maxdepth 1 -type f -name "*.ARW")
				neffile=$(find "$dir" -maxdepth 1 -type f -name "*.NEF")
				if [ ! -z "$cr2file" ]; then
					echo -e "${GREEN_COLOR}[OK] ${DEFAULT}Moving CR2 files to $dir/Raw/"
					mv "$dir/"*.CR2 "$dir/Raw/"
				fi
				if [ ! -z "$arwfile" ]; then
					echo -e "${GREEN_COLOR}[OK] ${DEFAULT}Moving ARW files to $dir/Raw/"
					mv "$dir/"*.ARW "$dir/Raw/"
				fi
				if [ ! -z "$neffile" ]; then
					echo -e "${GREEN_COLOR}[OK] ${DEFAULT}Moving NEF files to $dir/Raw/"
					mv "$dir/"*.NEF "$dir/Raw/"
				fi
			else
				echo -e "${YELLOW_COLOR}[SKIP] ${DEFAULT}The folder Raw exists in $dir or no Raw files in directory"
			fi

			jpgfiles=$(find "$dir" -type f -maxdepth 1 -name "*.JPG")
			if [ ! -d "$dir/Jpg" ] && [ ! -z "$jpgfiles" ]; then
				echo -e "${GREEN_COLOR}[OK] ${DEFAULT}The folder Jpg does NOT exist in $dir"
				echo -e "${GREEN_COLOR}[OK] ${DEFAULT}Creating Jpg folder in $dir"
				mkdir -p "$dir/Jpg"
				echo -e "${GREEN_COLOR}[OK] ${DEFAULT}Moving JPG files to $dir/Jpg/"
				mv "$dir/"*.JPG "$dir/Jpg/"
				if [ -f "$dir/demo.mov" ]; then
					echo -e "${GREEN_COLOR}[OK] ${DEFAULT}Rename $dir/demo.mov to $dir/demo_old.mov"
					mv "$dir/demo.mov" "$dir/demo_old.mov"
				fi
				echo -e "${GREEN_COLOR}[OK] ${DEFAULT}Creating demo timelapse from JPGs"
				ffmpeg -framerate 25 -pattern_type glob -i "$dir/Jpg/*.JPG" -c:v libx264 -pix_fmt yuv420p "$dir/demo.mp4"
				#tlassemble "$dir/"Jpg "$dir/"demo.mov -fps 25 -height 1080 -codec h264 -quality high
			else
				echo "${YELLOW_COLOR}[SKIP] ${DEFAULT}The folder Jpg exists in $dir or no Jpg files in directory"
				echo "${GREEN_COLOR}[OK] ${DEFAULT}Looking for Raw files to create preview"
				if [ -d "$dir/Raw" ] && [ ! -d "$dir/Jpg" ]; then
					echo "${GREEN_COLOR}[OK] ${DEFAULT}Creating JPGs preview in $dir"
					mkdir -p "$dir/Jpg"
					cr2file=$(find "$dir/Raw" -maxdepth 1 -type f -name "*.CR2")
					arwfile=$(find "$dir/Raw" -maxdepth 1 -type f -name "*.ARW")
					neffile=$(find "$dir/Raw" -maxdepth 1 -type f -name "*.NEF")
					if [ ! -z "$arwfile" ]; then
						echo "${GREEN_COLOR}[OK] ${DEFAULT}Found ARW files"
						for i in $dir/Raw/*;
							do
								#name=${i/Raw/"Jpg"}
								#name=${name%%.*}
								#dcraw -c $i | pnmtojpeg > $name.JPG
								dcraw -e $i
						done
						echo "${GREEN_COLOR}[OK] ${DEFAULT}Moving extracted the camera-generated thumbnail JPGs"
						mv $dir/Raw/*.jpg $dir/Jpg/
						echo "${GREEN_COLOR}[OK] ${DEFAULT}Creating preview from JPGs"
						ffmpeg -framerate 25 -pattern_type glob -i "$dir/Jpg/*.jpg" -c:v libx264 -pix_fmt yuv420p -vf scale="1280:-2" "$dir/demo.mp4"
					fi
					if [ ! -z "$cr2file" ]; then
						echo "${GREEN_COLOR}[OK] ${DEFAULT}Found CR2 files"
					fi
					if [ ! -z "$neffile" ]; then
						echo "${GREEN_COLOR}[OK] ${DEFAULT}Found NEF files"
					fi
				else
					echo "${YELLOW_COLOR}[SKIP] ${DEFAULT}The folder Jpg exists in $dir or no Raw to create preview"
				fi
			fi
	done

}

function 360_organize {
	clear
	# Checking for at least one subdirectory existing
	ls -d */ > /dev/null
	if [ $? -eq 0 ]
	then
        echo -e "${GREEN_COLOR}[OK] ${DEFAULT}At least one subfolder exists"
	else
        echo -e "${YELLOW_COLOR}[SKIP] ${DEFAULT}No subfolders founded" >&2
        exit 1
	fi

    for i in */;
        do
            echo $delimiter
            dir=$(echo $i | sed 's|/$||');

            #Checking if DNG folder not exist in subdirectory and DNG files exist
            dngfiles_check=$(find "$dir" -type f -maxdepth 1 \( -name "*.dng" \))
            if [ ! -d "$dir/DNG" ] && [ ! -z "$dngfiles_check" ]; then
                echo -e "${GREEN_COLOR}[OK] ${DEFAULT}The folder DNG does NOT exist in $dir"
                echo -e "${GREEN_COLOR}[OK] ${DEFAULT}Creating DNG folder in $dir"
                mkdir -p "$dir/DNG"
                dngfiles=$(find "$dir" -maxdepth 1 -type f -name "*.dng")
                if [ ! -z "$dngfiles" ]; then
                    echo -e "${GREEN_COLOR}[OK] ${DEFAULT}Moving DNG files to $dir/DNG/"
                    mv "$dir/"*.dng "$dir/DNG/"
                fi
            else
                echo -e "${YELLOW_COLOR}[SKIP] ${DEFAULT}The folder DNG exists in $dir or no DNG files in directory"
            fi

            #Checking if INSP folder not exist in subdirectory and INSP files exist
            inspfiles_check=$(find "$dir" -type f -maxdepth 1 \( -name "*.insp" \))
            if [ ! -d "$dir/INSP" ] && [ ! -z "$inspfiles_check" ]; then
                echo -e "${GREEN_COLOR}[OK] ${DEFAULT}The folder INSP does NOT exist in $dir"
                echo -e "${GREEN_COLOR}[OK] ${DEFAULT}Creating INSP folder in $dir"
                mkdir -p "$dir/INSP"
                inspfiles=$(find "$dir" -maxdepth 1 -type f -name "*.insp")
                if [ ! -z "$inspfiles" ]; then
                    echo -e "${GREEN_COLOR}[OK] ${DEFAULT}Moving INSP files to $dir/INSP/"
                    mv "$dir/"*.insp "$dir/INSP/"
                fi
            else
                echo -e "${YELLOW_COLOR}[SKIP] ${DEFAULT}The folder INSP exists in $dir or no INSP files in directory"
            fi

            #Checking if Video folder not exist in subdirectory and INSV files exist
            insvfiles_check=$(find "$dir" -type f -maxdepth 1 \( -name "*.insv" \))
            if [ ! -d "$dir/Video" ] && [ ! -z "$insvfiles_check" ]; then
                echo -e "${GREEN_COLOR}[OK] ${DEFAULT}The folder Video does NOT exist in $dir"
                echo -e "${GREEN_COLOR}[OK] ${DEFAULT}Creating Video folder in $dir"
                mkdir -p "$dir/Video"
                insvfiles=$(find "$dir" -maxdepth 1 -type f -name "*.insv")
                if [ ! -z "$insvfiles" ]; then
                    echo -e "${GREEN_COLOR}[OK] ${DEFAULT}Moving Video files to $dir/Video/"
                    mv "$dir/"*.insv "$dir/Video/"
                fi
            else
                echo -e "${YELLOW_COLOR}[SKIP] ${DEFAULT}The folder Video exists in $dir or no INSV files in directory"
            fi
    done
}

function move_lightroom_folders {
	clear
	for i in */;
		do
			echo $delimiter
			dir=$(echo $i | sed 's|/$||');

			if [ ! -d "$dir/Lightroom" ]; then
				if [ ! -d "$dir/Raw/Lightroom" ]; then
					echo -e "${YELLOW_COLOR}[SKIP] ${DEFAULT}The Lightroom folder does NOT exist in $dir/Raw"
				else
					echo -e "${GREEN_COLOR}[OK] ${DEFAULT}Moving Lightroom folder in $dir"
					mv "$dir/Raw/Lightroom" "$dir/Lightroom"
				fi
			else
				echo -e "${YELLOW_COLOR}[SKIP] ${DEFAULT}The Lightroom folder does EXIST in $dir"
			fi
	done;
}

# Create AE project and txt files
function create_ae_project {
	# Checking for at least one subdirectory existing
	clear
	ls -d */ > /dev/null
	if [ $? -eq 0 ]; then
		echo -e "${GREEN_COLOR}[OK] ${DEFAULT}At least one subfolder exists"
	else
		echo -e "${YELLOW_COLOR}[SKIP] ${DEFAULT}No subfolders founded" >&2
		exit 1
	fi
	# Checking subdirectories and creating project files if they not exist
	for i in */;
		do
			echo $delimiter
			dir=$(echo -e $i | sed 's|/$||');
			if [ -f "$dir/$dir.aep" ]; then
				echo -e "${YELLOW_COLOR}[SKIP] ${DEFAULT}The project file $dir.aep already exists"
			else
				echo -e "${GREEN_COLOR}[OK] ${DEFAULT}Creating project file in $dir folder"
				cp ~/Projects/tl-tools/templates/ae_template.aep "$dir/$dir.aep"
			fi
			if [ -f "$dir/$dir.txt" ]; then
				echo -e "${YELLOW_COLOR}[SKIP] ${DEFAULT}The project file $dir.txt already exists"
			else
				echo -e "${GREEN_COLOR}[OK] ${DEFAULT}Creating description file in $dir folder"
				touch "$dir/$dir.txt"
			fi
	done
}

function bf_move_raw_files {
	if [ ! -d "Raw" ]; then
		echo -e "${GREEN_COLOR}[OK] ${DEFAULT}The folder Raw does NOT exist."
		echo -e "${GREEN_COLOR}[OK] ${DEFAULT}Creating Raw folder."
		mkdir -p "Raw"
	else
		echo -e "${YELLOW_COLOR}[SKIP] ${DEFAULT}The folder Raw does exist."
	fi

	for i in */*.ARW;
		do
			dir=$(echo $i | cut -f1 -d "/")
			if [ $dir == "Raw" ]; then
				echo -e "${YELLOW_COLOR}[SKIP] ${DEFAULT}Raw folder."
			else
				file=$(echo $i | cut -f2 -d "/")
				if [ ! -f "Raw/$file" ]; then
					echo -e "${GREEN_COLOR}[OK] ${DEFAULT}Moving $i files to Raw/"
					mv "$i" "Raw/"
				else
					echo -e "${YELLOW_COLOR}[SKIP] ${DEFAULT}$i exist in Raw."
				fi
			fi
	done
}

function bf_n_move {
	read -r -p "Keep every nth photo. Enter n: " n
	case $n in
		''|*[!0-9]*)
			echo "Not a number"
			exit 1
			;;
		*)
			echo "Keeping every $n photo"
			;;
	esac

	x=1
	dir=(${PWD##*/})
	rawfiles=$(find . -name "*.ARW")
	if [ ! -d "../${dir}_KEEP" ] && [ -n "$rawfiles" ]; then
		echo -e "${GREEN_COLOR}[OK] ${DEFAULT}The folder ../${dir}_KEEP does NOT exist."
		echo -e "${GREEN_COLOR}[OK] ${DEFAULT}Creating ../${dir}_KEEP folder."
		mkdir -p "../${dir}_KEEP"
	else
		echo -e "${YELLOW_COLOR}[SKIP] ${DEFAULT}The folder ${dir}_KEEP does exist or no ARW files in folder"
		exit 1
	fi

	for i in *.ARW;
		do
			if [ ! -f "../${dir}_KEEP/$i" ]; then
				if [ $x == "$n" ]; then
					echo -e "${GREEN_COLOR}[OK] ${DEFAULT}Moving $i files to ../${dir}_KEEP"
					mv "$i" "../${dir}_KEEP"
					x=1
				else
					echo -e "${YELLOW_COLOR}[SKIP] ${DEFAULT}(x=$x) $i "
					x=$((x+1))
				fi
			else
				echo -e "${YELLOW_COLOR}[SKIP] ${DEFAULT}$i exist in ../${dir}_KEEP"
			fi
	done
}

function help {
	# Display Help
	echo
	echo -e "Syntax: tl-tools.sh [-h|-d|-360|-lr|-p|-bfr|-bfn]"
	echo -e "options:"
	echo -e "${YELLOW_COLOR}-h | --help${DEFAULT}       Show help"
	echo -e "${YELLOW_COLOR}-d | --demo${DEFAULT}       Organize photos and create demo from JPGs. (Run from folder with subfolders projects)"
	echo -e "${YELLOW_COLOR}-360${DEFAULT}              Organize 360. Separating files by type. (Run from folder with subfolders projects)"
	echo -e "${YELLOW_COLOR}-lr${DEFAULT}               Move lightroom forders ./ (Run from folder with subfolders projects)"
	echo -e "${YELLOW_COLOR}-p | --project${DEFAULT}    Create project files. Create blank AF .aep and .txt. (Run from folder with subfolders projects)"
	echo -e "${YELLOW_COLOR}-bfr${DEFAULT}              Move ARW files from subfolders to Raw folder. (Run from project's folder with ARW in subfolders)"
	echo -e "${YELLOW_COLOR}-bfn${DEFAULT}              Move nth photo to folder _KEEP. (Run from project's folder with ARW in subfolders)"
	echo
}

while :
do
	case "$1" in
		-h | --help)
			help
			exit 0
			;;
		-d | --demo)
			tl_organize_and_create_demo
			exit 0
			;;
		-360 )
			360_organize
			exit 0
			;;
		-lr )
			move_lightroom_folders
			exit 0
			;;
		-p | --project)
			create_ae_project
			exit 0
			;;
		-bfr )
			bf_move_raw_files
			exit 0
			;;
		-bfn )
			bf_n_move
			exit 0
			;;
		--) # End of all options
			shift
			break
			;;
		-*)
			echo -e "${YELLOW_COLOR}[ERROR] ${DEFAULT}Unknown option: $1" >&2
			help
			exit 1
			;;
		*)  # No more options
			help
			break
			exit 1
			;;
	esac
done
