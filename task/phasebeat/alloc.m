%% alloc: function description
function [timings] = alloc(n,begin)
	if nargin < 2
		begin = 10000;
	end
	if nargin < 1
		n = 1000;
	end
	
	a = rand(1,begin);
	timings = [];
	for ii=1:n
		tic;
		a = [a rand];
		b = toc;
		timings = [timings b];
	end