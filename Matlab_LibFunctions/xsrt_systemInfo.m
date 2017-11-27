function [info] = xsrt_systemInfo()
%XSRT_SYSTEMINFO Determine installed operating system.
%   Returns a cell array in which the first entry is the operating system
%   (e.g. "linux" or "mac"). On linux, further entries specify distribution
%   and version. E.g. on Ubuntu 16.04, the following is returned:
%   {'linux', 'ubuntu', 'ubuntu1604'}

%   TU Berlin --- Fachgebiet Regelungssystem
%   Author: Markus Valtin
%   Copyright © 2017 Markus Valtin. All rights reserved.
%
%   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT 
%   NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
%   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
%   WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
%   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

    % cache the result to avoid unnecessary calls to lsb_release
    persistent info_cached
    if isempty(info_cached)
        if(strcmp(mexext(),'mexa64'))
            [~,lsbRelease] = system('lsb_release -sir');
            versionParts = strsplit(lsbRelease, '\n');
            assert(length(versionParts) == 3, 'cannot parse output from lsb_release');
            assert(strcmp(versionParts{3}, ''), 'cannot parse output from lsb_release');
            distribution = lower(versionParts{1});
            version = lower(versionParts{2});
            if strcmp(distribution, 'ubuntu')
                version = strrep(version, '.', '');
            end
            distributionIdentifier = matlab.lang.makeValidName(distribution);
            versionIdentifier = matlab.lang.makeValidName([distribution version]);
            info_cached = {'linux', distributionIdentifier, versionIdentifier};
        elseif(strcmp(mexext(),'mexmaci64'))
            info_cached = {'mac'};
        end
    end
    info = info_cached;
end

