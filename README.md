# MIDI-Val
Automatically create your own Medieval-style MIDI files! This program was created entirely from scratch, and uses random number generation combined with the simple tonal/rythmic restrictions of early-Medieval chants to create completely original works. MIDI-Val is available as both a BASH script or Python 3 executable.

### Running the BASH Script (midi-val.sh)
To run the BASH version, ensure you have some form of bash installed on your device (for example, Git Bash generally comes as part of a broader [Git Installation](https://github.com/git-guides/install-git)). Download the MIDI-Val_Program/midi-val.sh file from this repository to a folder or directory where you have file read/write/delete permissions. Then simply open your BASH command line of choice, navigate to the location where midi-val.sh is stored, and run the command `bash midi-val.sh`. 

### Running the Python 3 Script (midi-val.py)
To run the Python version, ensure you have some form of Python installed on your device (see https://www.python.org/downloads/ for more information). Download the MIDI-Val_Program/midi-val.py file from this repository to a folder or directory where you have file read/write/delete permissions. Then simply open your command line of choice, navigate to the directory where midi-val.py is stored, and execute `midi-val.py` (how you do this varies depending on how you have install Python; for example, I use `winpty python3 midi-val.py` on my Windows device). 

### How to Use MIDI-Val
Both versions of the code were created with the goal of being functionally equivalent to each other. In fact, the one big difference you will see is that the BASH script prints colored text to the terminal while the Python version does not.

##### Default Behavior
If you run the program with no additional arguments as explained above, you will be prompted to enter the **style**, tempo (in beats per minute), song length (in beats), key signature, instrument number, pitch shift, and output file location, in that order. To answer each prompt, you can:
1. Simply press ENTER (This skips the prompt and uses the default value)
2. Type an valid value for the prompt and press ENTER (The value you enter will be used when creating the MIDI file)
3. Type `exit` and press ENTER (The program will exit immediately)
4. [*For the key signature prompt only*] Type `list` and press ENTER (This will print a list of all valid key signature options)

##### Help Page
If you run the program using the `-h` or `--help` argument at any point (i.e. `bash midi-val.sh -h`), the program will override any other command line arguments provided. Instead, it will print a help page explaining how to use command line arguments and exit. Information on each command line arguments is also provided below.

##### Running With Command Line Arguments
The command line arguments provided allow users to create a MIDI-Val MIDI file with only a single command, and they are equivalent between the BASH and Python 3 versions of the application. Including any of these arguments below will skip the prompting phase of the program, immediately creating a MIDI file with default values assumed in places that the command line arguments do not affect. The program will warn you if a command line argument has an invalid value, but will use default values as a fallback whenever possible. Each flag below (like `-i`) should be followed by exactly one other value (in place of `<INSTRUMENT_NUMBER>` insert some valid value like `33`). Otherwise, there is no requirement for ordering the arguments and you are free to use as many arguments as you like.

 * `-i OR --instrument <INSTRUMENT_NUMBER>`          Select instrument number
 * `-k OR --key OR --keysig <KEY_SIGNATURE>`          Select key signature
 * `-l OR --length <LENGTH>`          Set song length (beats)
 * `-o OR --output <OUTPUT_FILE>`          Select output destination
 * `-p OR --pitch <PITCH>`          Add pitch shift
 * `-s OR --style <STYLE>`          Select output style
 * `-t OR --tempo <TEMPO>`          Set song tempo (beats per minute)





