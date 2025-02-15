% Define the folder containing the label files
base_folder = '/Volumes/T7/AMPB/code/mpm/roi';

hemi = 'R'; 
area = 'PT'; 
folder_name = sprintf('MNI152NLin2009cAsym_%s_label-%s', hemi, area);
folder_path = fullfile(base_folder, folder_name);

% Get list of label files
label_files_struct = dir(fullfile(folder_path, '*.label'));
label_files = fullfile(folder_path, {label_files_struct.name});

% Exclude files starting with '._'
label_files = label_files(~startsWith({label_files_struct.name}, '._'));

for i = 1:length(label_files)
    current_file = label_files{i};
    
    % Calculate and display ROI size
    try
        roi_size = calculate_roi_size(current_file);
        [~, filename, ~] = fileparts(current_file);
        fprintf('File: %s, ROI size: %d vertices\n', filename, roi_size);
    catch ME
        warning('Failed to calculate ROI size for %s: %s', filename, ME.message);
    end
end

function roi_size = calculate_roi_size(label_file)
    % Calculate the size of the ROI based on the number of vertices
    if exist(label_file, 'file') ~= 2
        error('Label file does not exist: %s', label_file);
    end

    data = read_label('',label_file);
    if isempty(data)
        error('Label file is empty or could not be read.');
    end
    roi_size = size(data, 1);
end


function data = read_label_file(filename)


    % Read FreeSurfer label file manually
    fid = fopen(filename, 'r');
    if fid == -1
        error('Cannot open file: %s', filename);
    end
    
    try
        % Read header (first line usually starts with #)
        header = fgetl(fid);
        if ~startsWith(header, '#')
            warning('Unexpected header format in file: %s', filename);
        end
        
        % Read number of vertices
        n_vertices = str2double(fgetl(fid));
        if isnan(n_vertices)
            error('Invalid number of vertices in file: %s', filename);
        end
        
        % Initialize data array
        data = zeros(n_vertices, 5);
        
        % Read vertex data
        for i = 1:n_vertices
            line = fgetl(fid);
            if line == -1
                error('Unexpected end of file at vertex %d', i);
            end
            values = sscanf(line, '%f');
            if length(values) ~= 5
                error('Invalid data format at vertex %d', i);
            end
            data(i,:) = values';
        end
        
    catch ME
        fclose(fid);
        rethrow(ME);
    end
    
    fclose(fid);
end
