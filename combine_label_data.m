%% Define the folder containing the label files
base_folder = '/Volumes/T7/AMPB/code/mpm/roi_study2';
hemi = 'R';
area = 'PT';
folder_name = sprintf('MNI152NLin2009cAsym_%s_label-%s', hemi, area);
folder_path = fullfile(base_folder, folder_name);

%% read labels
% Get list of label files
label_files_struct = dir(fullfile(folder_path, '*.label'));
label_files = fullfile(folder_path, {label_files_struct.name});

% Exclude files starting with '._' or containing 'averaged'
exclude_mask = startsWith({label_files_struct.name}, '._') | ...
               contains({label_files_struct.name}, 'averaged');

label_files = label_files(~exclude_mask);


% Process the files and combine vertices
[label_data, ids] = process_label_files(label_files);
combined_data = combineVertices(label_data);


%% functions
%% read all labels
function [all_data, subject_ids] = process_label_files(label_files)
    num_labels = length(label_files);
    all_data = [];
    subject_ids = {};
    valid_count = 0;
    
    % Read all label files using read_label
    for i = 1:num_labels
        try
            fprintf('Reading file %d/%d: %s\n', i, num_labels, label_files{i});
            [data, ~] = read_label('', label_files{i});
            if ~isempty(data)
                subject_ids{i} = label_files{i};
                data(:,5) = 1; % Set the last column to 1 for each file
                all_data = [all_data; data];
                valid_count = valid_count + 1;
                fprintf('Successfully read with %d vertices\n', size(data, 1));
            end
        catch ME
            warning('Error reading file %s: %s', label_files{i}, ME.message);
        end
    end
    
    % Report summary
    fprintf('\nProcessing Summary:\n');
    fprintf('Total files: %d\n', num_labels);
    fprintf('Successfully read: %d\n', valid_count);
    fprintf('Failed/Skipped: %d\n\n', num_labels - valid_count);
    
    if isempty(all_data)
        error('No valid label data found. Check input files.');
    end
end

%% Combine rows with identical vertex coordinates by summing their values
function [combinedData] = combineVertices(data)
    T = array2table(data, 'VariableNames', {'VertexIndex', 'X', 'Y', 'Z', 'Value'});
    combinedTable = groupsummary(T, {'VertexIndex', 'X', 'Y', 'Z'}, 'sum', 'Value');
    combinedData = [combinedTable.VertexIndex, ...
                   combinedTable.X, ...
                   combinedTable.Y, ...
                   combinedTable.Z, ...
                   combinedTable.sum_Value];
end

