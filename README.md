# Simulink Toolchain for Soft-Realtime

This repository holds the basic structure and, some utility scripts of the Soft-Realtime Toolbox for Simulink.  
This toolbox allows you to compile a Simulink diagram into a Linux executable which uses nano-sleep to ensure [better real-time behaviour](http://rtime.felk.cvut.cz/publications/public/ert_linux.pdf).

This is done by the external **ERT_Linux target** for the Simulink Embeded Coder, which can be found here:

* `git clone git://rtime.felk.cvut.cz/ert_linux.git` -> [https://rtime.felk.cvut.cz/gitweb/ert_linux.git](https://rtime.felk.cvut.cz/gitweb/ert_linux.git)
* [http://lintarget.sourceforge.net/](http://lintarget.sourceforge.net/)

ERT_linux and the actual Simulink blocks, which use the Soft-Realtime provided by ERT_Linux, are developed in separate Git repositories and included as Git submodules for convenience.

## Requirements

The current version requires a Linux 64 bit operating system (e.g. Ubuntu 16.04).
Besides Matlab and Simulink, the following toolboxes are required:  

* Simulink Coder
* Embedded Coder
* (MATLAB Coder)

This toolchain is tested with Matlab 2014b and Maltab 2016b but should run with other versions too.  

## Installation

You must use:

    git clone --recursive https://github.com/worldwidemv/SimulinkToolchain.git SRT_repo

Otherwise the submodules will not be included and must be manually added by you. But you can change "SRT_repo" of course ;-).

Inside the main directory is the install script `srt_InstallSRT.m`, which must be run with Matlab.
This script should generate a working setup with the new entry  
_Soft-Realtime Simulink Toolbox - Available Blocks_ in the Simulink library browser.

You will also have the new option `ert_linux.tlc` for the _System Target file_ under _Setup > Code Generation_.
Please have a look at the [documentation](https://github.com/worldwidemv/SimulinkToolchain/wiki) for a more detailed description.

## Usage / Documentation

The toolchain it self has very little end-user functionality. Only the function `srt_CreateLib([Cell_with_FolderNames])` is useful to end-user to rebuild the Simulink library, e.g. after updates.

The full documentation can be found in the [Wiki](https://github.com/worldwidemv/SimulinkToolchain/wiki).


## License

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.
A copy is provided in the the LICENSE file or can be at [http://www.gnu.org/licenses/](http://www.gnu.org/licenses/).

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
