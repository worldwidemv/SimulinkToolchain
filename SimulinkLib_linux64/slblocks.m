function blkStruct = slblocks
		% This function specifies that the library should appear
		% in the Library Browser
		% and be cached in the browser repository

		% the name of the library
		Browser.Library = 'xsrt_control_lib';

		% the library name that appears in the Library Browser
		Browser.Name = 'Soft-Realtime Simulink Toolbox - Available Blocks';

		blkStruct.Browser = Browser;
