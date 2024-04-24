#/bin/bash

# ---------------------------------------------------------------------
# MIDI-Val - CSU Chico Capstone Project By Max Stickels
# Advisor: Professor Todd Gibson
# Automatically generate medieval files in the style of medieval music!
# Run this script with "-h" as the first argument to learn how!
#----------------------------------------------------------------------

# Text color specifiers
RED='\033[1;31m'
YELLOW='\033[1;33m'
NYELLOW='\033[0;33m' # Note yellow
GREEN='\033[1;32m'
NGREEN='\033[0;32m'
CYAN='\033[1;36m'
NCYAN='\033[0;36m' # Note cyan
PINK='\033[1;35m'
NONE='\033[0m' # No Color

# Essential files (must be available to read/write/append/create/delete)
NOTEFILE="x.midival" # File to store note data (temporary, will always be overwritten by program)
ANTIFILE="a.midival" # File to store antiphonal response data (also temporary)

[[ -f $NOTEFILE ]] && rm $NOTEFILE
[[ -f $ANTIFILE ]] && rm $ANTIFILE

# Print help if help flag is passed as an argument
for ARG in "$@"
do
if [[ "$ARG" == "-h" || "$ARG" == "--help" ]]; then 
echo -e "\n${CYAN}USAGE: bash midi-val.sh [ -h | -i <INSTRUMENT_NUMBER> | -k <KEY_SIGNATURE> | -o <OUTPUT_FILE> | -l <LENGTH> | -p <PITCH> | -s <STYLE> | -t <TEMPO> ]\n${NONE}"
echo -e "${GREEN}-h OR --help                                                                     ${YELLOW}Prints this page and exits\n${NONE}"
echo -e "${GREEN}-i OR --instrument <INSTRUMENT_NUMBER>                                           ${YELLOW}Select instrument${NONE}"
echo -e "    Default: 19 (Church Organ)"
echo -e "    Range: 0 to 127"
echo -e "    Examples: -i 0 = Acoustic Grand Piano, -i 3 = Honky Tonk Piano\n"
echo -e "${GREEN}-k OR --key OR --keysig <KEY_SIGNATURE>                                          ${YELLOW}Select key signature${NONE}"
echo -e "    Default: CM (C Major)"
echo -e "    Examples: -k D#m = D Sharp Minor, -k GbM = G Flat Major, -k Bm = B Minor"
echo -e "    ${NCYAN}Note: # = Sharp, b = Flat, m = Minor, M = Major${NONE}\n"
echo -e "${GREEN}-l OR --length <LENGTH>                                                          ${YELLOW}Set song length (beats)${NONE}"
echo -e "    Default: 16 beats; 32 if antiphonal style is chosen"
echo -e "    Examples: -l 20 = Output file will last for 20 beats (1 beat = 1 half note)"
echo -e "    ${NCYAN}Note: Length may be greater than requested for antiphonal style MIDIs${NONE}\n"
echo -e "${GREEN}-o OR --output <OUTPUT_FILE>                                                     ${YELLOW}Select output destination${NONE}"
echo -e "    Default: output.mid"
echo -e "    Example: -o 1234.mid = Saves output to file 1234.mid\n"
echo -e "${GREEN}-p OR --pitch <PITCH>                                                            ${YELLOW}Add pitch shift${NONE}"
echo -e "    Default: 50 (equal to default system tuning)"
echo -e "    Range: 0 to 100 (translated to -50 to 50 cents; tuning may vary by system)"
echo -e "    Example: -p 10 = Music will be about 40 cents flat\n"
echo -e "${GREEN}-s OR --style <STYLE>                                                            ${YELLOW}Select output style${NONE}"
echo -e "    Default: Monophonic Chant"
echo -e "    Options: -s 0 = Monophonic Chant, -s 1 = Strict Homophonic Chant, -s 2 = Antiphonal (responsorial)\n"
echo -e "${GREEN}-t OR --tempo <TEMPO>                                                            ${YELLOW}Set song tempo (beats per minute)${NONE}"
echo -e "    Default: 120BPM"
echo -e "    Range: 40BPM and above"
echo -e "    Example: -t 108 = 108BPM"
exit 0
fi
done

# Print Header
echo "--------------------------------------------------------------------------------"
echo -e "        ${YELLOW}MIDI-Val: Automatically Generate Medieval-Era Music Files!${NONE}"

# Iterators
I=0
J=0

# Other variables
OUTPUTFILE="output.mid" # File for output
TRACKSIZE=0 # Variable for calculating track size (must match exactly)
TEMPO=500000 # Microseconds per beat (default = 120 BPM, 500000 us per beat)
ARGTEMPO=120 # Tempo in BPM (provided as argument)
INSTRUMENT=19 # Default to (usually) church organ 
STYLE=0 
STYLES=("Monophonic" "Strict Homophonic" "Antiphonal")
PITCH=50 # Changed to 0-100 if pitch modulation is supplied
KEYSIG=0 # Number of flats / sharps (max of 7)
KEYNUM=7 # Position of key signature in KEYSIGS array
MAJMIN=0 # 0 if major key, 1 if minor key
MAJKEYS=(-12 -10 -8 -7 -5 -3 -1 0 2 4 5 7 9 11) # Distance from root note
MINKEYS=(-12 -10 -9 -7 -5 -4 -2 0 2 3 5 7 8 10) 
SIZEOFKEY="${#MAJKEYS[@]}"
# Each root note is a fifth above the previous (even between C#M and Abm!), so root for any key = value of B4 + (7 * I % 12)
KEYSIGS=("CbM" "GbM" "DbM" "AbM" "EbM" "BbM" "FM" "CM" "GM" "DM" "AM" "EM" "BM" "F#M" "C#M" "Abm" "Ebm" "Bbm" "Fm" "Cm" "Gm" "Dm" "Am" "Em" "Bm" "F#m" "C#m" "G#m" "D#m" "A#m")
# Full keysig names for key signature output
FULLKEYSIGS=("C Flat Major" "G Flat Major" "D Flat Major" "A Flat Major" "E Flat Major" "B Flat Major" "F Major" "C Major" "G Major" "D Major" "A Major" "E Major" "B Major" "F Sharp Major" "C Sharp Major" "A Flat Minor" "E Flat Minor" "B Flat Minor" "F Minor" "C Minor" "G Minor" "D Minor" "A Minor" "E Minor" "B Minor" "F Sharp Minor" "C Sharp Minor" "G Sharp Minor" "D Sharp Minor" "A Sharp Minor")
BEATS=16 # Number of beats (passed in as length argument)
BEATSFLAG=0 # If beats is unspecified in antiphonal style, default needs to change to 32

# Argument-free attribute entry system
if [[ ! -z $1 ]]; then
    echo -e "          Run with \"-h\" or \"--help\" flags for usage information,\n           or run without flags to enter each setting manually."
    echo "--------------------------------------------------------------------------------"
    echo -e "${GREEN}Command line arguments used! Any errors/warnings will appear here.${NONE}"
    echo -e "${NGREEN}(MIDI-Val will try to continue with defaults if any arguments are invalid.)\n${NONE}"
else
    VALID=0
    echo -e "       This program supports quick and easy command-line arguments!\n           Run it with the \"-h\" or \"--help\" flag to learn more."
    echo "--------------------------------------------------------------------------------"
    echo -e "${CYAN}For each of the following prompts, type in an accepted value, then press ENTER.\nYou may also simply press ENTER to use the default setting.\n${PINK}Press ^C (Ctrl+C) or type ${NYELLOW}exit${PINK} into a prompt to exit.${NONE}"
    # Style
    while [[ "$VALID" -eq 0 ]]; do
        printf "\n${GREEN}Select a style! [DEFAULT = 0]\n${NGREEN}(0 = Monophonic, 1 = Strict Homophonic, 2 = Antiphonal): ${NONE}"; read ARG
        if [[ "$ARG" == [eE][xX][iI][tT] ]]; then
            echo -e "${NYELLOW}Exiting now. Come back again soon!"; 
            exit 0
        fi
        if [[ -z "$ARG" ]]; then
            echo -e "${NYELLOW}Prompt skipped - using default value.${NONE}"
            ((VALID++))
        else
            if [[ ! "$ARG" == [012] ]]; then
                echo -e "${PINK}Invalid style number \"$ARG\".${NONE} Please choose an integer value from 0 to 2 inclusive."
            else 
                STYLE=$((10#$ARG))
                ((VALID=1))
            fi
        fi
    done;VALID=0
    # Tempo
    while [[ "$VALID" -eq 0 ]]; do
        printf "\n${GREEN}Select a tempo in BPM (beats per minute)! [DEFAULT = 120]: ${NONE}"; read ARG
        if [[ "$ARG" == [eE][xX][iI][tT] ]]; then
            echo -e "${NYELLOW}Exiting now. Come back again soon!"; 
            exit 0
        fi
        if [[ -z "$ARG" ]]; then
            echo -e "${NYELLOW}Prompt skipped - using default value.${NONE}"
            ((VALID++))
        else
            if ! [[ "$ARG" =~ ^[0-9]+$ && "$((10#$ARG))" -ge 40 ]] 2> /dev/null; then
                echo -e "${PINK}Invalid tempo \"$ARG\".${NONE} Please choose an integer value of 40 or greater."
            else 
                TEMPO=$((60000000 / $ARG))
                ARGTEMPO=$((10#$ARG))
                [[ "$TEMPO" -eq 0 ]] && ((TEMPO++))
                ((VALID=1))
            fi
        fi
    done;VALID=0
    # Length (Beats)
    while [[ "$VALID" -eq 0 ]]; do
        printf "\n${GREEN}How long should the song be (total number of beats)? [DEFAULT = 16]\n${NGREEN}(The default is *at least* 32 beats for antiphonal songs): ${NONE}"; read ARG
        if [[ "$ARG" == [eE][xX][iI][tT] ]]; then
            echo -e "${NYELLOW}Exiting now. Come back again soon!"; 
            exit 0
        fi
        if [[ -z "$ARG" ]]; then
            echo -e "${NYELLOW}Prompt skipped - using default value.${NONE}"
            ((VALID++))
        else
        if ! [[ "$ARG" =~ ^[0-9]+$ && "$((10#$ARG))" -gt 0 ]] 2> /dev/null; then
                echo -e "${PINK}Invalid song length \"$ARG\".${NONE} Please choose an integer value greater than 0."
            else 
                BEATS=$((10#$ARG))
                ((BEATSFLAG++))
                ((VALID=1))
            fi
        fi
    done;VALID=0
    # Key signature
    while [[ "$VALID" -eq 0 ]]; do
        printf "\n${GREEN}Select a key signature! [DEFAULT = CM = C Major]\n${NGREEN}(Or type ${NYELLOW}list${NGREEN} to see all accepted options): ${NONE}"; read ARG
        if [[ "$ARG" == [eE][xX][iI][tT] ]]; then
            echo -e "${NYELLOW}Exiting now. Come back again soon!"; 
            exit 0
        fi
        if [[ -z "$ARG" ]]; then
            echo -e "${NYELLOW}Prompt skipped - using default value.${NONE}"
            ((VALID++))
        else
            # "list" case; no error but still not valid to continue here, i.e it should loop again
            if [[ "$ARG" == [lL][iI][sS][tT] ]]; then
                printf "${CYAN}All options (case sensitive): ${NCYAN}CbM, GbM, DbM, AbM, EbM, BbM, FM, CM, GM, DM, AM, EM, BM, F#M, C#M, Abm, Ebm, Bbm, Fm, Cm, Gm, Dm, Am, Em, Bm, F#m, C#m, G#m, D#m, A#m${NONE}\n"
                printf "${CYAN}Note: ${NCYAN}# = Sharp, b = Flat, m = Minor, M = Major. For exmaple, Ebm is shorthand for \"E Flat Minor\".${NONE}\n"
            else # checking for actual valid key sig
                I=0
                FOUND=0
                J="${#KEYSIGS[@]}"; ((J/=2)) # Setting J equal to half of KEYSIGS list size; splits list between major and minor sigs
                while [ $I -lt "${#KEYSIGS[@]}" ]
                do
                    if [[ "$ARG" == "${KEYSIGS[I]}" ]]; then
                        KEYNUM=$((I)) # Store index in KEYNUM
                        KEYSIG=$((I%J)); ((KEYSIG-=7)) # K=I*J-7 should represent the number of sharps/flats based on position in KEYSIGS array
                        [[ "$I" -lt "$J" ]] && MAJMIN=0 || MAJMIN=1 # First half of list is major, second half minor
                        ((FOUND++))
                        break
                    fi
                    ((I++))
                done
                [[ "$FOUND" -eq 0 ]] && echo -e "${PINK}Invalid key signature \"$ARG\".\n${NONE}Try typing ${NYELLOW}list${NONE} to see all accepted options!" || ((VALID=1))
            fi
        fi
    done;VALID=0
    # Instrument
    while [[ "$VALID" -eq 0 ]]; do
        printf "\n${GREEN}Which MIDI instrument should the song use? [DEFAULT = 19 (Church Organ)]\n${NGREEN}(A number from 0-127. For a full list of General MIDI instrument codes,\nsee https://www.cs.cmu.edu/~music/cmsip/readings/GMSpecs_Patches.htm): ${NONE}"; read ARG
        if [[ "$ARG" == [eE][xX][iI][tT] ]]; then
            echo -e "${NYELLOW}Exiting now. Come back again soon!"; 
            exit 0
        fi
        if [[ -z "$ARG" ]]; then
            echo -e "${NYELLOW}Prompt skipped - using default value.${NONE}"
            ((VALID++))
        else
            if ! [[ "$ARG" =~ ^[0-9]+$ && "$((10#$ARG))" -le 127 ]] 2> /dev/null; then
                echo -e "${PINK}Invalid instrument number \"$ARG\".${NONE} Please choose an integer value from 0 to 127 inclusive."
            else 
                INSTRUMENT=$((10#$ARG))
                ((VALID=1))
            fi
        fi
    done;VALID=0
    # Pitch Shift
    while [[ "$VALID" -eq 0 ]]; do
        printf "\n${GREEN}Would you like to detune the music? [DEFAULT = 50 (No detuning)]\n${NGREEN}(Range from 0 to 100. 0 = 50 cents flat, 100 = 50 cents sharp): ${NONE}"; read ARG
        if [[ "$ARG" == [eE][xX][iI][tT] ]]; then
            echo -e "${NYELLOW}Exiting now. Come back again soon!"; 
            exit 0
        fi
        if [[ -z "$ARG" ]]; then
            echo -e "${NYELLOW}Prompt skipped - using default value.${NONE}"
            ((VALID++))
        else
            if ! [[ "$ARG" =~ ^[0-9]+$ && "$((10#$ARG))" -le 100 ]] 2> /dev/null; then
                echo -e "${PINK}Invalid detuning value \"$ARG\".${NONE} Please choose an integer value from 0 to 100 inclusive."
            else 
                PITCH=$((10#$ARG))
                ((VALID=1))
            fi
        fi
    done;VALID=0
        # Output file name
    while [[ "$VALID" -eq 0 ]]; do
        printf "\n${GREEN}Lastly, would you like to name the song file? [DEFAULT = output.mid]\n${NGREEN}(Include a valid MIDI file extension such as .mid or .midi): ${NONE}"; read ARG
        if [[ "$ARG" == [eE][xX][iI][tT] ]]; then
            echo -e "${NYELLOW}Exiting now. Come back again soon!"; 
            exit 0
        fi
        if [[ -z "$ARG" ]]; then
            echo -e "${NYELLOW}Prompt skipped - using default file name.${NONE}"
            ((VALID++))
        else
            if [[ "$(printf $ARG | tail -c 4)" != ".mid" && "$(printf $ARG | tail -c 5)" != ".midi" ]]; then 
                echo -e -n "${PINK}Warning: file $ARG does not have a proper MIDI file extension.\n${NONE}Press ENTER to continue anyways, or press ^C (Ctrl+C) to exit."
                read $NOTHING
                [[ "$NOTHING" == [eE][xX][iI][tT] ]] && exit 0
            fi
            [[ -f $ARG ]] && (echo -e -n "${PINK}File $ARG already exists and will be overwritten.\n${NYELLOW}Make sure the file is not open in any other application.\n${NONE}Press ENTER to override the file or ^C (Ctrl+C) to exit."; read $NOTHING)
            [[ -f $ARG ]] && rm "$ARG" 
            touch "$ARG" 2> /dev/null
            if ! [[ -f $ARG ]]; then
                (echo -e "${RED}Failed to create file \"$ARG\". Please try a different file name.${NONE}")
            else
                OUTPUTFILE="$ARG"
                ((VALID++))
            fi
        fi
    done; VALID=0
fi


## Processing command line arguments iteratively
FLAG=""
for ARG in "$@"
do
    if [[ "$FLAG" == "-o" || "$FLAG" == "--output" ]]; then
        [[ -f $ARG ]] && (echo -e -n "${PINK}File $ARG already exists and will be overwritten.\n${NYELLOW}Make sure the file is not open in any other application.\n${NONE}Press ENTER to override the file or ^C (Ctrl+C) to exit."; read $NOTHING)
        [[ -f $ARG ]] && rm "$ARG" 
        touch "$ARG" 2> /dev/null
        ! [[ -f $ARG ]] && (echo -e "${RED}Failed to create file \"$ARG\"; will use default destination \"$OUTPUTFILE\".${NONE}") || OUTPUTFILE="$ARG"
    fi
    if [[ "$FLAG" == "-t" || "$FLAG" == "--tempo" ]]; then
        ! [[ "$ARG" =~ ^[0-9]+$ && "$((10#$ARG))" -ge 40 ]] 2> /dev/null && (echo -e "${PINK}Invalid tempo flag \"$FLAG $ARG\"; using default tempo of 120BPM.\n${NONE}Please choose an integer value of 40 or greater.") || (TEMPO=$((60000000 / $ARG)); ARGTEMPO=$ARG)
        [[ "$TEMPO" -eq 0 ]] && ((TEMPO++))
    fi
    if [[ "$FLAG" == "-i" || "$FLAG" == "--instrument" ]]; then
        ! [[ "$ARG" =~ ^[0-9]+$ && "$((10#$ARG))" -le 127 ]] 2> /dev/null && (echo -e "${PINK}Invalid instrument flag \"$FLAG $ARG\"; using default Church Organ.\n${NONE}Please choose an integer value from 0 to 127 inclusive.") || INSTRUMENT=$((10#$ARG))
    fi
    if [[ "$FLAG" == "-s" || "$FLAG" == "--style" ]]; then
        [[ ! "$ARG" == [012] ]] && (echo -e "${PINK}Invalid style flag \"$FLAG $ARG\".${NONE} Please choose an integer value from 0 to 2 inclusive.") || STYLE=$((10#$ARG))
    fi
    if [[ "$FLAG" == "-l" || "$FLAG" == "--length" ]]; then
        if ! [[ "$ARG" =~ ^[0-9]+$ && "$((10#$ARG))" -gt 0 ]] 2> /dev/null; then
            (echo -e "${PINK}Invalid length flag \"$FLAG $ARG\".${NONE} Please choose an integer value greater than 0.")
        else 
            BEATS=$((10#$ARG))
            ((BEATSFLAG++))
        fi
    fi
    if [[ "$FLAG" == "-p" || "$FLAG" == "--pitch" ]]; then
        ! [[ "$ARG" =~ ^[0-9]+$ && "$((10#$ARG))" -le 100 ]] 2> /dev/null && (echo -e "${PINK}Invalid pitch flag \"$FLAG $ARG\"; ignoring pitch shift.${NONE}\nPlease choose an integer value from 0 to 100 inclusive.") || PITCH=$((10#$ARG))
    fi
    if [[ "$FLAG" == "-k" || ("$FLAG" == "--key" || "$FLAG" == "--keysig") ]]; then
        I=0
        FOUND=0
        J="${#KEYSIGS[@]}"; ((J/=2)) # Setting J equal to half of KEYSIGS list size; splits list between major and minor sigs
        while [ $I -lt "${#KEYSIGS[@]}" ]
        do
            if [[ "$ARG" == "${KEYSIGS[I]}" ]]; then
                KEYNUM=$((I)) # Store index in KEYNUM
                KEYSIG=$((I%J)); ((KEYSIG-=7)) # K=I*J-7 should represent the number of sharps/flats based on position in KEYSIGS array
                [[ "$I" -lt "$J" ]] && MAJMIN=0 || MAJMIN=1 # First half of list is major, second half minor
                ((FOUND++))
                break
            fi
            ((I++))
        done
        [[ "$FOUND" -eq 0 ]] && echo -e "${PINK}Invalid key signature flag \"$FLAG $ARG\"; using default key C Major.\n${NONE}Execute MIDI-Val with no arguments or the "-h" flag for more information on key signatures."
    fi
    FLAG="$ARG"
done

# Modifying default length for antiphonal style
[[ "$STYLE" -eq 2 && "$BEATSFLAG" -eq 0 ]] && BEATS=32

## Output File Heading
[[ -f $OUTPUTFILE ]] && rm $OUTPUTFILE 
[[ -f $OUTPUTFILE ]] && (printf "${RED}Output file '$OUTPUTFILE' exists and cannot be replaced. Exiting now."; exit)
touch $OUTPUTFILE



echo "--------------------------------------------------------------------------------"
# Print File Settings To User
printf "${CYAN}Now creating file ${YELLOW}\"$OUTPUTFILE\"${CYAN} with these settings:${NONE}\n"
STYLENAME=${STYLES[STYLE]}
printf "${CYAN}* ${NCYAN}Style:${NONE} ${STYLENAME} Chant\n"
[[ "$STYLE" -lt 2 ]] && printf "${CYAN}* ${NCYAN}Song Length:${NONE} $BEATS beats\n" || printf "${CYAN}* ${NCYAN}Song Length:${NONE} At least $BEATS beats\n"
printf "${CYAN}* ${NCYAN}Key Signature:${NONE} ${KEYSIGS[KEYNUM]} (${FULLKEYSIGS[KEYNUM]})\n"
printf "${CYAN}* ${NCYAN}Tempo:${NONE} ${ARGTEMPO}BPM\n"
printf "${CYAN}* ${NCYAN}Instrument:${NONE} $INSTRUMENT\n"
printf "${CYAN}* ${NCYAN}Pitch Shift:${NONE} $((PITCH-50)) cents\n"

# MIDI File Header -- Single Track, 15360 Ticks Per Beat (Should Be Kept The Same)
printf "\x4d\x54\x68\x64\x00\x00\x00\x06\x00\x00\x00\x01\x3c\x00" > $OUTPUTFILE

# First MIDI Track Header Track Size, Tempo, Time Sig, Key Sig
printf "\x4d\x54\x72\x6b" >> $OUTPUTFILE

## Creating NOTEFILE
echo -n "" > $NOTEFILE # Creates empty file with no newline
# Pitch Wheel Event
if [[ "$PITCH" -ne 50 ]]; then
    ((PITCH-=50))
    CENTER=8192 #0x2000 is no shift; 14-bit number with highest bit of each byte as 0, so it becomes 0x4000
    NEWPITCH=$((CENTER+PITCH*41)) # 41 is approximately 4096 over 100
    PITCH1=$(printf "%02x" $((NEWPITCH/128))) # Top 7 Bits
    PITCH2=$(printf "%02x" $((NEWPITCH%128))) # Bottom 7 Bits 
    printf "\x00\xe0\x${PITCH2}\x${PITCH1}" >> $NOTEFILE
fi

# Style-Dependent Note Creation
if [[ "$STYLE" -le 1 ]]; then # MONOPHONIC AND STRICT HOMOPHONIC CHANT CASES
    ROOT=$(( 59 + (7 * KEYNUM) % 12 )) # value of root note for the given key (based on KEYNUM)
    RNG=$(echo $RANDOM) # First call to RANDOM determines interval if necessary
    [[ "$((RNG%2))" -eq 0 ]] && HT=$((ROOT+5)) || HT=$((ROOT+7))
    I=0
    while [[ "$I" -lt "$((BEATS+1))" ]]; do
        RNG=$(echo $RANDOM) # Second call to RANDOM for randomizing velocity, note size and note placement
        NOTERNG=$(( RNG%7 )) # 2/7 odds of semibreve, 4/7 odds of breve, 1/7 odds of long
        if [[ "$NOTERNG" -lt 4 || ("$I" -eq "$((BEATS-1))" || "$I" -eq 0) ]]; then # Breve (forced for first and last note)
            NOTESIZE=$(printf "\xf8") # Actual number of ticks = (248 - 128) * 128
        else 
            [[ "$NOTERNG" -eq 4 ]] && NOTESIZE=$(printf "\x81\xf0") || NOTESIZE=$(printf "\xbc") # Long (equals 4) or semibreve (greater than 4)
        fi
        VELOCITY=$(( RNG%33 + 48 )); VELOCITY=$(printf "%02x" $VELOCITY) # Setting velocity between 48 and 80
        
        # Setting offset from root note with default values if applicable
        IDX=7
        OFFSET=0
        if [[ ! "$I" -eq 0 ]]; then
            IDX=$((RNG%SIZEOFKEY))
            [[ "$MAJMIN" -eq 1 ]] && OFFSET="${MINKEYS[$IDX]}" || OFFSET="${MAJKEYS[$IDX]}"
        fi
        ROOT1=$((ROOT+OFFSET)); ROOT1=$(printf "%02x" $ROOT1 )
        HT1=$((HT+OFFSET)); HT1=$(printf "%02x" $HT1 )
        printf "\x00\x90\x${ROOT1}\x${VELOCITY}" >> $NOTEFILE
        if [[ "$STYLE" -eq 1 ]]; then
            printf "\x00\x90\x${HT1}\x${VELOCITY}" >> $NOTEFILE
        fi
        printf "$NOTESIZE\x00\x80\x${ROOT1}\x00" >> $NOTEFILE
        if [[ "$STYLE" -eq 1 ]]; then
            printf "\x00\x80\x${HT1}\x00" >> $NOTEFILE
        fi
        if [[ "$NOTERNG" -gt 4 ]]; then # Semibreve case has two notes
            IDX2=$((RANDOM%5+IDX-2))
            [[ "$MAJMIN" -eq 1 ]] && OFFSET2="${MINKEYS[$IDX2]}" || OFFSET2="${MAJKEYS[$IDX2]}"
            [[ "$IDX2" -lt 0 ]] && IDX2=0 # If second note is too low
            [[ "$IDX2" -ge "$SIZEOFKEYS" ]] && IDX2=$((SIZEOFKEYS-1)) # If second note is too high
            ROOT2=$((ROOT+OFFSET2)); ROOT2=$(printf "%02x" $ROOT2 )
            HT2=$((HT+OFFSET2)); HT2=$(printf "%02x" $HT2 )
            printf "\x00\x90\x${ROOT2}\x${VELOCITY}" >> $NOTEFILE
            if [[ "$STYLE" -eq 1 ]]; then
                printf "\x00\x90\x${HT2}\x${VELOCITY}" >> $NOTEFILE
            fi
            printf "$NOTESIZE\x00\x80\x${ROOT2}\x00" >> $NOTEFILE
            if [[ "$STYLE" -eq 1 ]]; then
                printf "\x00\x80\x${HT2}\x00" >> $NOTEFILE
            fi
        fi
        [[ "$NOTERNG" -eq 4 ]] && ((I+=2)) || ((I++)) # Long case is 2 beats
    done
else # ANTIPHONAL CASE
    ROOT=$(( 59 + (7 * KEYNUM) % 12 )) # value of root note for the given key (based on KEYNUM)
    RNG=$(echo $RANDOM) # First call to RANDOM determines interval
    [[ "$((RNG%2))" -eq 0 ]] && HT=$((ROOT+5)) || HT=$((ROOT+7))
    I=0
    # Setting up 8-beat response in ANTIFILE
    while [[ "$I" -lt 8 ]]; do
        RNG=$(echo $RANDOM) # Second call to RANDOM for randomizing velocity, note size and note placement
        NOTERNG=$(( RNG%7 )) # 1/7 odds of semibreve, 5/7 odds of breve, 1/7 odds of long
        if [[ "$NOTERNG" -lt 5 || ("$I" -eq "$((BEATS-1))" || "$I" -eq 0) ]]; then # Breve (forced for first and last note)
            NOTESIZE=$(printf "\xf8") # Actual number of ticks = (248 - 128) * 128
        else 
            [[ "$NOTERNG" -eq 5 ]] && NOTESIZE=$(printf "\x81\xf0") || NOTESIZE=$(printf "\xbc") # Long (equals 4) or semibreve (greater than 4)
        fi
        VELOCITY=$(( RNG%33 + 64 )); VELOCITY=$(printf "%02x" $VELOCITY) # Setting velocity between 64 and 96
        
        # Setting offset from root note with default values if applicable
        IDX=7
        OFFSET=0
        if [[ ! "$I" -eq 0 ]]; then
            IDX=$((RNG%SIZEOFKEY))
            [[ "$MAJMIN" -eq 1 ]] && OFFSET="${MINKEYS[$IDX]}" || OFFSET="${MAJKEYS[$IDX]}"
        fi
        ROOT1=$((ROOT+OFFSET)); ROOT1=$(printf "%02x" $ROOT1 )
        HT1=$((HT+OFFSET)); HT1=$(printf "%02x" $HT1 )
        printf "\x00\x90\x${ROOT1}\x${VELOCITY}\x00\x90\x${HT1}\x${VELOCITY}" >> $ANTIFILE
        printf "$NOTESIZE\x00\x80\x${ROOT1}\x00\x00\x80\x${HT1}\x00" >> $ANTIFILE
        if [[ "$NOTERNG" -gt 5 ]]; then # Semibreve case requires second note per beat
            IDX2=$((RANDOM%5+IDX-2))
            [[ "$MAJMIN" -eq 1 ]] && OFFSET2="${MINKEYS[$IDX2]}" || OFFSET2="${MAJKEYS[$IDX2]}"
            [[ "$IDX2" -lt 0 ]] && IDX2=0 # If second note is too low
            [[ "$IDX2" -ge "$SIZEOFKEYS" ]] && IDX2=$((SIZEOFKEYS-1)) # If second note is too high
            ROOT2=$((ROOT+OFFSET2)); ROOT2=$(printf "%02x" $ROOT2 )
            HT2=$((HT+OFFSET2)); HT2=$(printf "%02x" $HT2 )
            printf "\x00\x90\x${ROOT2}\x${VELOCITY}\x00\x90\x${HT2}\x${VELOCITY}" >> $ANTIFILE
            printf "$NOTESIZE\x00\x80\x${ROOT2}\x00\x00\x80\x${HT2}\x00" >> $ANTIFILE
        fi
        [[ "$NOTERNG" -eq 5 ]] && ((I+=2)) || ((I++))
    done
    # End ANTIFILE response
    # Now, create call sections with responses in between:
    I=0
    ROOT1=$(printf "%02x" $ROOT)
    while [[ "$I" -lt "$BEATS" ]]; do
        RNG=$(echo $RANDOM) # First call to RANDOM determines size of call
        
        CALLSIZE=$(( ((RNG%3)*2)+6 )) # 6, 8, or 10 (the 2-beat long at the end is not factored in here)
        J=0
        while [[ "$J" -lt "$CALLSIZE" ]]; do
            RNG=$(echo $RANDOM) # Second call to RANDOM for randomizing velocity, note size and note placement
            NOTERNG=$(( RNG%7 )) # 2/7 odds of semibreve, 4/7 odds of breve, 1/7 odds of long
            if [[ "$NOTERNG" -lt 4 || ("$I" -eq "$((BEATS-1))" || "$I" -eq 0) ]]; then # Breve (forced for first and last note)
                NOTESIZE=$(printf "\xf8") # Actual number of ticks = (248 - 128) * 128
            else 
                [[ "$NOTERNG" -eq 4 ]] && NOTESIZE=$(printf "\x81\xf0") || NOTESIZE=$(printf "\xbc") # Long (equals 4) or semibreve (greater than 4)
            fi
            VELOCITY=$(( RNG%33 + 64 )); VELOCITY=$(printf "%02x" $VELOCITY) # Setting velocity between 64 and 96
            printf "\x00\x90\x${ROOT1}\x${VELOCITY}" >> $NOTEFILE
            printf "$NOTESIZE\x00\x80\x${ROOT1}\x00" >> $NOTEFILE
            [[ "$NOTERNG" -eq 4 ]] && ((J+=2)) || ((J++))
        done

        # Last long of call section is a different note from ROOT
        RNG=$(( (RANDOM%5)+1 )); [[ "$RNG" -ge 3 ]] && ((RNG-=5)) | ((RNG+=1));
        IDX2=$((RNG+7)) # Note stays within 3 steps of ROOT (index 7) but is never ROOT
        [[ "$MAJMIN" -eq 1 ]] && OFFSET2="${MINKEYS[$IDX2]}" || OFFSET2="${MAJKEYS[$IDX2]}"
        ROOT2=$((ROOT+OFFSET2)); ROOT2=$(printf "%02x" $ROOT2 )
        printf "\x00\x90\x${ROOT2}\x${VELOCITY}" >> $NOTEFILE
        printf "\x81\xf0\x00\x80\x${ROOT2}\x00" >> $NOTEFILE

        cat $ANTIFILE >> $NOTEFILE; ((I+=9)) # Adding in the reponse section after each call + the 1-beat pause below
        printf "\x81\xf0" >> $NOTEFILE # Ensure long pause after response section
        ((I+=CALLSIZE+1)) # Accounting for call's size in beat measurement
    done
fi
printf "\xbc\x00\xff\x2f\x00" >> $NOTEFILE

## Back to OUTPUTFILE; Starting with calculating tracksize
TRACKSIZE=$(cat $NOTEFILE | wc -c)
((TRACKSIZE+=24)) # Accounting for Metadata
TRACKSIZE1=$(printf "%08x" $TRACKSIZE)
printf "\x${TRACKSIZE1:0:2}\x${TRACKSIZE1:2:2}\x${TRACKSIZE1:4:2}\x${TRACKSIZE1:6:2}" >> $OUTPUTFILE

## Track Metadata (24 Extra Bytes Not Included In NOTEFILE)
# Tempo
printf "\x00\xff\x51\x03" >> $OUTPUTFILE
TEMPO1=$(printf "%06x" $TEMPO)
printf "\x${TEMPO1:0:2}\x${TEMPO1:2:2}\x${TEMPO1:4:2}" >> $OUTPUTFILE
# Time Sig (always 4:4)
printf "\x00\xff\x58\x04\x04\x02\x18\x08" >> $OUTPUTFILE
# Key Sig
printf "\x00\xff\x59\x02" >> $OUTPUTFILE
if [[ "$KEYSIG" -lt 0 ]]; then
    KEYSIG2=$((128+KEYSIG))
    KEYSIG1=$(printf "%02x" $KEYSIG2)
else
    KEYSIG1=$(printf "%02x" $KEYSIG)
fi
MAJMIN1=$(printf "%02x" $MAJMIN)
printf "\x${KEYSIG1}\x${MAJMIN1}" >> $OUTPUTFILE
# Instrument
INSTRUMENT1=$(printf "%02x" $INSTRUMENT)
printf "\x00\xc0\x${INSTRUMENT1}" >> $OUTPUTFILE

# MIDI Track (Notes)
cat $NOTEFILE >> $OUTPUTFILE

# The temporary files are temporary, after all :)
[[ -f $NOTEFILE ]] && rm $NOTEFILE
[[ -f $ANTIFILE ]] && rm $ANTIFILE

echo "--------------------------------------------------------------------------------"
printf "\a"
printf "${GREEN}Done!${NONE}\nTry opening${NYELLOW} $OUTPUTFILE ${NONE}in your favorite MIDI editor.\n"
[[ "$(printf $OUTPUTFILE | tail -c 4)" != ".mid" && "$(printf $OUTPUTFILE | tail -c 5)" != ".midi" ]] && printf "${PINK}Make sure to give it a proper MIDI file extension beforehand!${NONE}\n"

# Opens file in VS Code for developer purposes (remove # symbols)
#co#de $OUTPUTFILE