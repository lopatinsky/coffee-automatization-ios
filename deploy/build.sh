DEV_ACCOUNT='isoschepkov@gmail.com'
PASSWORD='Apisosch094epk8ov'

PROJECT_NAME="DoubleB"
DEBUG_SKIP_BUILD_STEP=0      # set to 1 if you don't want to clean and rebuild ipa files
DEBUG_SKIP_UPLOAD_STEP=0  # set to 1 if you don't want the built ipa files to be uploaded

script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
path_output="${script_path}/build" 
workspace_file="${script_path%/*}/${PROJECT_NAME}.xcworkspace"


#============
# Build
#============
if [ $DEBUG_SKIP_BUILD_STEP -eq 0 ]; then
  list=$(xcodebuild -list -workspace $workspace_file)
  list=$(echo ${list:(53+${#PROJECT_NAME})})

  schemes=($(echo $list))

# Clear schemes of Pods
  target_schemes=()
  for scheme in "${schemes[@]}"; do
    if [[ $scheme != *"Pods"* ]]; then
        target_schemes+=($scheme)
    fi
  done
  schemes=("${target_schemes[@]}")

# Display schemes on screen
  i=0
  for scheme in "${schemes[@]}";do
	 ((i++))
    echo "${i}. ${scheme}"
  done

# Wait list of build schemes
  read -p "Targets:" mainmenuinput
  target_nums=($(echo $mainmenuinput))

# Save only selected schemes
  selected_schemes=()
  for target_number in "${target_nums[@]}"; do
	 scheme=${target_schemes[$target_number-1]}
	 selected_schemes+=($scheme)
  done
  schemes=("${selected_schemes[@]}")
  schemes_count=(${#schemes[@]})


  # Clean output files
  echo "*** Remove output files in directory: $path_output"
  # do dangerous stuff
  mkdir -p $path_output   # create directory if not exists
  pushd "$path_output"  # use double quotes so path with space works
  rm *.ipa
  rm *.app.dSYM.zip
  popd


  # build each scheme, creating ipa and .dSYM.zip files
  echo
  echo "*** Start building ..."
  printf "All schemes ($schemes_count):"
  printf " \"%s\"" "${schemes[@]}"
  echo

  i=0
  for scheme in "${schemes[@]}"; do
    ((i++))
    echo
    echo Building scheme "($i/$schemes_count)": $scheme

    # Note: `ipa build` will clean and archive by default
    # Hardcoded arguments: -c release, --no-archive
    ipa build -w "$workspace_file" -s "$scheme" -c AppStore -d "$path_output"
  done
else
  echo "*** SKIPPING build step ..."
fi


#============
# Upload
#============
if [ $DEBUG_SKIP_UPLOAD_STEP -eq 0 ]; then

# Read list of AppleIDs for project Schemes
  schemes_list=()
  app_id_list=()
  while read line; do
    list=($(echo $line))
    schemes_list+=(${list[0]})
    app_id_list+=(${list[1]})
  done < "${script_path}/Targets.txt"

  # list all ipa files
  cd $path_output
  IPA_FILES=()
  for f in *.ipa; do 
    mod=${f//.ipa/}
    IPA_FILES+=("$mod")
  done
  IPA_FILES_COUNT=${#IPA_FILES[*]}

  i=0
  number_of_successful_uploads=0

  echo
  echo "*** Start uploading ..."
  for f in "${IPA_FILES[@]}"; do
    if [ "$f" == "*" ]; then 
      echo "No ipa file found."
      break
    fi

    ((i++)) # increment
    ipa=$f".ipa"
    dsym=$f".app.dSYM.zip"
    echo Uploading "($i/$IPA_FILES_COUNT)": \"$ipa\" with \"$dsym\"


    index=0
    for j in "${!schemes_list[@]}"; do
      if [[ "${f}" = "${schemes_list[$j]}" ]]; then
        index=$j
      fi
    done
    app_id="${app_id_list[$index]}"
  
    ipa distribute:itunesconnect -a "$DEV_ACCOUNT" -p "$PASSWORD" -i "$app_id" -f "${path_output}/${ipa}"  --upload
  done
fi