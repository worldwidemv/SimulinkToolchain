# TUB Matlab Toolchain -- StartScript

## Summary

The StartScript is a simple Bash script, which:

* starts simultaneously PaPI and the Simulink executable,
* creates log files for the Simulink executable and PaPI,
* loads a user configured PaPI configuration or a default PaPI configuration, which automatically connects to the Simulink executable and
* moves the *.mat files created by the Simulink executable to a data directory, preventing accidental overrides.

## Detailed Description

The StartScript is a simple Bash script, which can be copied to the directory were the Simulink diagram and executable resides, or it can be copied to `/usr/local/bin`.
Coping the script to you Simulink files directory allows you to configure the script to the specific needs of the diagram/experiment.
Coping or linking the script to `/usr/local/bin` allows you to start the Simulink executable in a more convenient way, with the added bonus of automatic log file creation and data override protection.

### Calling the Script and Parameters

The script asks you for _root_ privileges when needed, so you do not need to be called the script with @sudo@.
The script  can take two optional arguments, which default to:
`USAGE: startEXE.sh  EXECUTABLE_NAME  PREFIX  `, if both arguments are present.

If only one argument is present, the script will check if the argument is the `EXECUTABLE_NAME` by checking if a file like the argument exists. If no such file exists, the script assumes that the argument is the `PREFIX` argument.

### Prefix and File Names

The `PREFIX` is used to create an unique file name pattern for the log files and the data files.
This pattern locks like <pre>
$date_time"_"$simulink_exec_name"_"$PREFIX"_"$counter"__"XXX .
</pre>
The `$counter` variable is a number from 01 to 49, ensuring an unique file name pattern for subsequent trials, since the default `$date_time` variable contains only the current day.

### Example

<pre>
control@control-VB:~/Matlab_UsefulStuff/StartSkript/MinimalExample$ startEXE.sh MinimalExample TestPrefix

### Starting Simulink executable for './MinimalExample'.....

Create: PaPIBlock (Embedded Coder)

** starting the model **

### Simulink executable was terminated.

### Moving *.mat files ...
   ‘./EXP__Output.mat’ -> ‘data/2016.09.04_MinimalExample_TestPrefix_01__EXP__Output.mat’
   ‘./EXP__Input.mat’ -> ‘data/2016.09.04_MinimalExample_TestPrefix_01__EXP__Input.mat’

.... done

control@control-VB:~/Matlab_UsefulStuff/StartSkript/MinimalExample$ ls -1 *
MinimalExample
MinimalExample.slx
PaPI_MinimalExample.json
startEXE.sh
data:
   2016.09.04_MinimalExample_TestPrefix_01__EXP__Input.mat
   2016.09.04_MinimalExample_TestPrefix_01__EXP__Output.mat
logs:
   2016.09.04_MinimalExample_TestPrefix_01__PaPILog.log
   2016.09.04_MinimalExample_TestPrefix_01__SimulinkExecLog.log
</pre>

## Installation

* TODO
* link nach usr
* papi link

## Configuration 

* TODO