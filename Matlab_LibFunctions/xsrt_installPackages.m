function [installPkgs]=xsrt_installPackages(packages)
%XSRT_INSTALLPACKAGES Installs packages depending on the installed system.
%   The parameter "packages" is a struct containing cell arrays of package
%   names. The field names are system identifiers returned by
%   xsrt_systemInfo. All matching packages are installed by the package
%   mananger of a given system. E.g. on Ubuntu 16.04, all packages
%   contained in either "linux", "ubuntu" or "ubuntu1604" are installed
%   using "apt-get".
%
%   Example usage (taken from Array library dependencies):
%   packages = struct();
%   packages.ubuntu = {'gsl-bin', 'libgsl0-dev', 'libblas-dev', 'libblas3'};
%   packages.ubuntu1404 = {'libgsl0ldbl'};
%   packages.ubuntu1604 = {'libgsl2'};
%   xsrt_installPackages(packages);

%   TU Berlin --- Fachgebiet Regelungssystem
%   Author: Markus Valtin
%   Copyright © 2017 Markus Valtin. All rights reserved.
%
%   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT 
%   NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
%   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
%   WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
%   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

    sys = xsrt_systemInfo();
    installPkgs = {};
    for identifier=sys
        if ~isfield(packages, identifier{:})
            continue;
        end
        installPkgs = union(installPkgs, packages.(identifier{:}));
    end
    installPkgsStr = sprintf('%s ', installPkgs{:});
    disp(['Installing packages: ' installPkgsStr]);
    
    if strcmp(sys{1}, 'linux') && strcmp(sys{2}, 'ubuntu')
        cmd = ['sudo apt-get install -yq ' installPkgsStr];
        disp(cmd)
        xsrt_runCommand(cmd);
    elseif strcmp(sys{1}, 'mac')
        cmd = ['sudo /opt/local/bin/port install ' installPkgsStr];
        disp(cmd)
        xsrt_runCommand(cmd);
    end
end

