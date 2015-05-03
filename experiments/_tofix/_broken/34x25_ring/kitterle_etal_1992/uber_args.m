function [args,freqs] = uber_args(varargin)
%

    [args,freqs] = kitterle_args('sigma',    [ 1.5  3.0  6.0  11.0  18.0 ], ...
                                'uberpath', {'/home/bcipolli/de/runs/h180_c15-all/10722305/' ...
                                             '/home/bcipolli/de/runs/h180_c15-all/10721622/' ...
                                             '/home/bcipolli/de/runs/h180_c15-all/10727469/' ...
                                             '/home/bcipolli/de/runs/h180_c15-all/10798383/' ...
                                             '/home/bcipolli/de/runs/h180_c15-all/10806430/' ...
                                             }, ...
                                 varargin{:} ...
                               );

% train to 0.001
%                                'uberpath', {'/home/bcipolli/de/runs/h180_c15-all/11605201/' ...
%                                             '/home/bcipolli/de/runs/h180_c15-all/11604518/' ...
%                                             '/home/bcipolli/de/runs/h180_c15-all/11610585/' ...
%                                             '/home/bcipolli/de/runs/h180_c15-all/11684229/' ...
%                                             '/home/bcipolli/de/runs/h180_c15-all/11685741/' ...
%                                             }, ...