function [train,test] = de_StimCreate(stimSet, taskType, opt)
%Input:
%  stimSet  : a string specifying which INPUT sets to train autoencoder on
%                de: (default) 10 "far", 5 "near", 5 "on" images
%
%  taskType : a string specifying which OUTPUT task to train on
%               categorical = compare on (1) to off (0)
%               coordinate = compare near (1) vs. far (0)
%
%  opt      : a vector of options; all listed will be applied
%
%OUTPUT: a data file with the following variables:
%
%  train.X    : matrix containing 20 vectors, each a unique hierarchical stimulus.
%  train.T    : target vectors for perceptron (labels, based on task)
%
%  test.*     : same as train object, but

    if (~exist('opt','var')),      opt      = {};     end;
    if (~iscell(opt)),             opt      = {opt};  end;

    switch(stimSet)
        case 'blob-dot'
            train = MakeBlobDot(taskType);

        case 'paired-squares'
            train = MakePairedSquares(taskType);

        case 'plus-minus'
            train = MakePlusMinus(taskType);

        otherwise
            error('Invalid stimulus type. Choose one from: {''blob-dot'', ''paired-squares'', ''plus-minus''}');
    end;


    % Now say that test data is the same as training data.
    test = train;


function train = MakeBlobDot(taskType)
    if ~any(ismember(taskType, {'categorical', 'coordinate'}))
        error('Unknown taskType: %s', taskType);
    end;

    % Create the input images.
    train.nInput = [68 50];
    train.X = zeros(prod(train.nInput), 0);
    train.XLAB = {}; % blob-dot has 20 stimuli: 10 far/off, 5 near/off, 5 near/on
    train.T = [];
    train.TLAB = {};
    heights = [];

    distances = [0, 4, 8, 12];
    ref_distance = 6;
    for bi=1:5  % 5 blob images have been coded.
        for d=distances
            img = blob_stimuli(d, 3, bi);
            train.X(:, end+1) = reshape(img, prod(train.nInput), 1);
            train.XLAB{end+1} = sprintf('%dpx from %d%c', d, (bi-1)* 72, char(176));
            heights(end+1) = d;

            difficulty = guru_iff(abs(d - ref_distance) > 2, 'easy', 'hard');

            switch (taskType)
                case 'categorical',
                    train.T(end+1) = d > 0;
                    lbl = guru_iff(train.T(end), 'off', 'on');
                    train.TLAB{end+1} = sprintf('%s-%s', lbl, difficulty);
                case 'coordinate',
                    train.T(end+1) = (d / distances(end)) < 0.5;
                    lbl = guru_iff(train.T(end), 'near', 'far');
                    train.TLAB{end+1} = sprintf('%s-%s', lbl, difficulty);
            end
        end;
    end


function train = MakePairedSquares(taskType)
%
    if ~strcmp(taskType, 'coordinate')
        error('Unknown taskType: %s. paired-squares only takes coordinate task type.', taskType);
    end;

    % first, set some variables
    distances = [2 3 4 5];

    train.nInput = [34 25];
    train.X = zeros(prod(train.nInput), 0);
    train.XLAB = {}; % paired squares has 16 stimuli: 4 distances left side x 4 distances right
    train.T = [];
    train.TLAB = {};

    top_distances = []; % to be used when assigning labels
    bottom_distances = [];

    % Create the 16 images
    for d1=distances % left side: distance b/n squares ranges [2, 5]
        for d2=distances % right side: distance b/n square ranges [2, 5]
            img = paired_squares_stimuli(d1, d2, 1);
            train.X(:, end+1) = reshape(img, prod(train.nInput), 1);
            train.XLAB{end+1} = sprintf('(Dist) Top: %dpx ; Bottom: %dpx', d1, d2);

            % Coordinate task
            train.T(end+1) = (d1 == d2); % same distance or no?
            difficulty = guru_iff(d1 == d2, 'easy', 'hard');  % according to the paper...
            lbl = guru_iff(train.T(end) == 1, 'same', 'different');
            train.TLAB{end+1} = sprintf('%s-%s', lbl, difficulty);
            
            %There are 12 "different" stimuli and 4 "same" stimuli. To make
            %class sizes the same, each "same" stimuli will be duplicated
            %twice (for a total of three copies).
            
            if d1 == d2
                nRepeat = 2; %how many times should this be repeated?
                for i=1:nRepeat
                    %Just copy over the information from before.
                    train.X(:, end+1) = train.X(:, end);
                    train.XLAB{end+1} = train.XLAB{end};

                    train.T(end+1) = train.T(end); % same distance or no?
                    train.TLAB{end+1} = train.TLAB{end};
                end
            end
        end
    end


function train = MakePlusMinus(taskType)
%

    if ~any(ismember(taskType, {'categorical', 'coordinate'}))
        error('Unknown taskType: %s', taskType);
    end;

    % Create the input images.
    train.nInput = [34 25];
    train.X = zeros(prod(train.nInput), 0);
    train.XLAB = {};
    train.T = [];
    train.TLAB = {};

    distances = [2 3 4 5 6 7 8 9];
    ref_distance = 5.5;
    sides = {'left', 'right'};
    for d=distances
        for plus_side=sides
            plus_side = plus_side{1};
            img = plus_minus_stimuli(d, plus_side);
            train.X(:, end+1) = reshape(img, prod(train.nInput), 1);
            train.XLAB{end+1} = sprintf('Plus on %s, %dpx apart', plus_side, d);

            % Create the output vectors.

            difficulty = guru_iff(abs(d - ref_distance) > 2, 'easy', 'hard');
            switch (taskType)
                case 'categorical'
                    train.T(end+1) = strcmp(plus_side, 'right') == 1;
                    train.TLAB{end+1} = sprintf('%s-%s', plus_side, difficulty);
                case 'coordinate',
                    train.T(end+1) = (d < ref_distance);
                    lbl = guru_iff(train.T(end), 'near', 'far');
                    train.TLAB{end+1} = sprintf('%s-%s', lbl, difficulty);
            end
        end;
    end;


function image = paired_squares_stimuli(top_distance, bottom_distance, four_pixel)
% Takes three parameters: 2 are distances from quartile lines
% Last parameter: if four_pixel = 1, then the square will be 4 pixels. For all other values it will be 1 pixel

    image_height = 34;
    image_width = 25;

    horizontal_midline = image_height/2;
    vertical_midline = ceil(image_width/2);

    top_quarterline = floor(image_height/4);
    bottom_quarterline = image_height - top_quarterline;

    image = ones(image_height, image_width);

    for ii = 2:image_width-1
        image(horizontal_midline, ii) = 0;
    end

    image(top_quarterline-top_distance+1, vertical_midline) = 0;
    image(top_quarterline+top_distance, vertical_midline) = 0;
    image(bottom_quarterline+bottom_distance, vertical_midline) = 0;
    image(bottom_quarterline-bottom_distance+1, vertical_midline) = 0;

    
    if four_pixel
        image(top_quarterline-top_distance, vertical_midline) = 0;
        image(top_quarterline+top_distance+1, vertical_midline) = 0;
        image(bottom_quarterline+bottom_distance+1, vertical_midline) = 0;
        image(bottom_quarterline-bottom_distance, vertical_midline) = 0;
        
        image(top_quarterline-top_distance, vertical_midline+1) = 0;
        image(top_quarterline+top_distance+1, vertical_midline+1) = 0;
        image(bottom_quarterline+bottom_distance+1, vertical_midline+1) = 0;
        image(bottom_quarterline-bottom_distance, vertical_midline+1) = 0;
        
      	image(top_quarterline-top_distance+1, vertical_midline+1) = 0;
        image(top_quarterline+top_distance, vertical_midline+1) = 0;
        image(bottom_quarterline+bottom_distance, vertical_midline+1) = 0;
        image(bottom_quarterline-bottom_distance+1, vertical_midline+1) = 0;
    end


function rot_image = blob_stimuli(distance, dot_size, orientation)

    %orientation is the follow values:
    % 1 = blob on left
    % 2 = blob rotated 72 degrees
    % 3 = blob rotated 144 degrees
    % 4 = blob rotated 216 degrees
    % 5 = blob rotated 288 degrees

    center_of_blob = [34, 15]; %hardcoded
    image_height = 68;
    image_width = 50;


    image = ones(image_height, image_width);
    rot_image = ones(image_height, image_width);

    center_y = center_of_blob(1);
    center_x = center_of_blob(2);


    image(center_y, center_x+6) = 0;
    image(center_y, center_x-6) = 0;
    image(center_y+10, center_x) = 0;
    image(center_y-10, center_x) = 0;
    image(center_y-11, center_x) = 0;
    image(center_y-12, center_x-1) = 0;
    image(center_y-13, center_x-2) = 0;
    image(center_y-13, center_x-3) = 0;
    image(center_y-12, center_x-4) = 0;
    image(center_y-11, center_x-5) = 0;
    image(center_y-10, center_x-5) = 0;
    image(center_y-9, center_x-5) = 0;
    image(center_y-8, center_x-5) = 0;
    image(center_y-7, center_x-4) = 0;
    image(center_y-6, center_x-4) = 0;
    image(center_y-5, center_x-4) = 0;
    image(center_y-4, center_x-5) = 0;
    image(center_y-3, center_x-5) = 0;
    image(center_y-3, center_x-6) = 0;
    image(center_y-2, center_x-6) = 0;
    image(center_y-1, center_x-6) = 0;
    image(center_y+1, center_x-6) = 0;
    image(center_y+2, center_x-7) = 0;
    image(center_y+3, center_x-7) = 0;
    image(center_y+4, center_x-7) = 0;
    image(center_y+5, center_x-8) = 0;
    image(center_y+6, center_x-8) = 0;
    image(center_y+7, center_x-8) = 0;
    image(center_y+8, center_x-7) = 0;
    image(center_y+9, center_x-6) = 0;
    image(center_y+10, center_x-5) = 0;
    image(center_y+9, center_x-4) = 0;
    image(center_y+8, center_x-4) =0;
    image(center_y+8, center_x-3) = 0;
    image(center_y+7, center_x-3) = 0;
    image(center_y+6, center_x-2) = 0;
    image(center_y+7, center_x-1) = 0;
    image(center_y+8, center_x-1) = 0;
    image(center_y+9, center_x) = 0;
    image(center_y+10, center_x+1) = 0;
    image(center_y+11, center_x+1) = 0;
    image(center_y+12, center_x+1) = 0;
    image(center_y+13, center_x+2) = 0;
    image(center_y+13, center_x+2) = 0;
    image(center_y+13, center_x+2) = 0;
    image(center_y+14, center_x+2) = 0;
    image(center_y+14, center_x+3) = 0;
    image(center_y+15, center_x+3) = 0;
    image(center_y+15, center_x+3) = 0;
    image(center_y+14, center_x+4) = 0;
    image(center_y+13, center_x+5) = 0;
    image(center_y+12, center_x+5) = 0;
    image(center_y+11, center_x+5) = 0;
    image(center_y+10, center_x+5) = 0;
    image(center_y+9, center_x+4) = 0;
    image(center_y+8, center_x+4) = 0;
    image(center_y+7, center_x+5) = 0;
    image(center_y+6, center_x+5) = 0;
    image(center_y+5, center_x+5) = 0;
    image(center_y+4, center_x+5) = 0;
    image(center_y+3, center_x+6) = 0;
    image(center_y+2, center_x+6) = 0;
    image(center_y+2, center_x+5) = 0;
    image(center_y+1, center_x+5) = 0;
    image(center_y-1, center_x+6) = 0;
    image(center_y-2, center_x+7) = 0;
    image(center_y-3, center_x+7) = 0;
    image(center_y-4, center_x+8) = 0;
    image(center_y-5, center_x+9) = 0;
    image(center_y-5, center_x+9) = 0;
    image(center_y-6, center_x+9) = 0;
    image(center_y-7, center_x+9) = 0;
    image(center_y-8, center_x+8) = 0;
    image(center_y-8, center_x+7) = 0;
    image(center_y-7, center_x+6) = 0;
    image(center_y-7, center_x+5) = 0;
    image(center_y-7, center_x+4) = 0;
    image(center_y-7, center_x+3) = 0;
    image(center_y-8, center_x+2) = 0;
    image(center_y-9, center_x+1) = 0;

    switch orientation
        case 1 % at the left
            rot_image = image;

            % Now make the "dot"
            if (mod(dot_size, 2) == 1)
                right_bound = floor(dot_size/2);
                left_bound = -1 * right_bound;
                for i=left_bound:right_bound
                    for j=left_bound:right_bound
                        rot_image(center_y+i+1, center_x + distance + 6 + j) = 0;
                    end
                end

            else
                right_bound = dot_size/2;
                left_bound = -1 *(dot_size-1);
                for i=left_bound:right_bound
                    for j=left_bound:right_bound
                        rot_image(center_y+i+1, center_x + distance + 6 + j) = 0;
                    end
                end
            end


        case 2 % 72 degrees
            image = image * -1 + 1; % invert for rotation
            rotated = imrotate(image, 72);
            rot_image(:, :) = rotated(2:69, 11:60);
            rot_image = rot_image * -1 + 1; % invert again


            % Now make the "dot"
            center_y = 40; %hard-coded
            center_x = 33;
            if (mod(dot_size, 2) == 1)
                right_bound = floor(dot_size/2);
                left_bound = -1 * right_bound;
                for i=left_bound:right_bound
                    for j=left_bound:right_bound
                        rot_image(center_y+i-distance, center_x+distance+j) = 0;
                    end
                end

            else
                right_bound = dot_size/2;
                left_bound = -1 *(dot_size-1);
                for i=left_bound:right_bound
                    for j=left_bound:right_bound
                        rot_image(center_y+i-distance, center_x+distance+j) = 0;
                    end
                end
            end


        case 3  % 144 degrees
            image = image * -1 + 1;
            rot_image = imrotate(image, 144);
            rot_image = rot_image(4:71, 15:64);
            rot_image = rot_image * -1 + 1;
            center_y = 42;
            center_x = 31; % hard coded

            if (mod(dot_size, 2) == 1)
                right_bound = floor(dot_size/2);
                left_bound = -1 * right_bound;
                for i=left_bound:right_bound
                    for j=left_bound:right_bound
                        rot_image(center_y+i-distance, center_x-distance+j) = 0;
                    end
                end

            else
                right_bound = dot_size/2;
                left_bound = -1 *(dot_size-1);
                for i=left_bound:right_bound
                    for j=left_bound:right_bound
                        rot_image(center_y+i-distance, center_x-distance+j) = 0;
                    end
                end
            end

        case 4 % 216 degrees
            image = image * -1 + 1;
            rotated = imrotate(image, 216);
            rot_image(:, :) = rotated(14:81, 20:69);
            rot_image = rot_image * -1 + 1;

            center_y = 27;
            center_x = 25;

            if (mod(dot_size, 2) == 1)
                right_bound = floor(dot_size/2);
                left_bound = -1 * right_bound;
                for i=left_bound:right_bound
                    for j=left_bound:right_bound
                        rot_image(center_y+i+distance, center_x-distance+j) = 0;
                    end
                end

            else
                right_bound = dot_size/2;
                left_bound = -1 *(dot_size-1);
                for i=left_bound:right_bound
                    for j=left_bound:right_bound
                        rot_image(center_y+i+distance, center_x-distance+j) = 0;
                    end
                end
            end



        case 5 %288 degrees
            image = image * -1 + 1;
            rotated = imrotate(image, 288);
            rotated = rotated * -1 + 1;
            rot_image = rotated(1:68, 20:69);
            center_y = 32;
            center_x = 17;
            if (mod(dot_size, 2) == 1)
                right_bound = floor(dot_size/2);
                left_bound = -1 * right_bound;
                for i=left_bound:right_bound
                    for j=left_bound:right_bound
                        rot_image(center_y+i+distance, center_x+j) = 0;
                    end
                end

            else
                right_bound = dot_size/2;
                left_bound = -1 *(dot_size-1);
                for i=left_bound:right_bound
                    for j=left_bound:right_bound
                        rot_image(center_y+i+distance, center_x+j) = 0;
                    end
                end
            end

        otherwise
            error('Invalid Orientation Number. Enter a number 1-5.');
    end


function image = plus_minus_stimuli(distance, plus_side)
% distance = distance of CENTER of plus, minus from midpoint
% distance = 0 means that the plus and minus are overlaid on top of each other
% valid distance ranges from [2, 11]

    image_height = 34;
    image_width = 25;

    image = ones(image_height, image_width);
    horiz_midline = (image_height)/2;
    center = ceil(image_width/2);

    for i = -1:1
        image(horiz_midline, center+distance+i) = 0;
        image(horiz_midline, center-distance-i) = 0;

        if strcmp(plus_side, 'right')
            image(horiz_midline+1, center+distance) = 0;
            image(horiz_midline-1, center+distance) = 0;
        else
            image(horiz_midline+1, center-distance) = 0;
            image(horiz_midline-1, center-distance) = 0;
        end
    end
