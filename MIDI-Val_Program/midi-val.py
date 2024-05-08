# ---------------------------------------------------------------------
# MIDI-Val - CSU Chico Capstone Project By Max Stickels
# Advisor: Professor Todd Gibson
# Automatically generate medieval files in the style of medieval music!
# Run this program with "-h" as the first argument to learn how!
#----------------------------------------------------------------------

import os # for deletion of temporary files
import sys # for command line arguments
import random # for RNG

# Iterators
i=0
j=0

# Essential files (must be available to read/write/append/create/delete)
NOTEFILE="x.midival" # File to store note data (temporary, will always be overwritten by program)
ANTIFILE="a.midival" # File to store antiphonal response data (also temporary)

# Make any existing file at the temp locations empty
notefile = open(NOTEFILE, 'wb+')
antifile = open(ANTIFILE, 'wb+') 
notefile.write(b"")
antifile.write(b"")
notefile.close()
antifile.close()

# Now we are appending
notefile = open(NOTEFILE, 'ab+')
antifile = open(ANTIFILE, 'ab+') 

# Print help if help flag is passed as an argument
for arg in sys.argv:
	if ( arg == "-h" or arg == "--help" ): 
		print("\nUSAGE: bash midi-val.sh [ -h | -i <INSTRUMENT_NUMBER> | -k <KEY_SIGNATURE> | -o <OUTPUT_FILE> | -l <LENGTH> | -p <PITCH> | -s <STYLE> | -t <TEMPO> ]\n")
		print("-h OR --help                                                                     Prints this page and exits\n")
		print("-i OR --instrument <INSTRUMENT_NUMBER>                                           Select instrument")
		print("    Default: 19 (Church Organ)")
		print("    Range: 0 to 127")
		print("    Examples: -i 0 = Acoustic Grand Piano, -i 3 = Honky Tonk Piano\n")
		print("-k OR --key OR --keysig <KEY_SIGNATURE>                                          Select key signature")
		print("    Default: CM (C Major)")
		print("    Examples: -k D#m = D Sharp Minor, -k GbM = G Flat Major, -k Bm = B Minor")
		print("    Note: # = Sharp, b = Flat, m = Minor, M = Major\n")
		print("-l OR -<=ngth <LENGTH>                                                          Set song length (beats)")
		print("    Default: 16 beats; 32 if antiphonal style is chosen")
		print("    Examples: -l 20 = Output file will last for 20 beats (1 beat = 1 half note)")
		print("    Note: Length may be greater than requested for antiphonal style MIDIs\n")
		print("-o OR --output <OUTPUT_FILE>                                                     Select output destination")
		print("    Default: output.mid")
		print("    Example: -o 1234.mid = Saves output to file 1234.mid\n")
		print("-p OR --pitch <PITCH>                                                            Add pitch shift")
		print("    Default: 50 (equal to default system tuning)")
		print("    Range: 0 to 100 (translated to -50 to 50 cents; tuning may vary by system)")
		print("    Example: -p 10 = Music will be about 40 cents flat\n")
		print("-s OR --style <STYLE>                                                            Select output style")
		print("    Default: Monophonic Chant")
		print("    Options: -s 0 = Monophonic Chant, -s 1 = Strict Homophonic Chant, -s 2 = Antiphonal (responsorial)\n")
		print("-t OR --tempo <TEMPO>                                                            Set song tempo (beats per minute)")
		print("    Default: 120BPM")
		print("    Range: 40BPM and above")
		print("    Example: -t 108 = 108BPM")
		sys.exit()

outputfilename="output.mid" # File for output
tracksize=0 # Variable for calculating track size (must match exactly)
tempo=500000 # Microseconds per beat (default = 120 BPM, 500000 us per beat)
argtempo=120 # Tempo in BPM (provided as argument)
instrument=19 # Default to (usually) church organ 
style=0 
STYLES=["Monophonic", "Strict Homophonic", "Antiphonal"]
pitch=50 # Changed to 0-100 if pitch modulation is supplied
keysig=0 # Number of flats / sharps (max of 7)
keynum=7 # Position of key signature in KEYSIGS array
majmin=0 # 0 if major key, 1 if minor key
MAJKEYS=[-12, -10, -8, -7, -5, -3, -1, 0, 2, 4, 5, 7, 9, 11] # Distance from root note
MINKEYS=[-12, -10, -9, -7, -5, -4, -2, 0, 2, 3, 5, 7, 8, 10] 
SIZEOFKEY=len(MAJKEYS)
# Each root note is a fifth above the previous (even between C#M and Abm!), so root for any key = value of B4 + (7 * I % 12)
KEYSIGS=["CbM", "GbM", "DbM", "AbM", "EbM", "BbM", "FM", "CM", "GM", "DM", "AM", "EM", "BM", "F#M", "C#M", "Abm", "Ebm", "Bbm", "Fm", "Cm", "Gm", "Dm", "Am", "Em", "Bm", "F#m", "C#m", "G#m", "D#m", "A#m"]
# Full keysig names for key signature output
FULLKEYSIGS=["C Flat Major", "G Flat Major", "D Flat Major", "A Flat Major", "E Flat Major", "B Flat Major", "F Major", "C Major", "G Major", "D Major", "A Major", "E Major", "B Major", "F Sharp Major", "C Sharp Major", "A Flat Minor", "E Flat Minor", "B Flat Minor", "F Minor", "C Minor", "G Minor", "D Minor", "A Minor", "E Minor", "B Minor", "F Sharp Minor", "C Sharp Minor", "G Sharp Minor", "D Sharp Minor", "A Sharp Minor"]
beats=16 # Number of beats (passed in as length argument)
beatsflag=0 # If beats is unspecified in antiphonal style, default needs to change to 32

print("--------------------------------------------------------------------------------")
print("        MIDI-Val: Automatically Generate Medieval-Era Music Files!")

# Argument-free attribute entry system
if (len(sys.argv) > 1):
    print("          Run with \"-h\" or \"--help\" flags for usage information,\n           or run without flags to enter each setting manually.")
    print("--------------------------------------------------------------------------------")
    print("Command line arguments used! Any errors/warnings will appear here.")
    print("(MIDI-Val will try to continue with defaults if any arguments are invalid.)\n")
else:
    valid=0
    print("       This program supports quick and easy command-line arguments!\n           Run it with the \"-h\" or \"--help\" flag to learn more.")
    print("--------------------------------------------------------------------------------")
    print("For each of the following prompts, type in an accepted value, then press ENTER.\nYou may also simply press ENTER to use the default setting.\nSimply type \"exit\" (with no quotes) into a prompt to exit.")
    # Style
    while valid == 0:
        arg = input("\nSelect a style! [DEFAULT = 0]\n(0 = Monophonic, 1 = Strict Homophonic, 2 = Antiphonal): ")
        if ( arg.lower() == "exit" ):
            print("Exiting now. Come back again soon!") 
            sys.exit()
        if ( arg == "" ):
            print("Prompt skipped - using default value.")
            valid=1
        else:
            if (not (arg == "0" or arg == "1" or arg == "2")):
                print(f"Invalid style number \"{arg}\". Please choose an integer value from 0 to 2 inclusive.")
            else:
                style=int(arg)
                valid=1
    valid=0
    # Tempo
    while valid == 0:
        arg = input("\nSelect a tempo in BPM (beats per minute))! [DEFAULT = 120]: ")
        if ( arg.lower() == "exit" ):
            print("Exiting now. Come back again soon!") 
            sys.exit()
        if ( arg == "" ):
            print("Prompt skipped - using default value.")
            valid=1
        else:
            if not ( arg.isdigit() and int(arg) >= 40):
                print(f"Invalid tempo \"{arg}\". Please choose an integer value of 40 or greater.")
            else: 
                tempo=int(60000000 / int(arg))
                argtempo=int(arg)
                if tempo == 0:
                    tempo=1
                valid=1
    valid=0
    # Length (Beats)
    while valid == 0:
        arg = input("\nHow long should the song be (total number of beats)? [DEFAULT = 16]\n(The default is *at least* 32 beats for antiphonal songs): ")
        if ( arg.lower() == "exit" ):
            print("Exiting now. Come back again soon!") 
            sys.exit()
        if ( arg == "" ):
            print("Prompt skipped - using default value.")
            valid=1
        else:
            if not ( arg.isdigit() and int(arg) > 0 ):
                    print(f"Invalid song length \"{arg}\". Please choose an integer value greater than 0.")
            else: 
                beats=int(arg)
                beatsflag += 1
                valid=1
    valid=0
    # Key signature
    while valid == 0:
        arg = input("\nSelect a key signature! [DEFAULT = CM = C Major]\n(Or type list to see all accepted options): ")
        if ( arg.lower() == "exit" ):
            print("Exiting now. Come back again soon!") 
            sys.exit()
        if ( arg == "" ):
            print("Prompt skipped - using default value.")
            valid=1
        else:
            # "list" case; no error but still not valid to continue here, i.e it should loop again
            if ( arg.lower() == "list" ):
                print("All options (case sensitive)): CbM, GbM, DbM, AbM, EbM, BbM, FM, CM, GM, DM, AM, EM, BM, F#M,\nC#M, Abm, Ebm, Bbm, Fm, Cm, Gm, Dm, Am, Em, Bm, F#m, C#m, G#m, D#m, A#m")
                print("Note: # = Sharp, b = Flat, m = Minor, M = Major. For exmaple, Ebm is shorthand for \"E Flat Minor\".")
            else: # checking for actual valid key sig
                i=0
                found=0
                j=len(KEYSIGS) / 2 # Setting J equal to half of KEYSIGS list size; splits list between major and minor sigs
                while ( i < len(KEYSIGS) ):
                    if ( arg == KEYSIGS[i] ):
                        keynum=i # Store index in keynum
                        keysig=int(((i % j) - 7)) # K=I*J-7 should represent the number of sharps/flats based on position in KEYSIGS array
                        if ( i < j ): # First half of list is major, second half minor
                            majmin=0
                        else:
                            majmin=1
                        found = 1
                        break
                    i += 1
                if found == 0:
                    print(f"Invalid key signature \"{arg}\".\nTry typing list to see all accepted options!")
                else:
                    valid=1
    valid=0
    # Instrument
    while valid == 0:
        arg = input("\nWhich MIDI instrument should the song use? [DEFAULT = 19 (Church Organ)]\n(A number from 0-127. For a full list of General MIDI instrument codes,\nsee https://www.cs.cmu.edu/~music/cmsip/readings/GMSpecs_Patches.htm): ")
        if ( arg.lower() == "exit" ):
            print("Exiting now. Come back again soon!") 
            sys.exit()
        if ( arg == "" ):
            print("Prompt skipped - using default value.")
            valid=1
        else:
            if not ( arg.isdigit() and int(arg) <= 127 ):
                print(f"Invalid instrument number \"{arg}\". Please choose an integer value from 0 to 127 inclusive.")
            else: 
                instrument=int(arg)
                valid=1
    valid=0
    # Pitch Shift
    while valid == 0:
        arg = input("\nWould you like to detune the music? [DEFAULT = 50 (No detuning)]\n(Range from 0 to 100. 0 = 50 cents flat, 100 = 50 cents sharp): ")
        if ( arg.lower() == "exit" ):
            print("Exiting now. Come back again soon!") 
            sys.exit()
        if ( arg == "" ):
            print("Prompt skipped - using default value.")
            valid=1
        else:
            if not ( arg.isdigit() and int(arg) <= 100 ):
                print(f"Invalid detuning value \"{arg}\". Please choose an integer value from 0 to 100 inclusive.")
            else: 
                pitch=int(arg)
                valid=1
    valid=0
        # Output file name
    while valid == 0:
        arg = input("\nLastly, would you like to name the song file? [DEFAULT = output.mid]\n(Include a valid MIDI file extension such as .mid or .midi): ")
        if ( arg.lower() == "exit" ):
            print("Exiting now. Come back again soon!") 
            sys.exit()
        if ( arg == "" ):
            print("Prompt skipped - using default file name.")
            valid += 1
        else:
            if ( arg[-4:] != ".mid" and arg[-5:] != ".midi" ): 
                nothing = input(f"Warning: file {arg} does not have a proper MIDI file extension.\nPress ENTER to continue anyways, or type exit then press ENTER to exit: ")
                if nothing.lower == "exit":
                    sys.exit()
            if ( os.path.isfile(arg) ):
                nothing = input(f"File {arg} already exists and will be overwritten.\nMake sure the file is not open in any other application.\nPress ENTER to override the file or type exit + press ENTER to exit.")
                if (nothing.lower == "exit"):
                    sys.exit()
                os.remove(arg) 
            outputfile = open(arg, 'wb+')
            outputfile.write(b"")
            if not ( os.path.isfile(arg) ):
                print(f"Failed to create file \"{arg}\". Please try a different file name.")
            else:
                outputfilename=arg
                outputfile.close()
                valid=1
    valid=0


## Processing command line arguments iteratively
if (len(sys.argv) > 1):
    flag=""
    for arg in sys.argv:
        if ( flag == "-o" or flag == "--output" ):
            if ( arg[-4:] != ".mid" and arg[-5:] != ".midi" ): 
                nothing = input(f"Warning: file {arg} does not have a proper MIDI file extension.\nPress ENTER to continue anyways, or type exit then press ENTER to exit: ")
                if nothing.lower == "exit":
                    sys.exit()
            if ( os.path.isfile(arg) ):
                nothing = input(f"File {arg} already exists and will be overwritten.\nMake sure the file is not open in any other application.\nPress ENTER to override the file or type exit + press ENTER to exit.")
                if (nothing.lower == "exit"):
                    sys.exit()
                os.remove(arg) 
            outputfile = open(arg, 'ab+')
            outputfile.write(b"")
            if not ( os.path.isfile(arg) ):
                print(f"Failed to create file \"{arg}\". Please try a different file name.")
            else:
                outputfilename=arg
                outputfile.close()
        if ( flag == "-t" or flag == "--tempo" ):
            if not ( arg.isdigit() and int(arg) >= 40):
                print(f"Invalid tempo \"{arg}\". Please choose an integer value of 40 or greater.")
            else: 
                tempo=int(60000000 / int(arg))
                argtempo=arg
                if tempo == 0:
                    tempo=1
        if ( flag == "-i" or flag == "--instrument" ):
            if not ( arg.isdigit() and int(arg) <= 127 ):
                print(f"Invalid instrument number \"{arg}\". Please choose an integer value from 0 to 127 inclusive.")
            else: 
                instrument=int(arg)
                valid=1
        if ( flag == "-s" or flag == "--style" ):
            if (not (arg == "0" or arg == "1" or arg == "2")):
                print(f"Invalid style number \"{arg}\". Please choose an integer value from 0 to 2 inclusive.")
            else:
                style=int(arg)
        if ( flag == "-l" or flag == "-length" ):
            if not ( arg.isdigit() and int(arg) > 0 ):
                    print(f"Invalid song length \"{arg}\". Please choose an integer value greater than 0.")
            else: 
                beats=int(arg)
                beatsflag += 1
        if ( flag == "-p" or flag == "--pitch" ):
            if not ( arg.isdigit() and int(arg) <= 100 ):
                print(f"Invalid detuning value \"{arg}\". Please choose an integer value from 0 to 100 inclusive.")
            else: 
                pitch=int(arg)
        if ( flag == "-k" or (flag == "--key" or flag == "--keysig") ):
            i=0
            found=0
            j=len(KEYSIGS) / 2 # Setting J equal to half of KEYSIGS list size; splits list between major and minor sigs
            while ( i < len(KEYSIGS) ):
                if ( arg == KEYSIGS[i] ):
                    keynum=i # Store index in keynum
                    keysig=int((i % j) - 7) # K=I*J-7 should represent the number of sharps/flats based on position in KEYSIGS array
                    if ( i < j ): # First half of list is major, second half minor
                        majmin=0
                    else:
                        majmin=1
                    found = 1
                    break
                i += 1
            if found == 0:
                print(f"Invalid key signature \"{arg}\".\nTry typing list to see all accepted options!")
        flag=arg

#print(f"{outputfilename}")
# Modifying default length for antiphonal style
if ( style == 2 and beatsflag == 0 ):
    beats=32

## Output File Heading
if ( os.path.isfile(outputfilename) ):
    os.remove(outputfilename) 
outputfile = open(outputfilename, 'ab+')
outputfile.write(b"")
if not ( os.path.isfile(outputfilename) ):
    print(f"Output file location {outputfilename} cannot be written to. Exiting now.")
    sys.exit()
#outputfile = open(outputfilename, 'ab+')

print("--------------------------------------------------------------------------------")
# Print File Settings To User
print(f"Now creating file \"{outputfilename}\" with these settings:\n")
stylename=STYLES[style]
print(f"* Style: {stylename} Chant")
if ( style < 2 ):
    print(f"* Song Length: {beats} beats")
else:
    print(f"* Song Length: At least {beats} beats")
print(f"* Key Signature: {KEYSIGS[keynum]} ({FULLKEYSIGS[keynum]})")
print(f"* Tempo: {argtempo}BPM")
print(f"* Instrument: {instrument}")
print(f"* Pitch Shift: {pitch - 50} cents")

# MIDI File Header -- Single Track, 15360 Ticks Per Beat (Should Be Kept The Same)
outputfile.write(b"\x4d\x54\x68\x64\x00\x00\x00\x06\x00\x00\x00\x01\x3c\x00")

# First MIDI Track Header Track Size, Tempo, Time Sig, Key Sig
outputfile.write(b"\x4d\x54\x72\x6b")

## Creating NOTEFILE
#echo -n "" > $NOTEFILE # Creates empty file with no newline
# Pitch Wheel Event
if ( pitch != 50 ):
    pitch-=50
    CENTER=8192 #0x2000 is no shift; 14-bit number with highest bit of each byte as 0, so it becomes 0x4000
    NEWPITCH=CENTER+(pitch*41) # 41 is approximately 4096 over 100
    np1=int(NEWPITCH/128).to_bytes(1) # Top 7 Bits
    np2=int(NEWPITCH%128).to_bytes(1) # Bottom 7 Bits
    notefile.write(b"\x00\xe0" + np2 + np1)

# Style-Dependent Note Creation
if ( style <= 1 ): # MONOPHONIC AND STRICT HOMOPHONIC CHANT CASES
    root= 59 + (7 * keynum) % 12 # value of root note for the given key (based on keynum)
    rng=random.randint(0, sys.maxsize - 1) # First call to RANDOM determines interval if necessary
    if ( rng%2 == 0 ):
        ht=root+5
    else:
        ht=root+7
    i=0
    while ( i < beats+1 ):
        rng=random.randint(0, sys.maxsize - 1) # Second call to RANDOM for randomizing velocity, note size and note placement
        noterng=rng%7 # 2/7 odds of semibreve, 4/7 odds of breve, 1/7 odds of long
        if ( noterng < 4 or (i == beats-1 or i == 0) ): # Breve (forced for first and last note)
            notesize=b"\xf8" # Actual number of ticks = (248 - 128)) * 128
        else: 
            if ( noterng == 4 ):
                notesize=b"\x81\xf0"
            else:
                notesize=b"\xbc" # Long (equals 4) or semibreve (greater than 4))
        velocity=( rng%33 + 48 ).to_bytes(1) # Setting velocity between 48 and 80
        
        # Setting offset from root note with default values if applicable
        idx=7
        offset=0
        if not ( i == 0 ):
            idx=rng%SIZEOFKEY
            if ( majmin == 1 ):
                offset=MINKEYS[idx]
            else:
                offset=MAJKEYS[idx]
        root1=(root+offset).to_bytes(1)
        ht1=(ht+offset).to_bytes(1)
        notefile.write(b"\x00\x90" + root1 + velocity)
        if ( style == 1 ):
            notefile.write(b"\x00\x90" + ht1 + velocity)
        notefile.write(notesize + b"\x00\x80" + root1 + b"\x00")
        if ( style == 1 ):
            notefile.write(b"\x00\x80" + ht1 + b"\x00")
        if ( noterng > 4 ): # Semibreve case has two notes
            idx2=rng%5+idx-2
            if ( idx2 < 0 ):
                idx2=0 # If second note is too low
            if ( idx2 >= SIZEOFKEY ):
                idx2=SIZEOFKEY-1 # If second note is too high
            if ( majmin == 1 ):
                offset2=MINKEYS[idx2]
            else:
                offset2=MAJKEYS[idx2]
            root2=(root+offset2).to_bytes(1)
            ht2=(ht+offset2).to_bytes(1)
            notefile.write(b"\x00\x90" + root2 + velocity)
            if ( style == 1 ):
                notefile.write(b"\x00\x90" + ht2 + velocity)
            notefile.write(notesize + b"\x00\x80" + root2 + b"\x00")
            if ( style == 1 ):
                notefile.write(b"\x00\x80" + ht2 + b"\x00")
        if ( noterng == 4 ):
            i+=2 # Long case is 2 beats
        else:
            i += 1 
else: # ANTIPHONAL CASE
    root=59 + (7 * keynum) % 12 # value of root note for the given key (based on keynum)
    rng=random.randint(0, sys.maxsize - 1) # First call to RANDOM determines interval
    if ( rng%2 == 0 ):
        ht=root+5
    else:
        ht=root+7
    i=0
    # Setting up 8-beat response in ANTIFILE
    while ( i < 8 ):
        rng=random.randint(0, sys.maxsize - 1) # Second call to RANDOM for randomizing velocity, note size and note placement
        noterng=rng%7 # 1/7 odds of semibreve, 5/7 odds of breve, 1/7 odds of long
        if ( noterng < 5 or (i == beats-1 or i == 0) ): # Breve (forced for first and last note)
            notesize=b"\xf8" # Actual number of ticks = (248 - 128)) * 128
        else: 
            if ( noterng == 5 ):
                notesize=b"\x81\xf0"
            else:
                notesize=b"\xbc" # Long (equals 4) or semibreve (greater than 4))
        velocity=(rng%33 + 64).to_bytes(1) # Setting velocity between 64 and 96
        
        # Setting offset from root note with default values if applicable
        idx=7
        offset=0
        if not ( i == 0 ):
            idx=rng%SIZEOFKEY
            if ( majmin == 1 ):
                offset=MINKEYS[idx]
            else:
                offset=MAJKEYS[idx]
        root1=(root+offset).to_bytes(1)
        ht1=(ht+offset).to_bytes(1)
        antifile.write(b"\x00\x90" + root1 + velocity + b"\x00\x90" + ht1 + velocity)
        antifile.write(notesize + b"\x00\x80" + root1 + b"\x00\x00\x80" + ht1 + b"\x00")
        if ( noterng > 5 ): # Semibreve case requires second note per beat
            idx2=rng%5+idx-2
            if ( idx2 < 0 ):
                idx2=0 # If second note is too low
            if ( idx2 >= SIZEOFKEY ):
                idx2=SIZEOFKEY-1 # If second note is too high
            if ( majmin == 1 ):
                offset2=MINKEYS[idx2]
            else:
                offset2=MAJKEYS[idx2]
            root2=(root+offset2).to_bytes(1)
            ht2=(ht+offset2).to_bytes(1)
            antifile.write(b"\x00\x90" + root2 + velocity + b"\x00\x90" + ht2 + velocity)
            antifile.write(notesize + b"\x00\x80" + root2 + b"\x00\x00\x80" + ht2 + b"\x00")
        if ( noterng == 5 ):
            i+=2
        else:
            i+=1

    # End ANTIFILE response
    # Now, create call sections with responses in between:
    i=0
    root1=root.to_bytes(1)
    while ( i < beats ):
        rng=random.randint(0, sys.maxsize - 1) # First call to RANDOM determines size of call
        callsize=((rng%3)*2)+6 # 6, 8, or 10 (the 2-beat long at the end is not factored in here)
        j=0
        while ( j < callsize ):
            rng=random.randint(0, sys.maxsize - 1) # Second call to RANDOM for randomizing velocity, note size and note placement
            noterng=rng%7 # 2/7 odds of semibreve, 4/7 odds of breve, 1/7 odds of long
            if ( noterng < 4 or (i == beats-1 or i == 0) ): # Breve (forced for first and last note)
                notesize=b"\xf8" # Actual number of ticks = (248 - 128)) * 128
            else: 
                if ( noterng == 4 ):
                    notesize=b"\x81\xf0"
                else:
                    notesize=b"\xbc" # Long (equals 4) or semibreve (greater than 4))
            velocity=(rng%33 + 64).to_bytes(1) # Setting velocity between 64 and 96
            notefile.write(b"\x00\x90" + root1 + velocity)
            notefile.write(notesize + b"\x00\x80" + root1 + b"\x00")
            if ( noterng == 4 ):
                j+=2
            else:
                j+=1

        # Last long of call section is a different note from root
        rng=(random.randint(0, sys.maxsize - 1) % 5)+1 
        if ( rng >= 3 ):
            rng-=5
        else:
            rng+=1
        idx2=rng+7 # Note stays within 3 steps of root (index 7) but is never root
        if ( majmin == 1 ): 
            offset2=MINKEYS[idx2]
        else:
            offset2=MAJKEYS[idx2]
        root2=(root+offset2).to_bytes(1)
        notefile.write(b"\x00\x90" + root2 + velocity)
        notefile.write(b"\x81\xf0\x00\x80" + root2 + b"\x00")

        antifile.seek(0)
        notefile.write(antifile.read())
        #cat $ANTIFILE >> $NOTEFILE

        i+=9 # Adding in the reponse section after each call + the 1-beat pause below
        notefile.write(b"\x81\xf0") # Ensure long pause after response section
        i+=callsize+1 # Accounting for call's size in beat measurement

notefile.write(b"\xbc\x00\xff\x2f\x00")

## Back to OUTPUTFILE; Starting with calculating tracksize
notefile.seek(0, os.SEEK_END)
tracksize = notefile.tell()
#print(tracksize)
tracksize+=24 # Accounting for Metadata
tracksize1=tracksize.to_bytes(4)
outputfile.write(tracksize1)

## Track Metadata (24 Extra Bytes Not Included In NOTEFILE)
# Tempo
outputfile.write(b"\x00\xff\x51\x03")
tempo1=tempo.to_bytes(3)
outputfile.write(tempo1)
# Time Sig (always 4:4)
outputfile.write(b"\x00\xff\x58\x04\x04\x02\x18\x08")
# Key Sig
outputfile.write(b"\x00\xff\x59\x02")
if ( keysig < 0 ):
    keysig2=128+keysig
    keysig1=keysig2.to_bytes(1)
else:
    keysig1=keysig.to_bytes(1)
majmin1=majmin.to_bytes(1)
outputfile.write(keysig1 + majmin1)
# Instrument
outputfile.write(b"\x00\xc0" + instrument.to_bytes(1))

# MIDI Track (Notes)
notefile.seek(0)
outputfile.write(notefile.read())

notefile.close()
antifile.close()
outputfile.close()

# The temporary files are temporary, after all :)
if ( os.path.isfile(NOTEFILE) ):
    os.remove(NOTEFILE) 
if ( os.path.isfile(ANTIFILE) ):
    os.remove(ANTIFILE) 

print("--------------------------------------------------------------------------------")
print(f"Done!\nTry opening {outputfilename} in your favorite MIDI editor.")
if ( arg[-4:] != ".mid" and arg[-5:] != ".midi" ): 
    print("Make sure to give it a proper MIDI file extension beforehand!")