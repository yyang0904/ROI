%% average process
n = size(ids, 2) % number of subjects
td = 0.52299; % Threshold
averaged_data = processVertexData(combined_data, n, td);

% Display summary of the results
fprintf('Original number of vertices: %d\n', size(label_data, 1));
fprintf('Number of unique vertices after combining: %d\n', size(combined_data, 1));

% Create output path with td value in filename
output_filename = sprintf('averaged_label-%.3f.label', td);  % %.2f will format td to 2 decimal places
output_path = fullfile(folder_path, output_filename);

% Save to label file
saveToLabel(averaged_data, output_path, 'subject01');

%% average process
function [processedData] = processVertexData(combined_data, n, td)
    processedData = combined_data;
    
    % Step 1: Divide the last column by n
    processedData(:,5) = processedData(:,5) / n;
    
    % Step 2: Apply binary threshold
    processedData(:,5) = processedData(:,5) >= td;
    
    % Step 3: Remove rows with 0 in the last column
    processedData = processedData(processedData(:,5) == 1, :);
end

%% save data into .label file
function saveToLabel(data, output_path, subject_id)   
    if nargin < 3
        subject_id = 'matlab';
    end
    
    % Extract components from the data matrix
    vertex_indices = data(:,1);    % First column
    xyz_coords = data(:,2:4);      % Columns 2-4 (X, Y, Z)
    values = data(:,5);            % Last column (Values)
    
    % Write to label file
    ok = write_label(vertex_indices, xyz_coords, values, output_path, subject_id);
    
    if ok
        fprintf('Successfully saved label file to: %s\n', output_path);
    else
        error('Failed to save label file to: %s\n', output_path);
    end
end
