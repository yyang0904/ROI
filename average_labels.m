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

% Construct the output file path
output_file = fullfile(folder_path, sprintf('averaged_%s_mask.label', area));

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



function avg_label = average_label(label_files, output_file)
    num_labels = length(label_files);
    all_data = cell(num_labels, 1);
    valid_count = 0;

    % Read all label files and set the last column to 1
    for i = 1:num_labels
        try
            fprintf('Reading file %d/%d: %s\n', i, num_labels, label_files{i});
            data = read_label_file(label_files{i});

            if ~isempty(data)
                % Set the last column (stat value) to 1
                data(:,5) = 1;
                all_data{i} = data;
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

    % Remove empty cells
    all_data = all_data(~cellfun('isempty', all_data));

    if isempty(all_data)
        error('No valid label data found. Check input files.');
    end

    % Get all unique vertices
    fprintf('Computing unique vertices...\n');
    all_vertices = unique(cell2mat(cellfun(@(x) x(:,1), all_data, 'UniformOutput', false)));

    % Initialize storage for averaged label
    avg_label = zeros(length(all_vertices), 5);
    avg_label(:,1) = all_vertices;

    % Compute mean coordinates & intensity values
    for v = 1:length(all_vertices)
        v_idx = all_vertices(v);
        matches = [];
        for i = 1:num_labels
            if ~isempty(all_data{i})
                row = all_data{i}(all_data{i}(:,1) == v_idx, :);
                if ~isempty(row)
                    matches = [matches; row];
                end
            end
        end
        if ~isempty(matches)
            avg_label(v, 2:4) = mean(matches(:, 2:4), 1);
            avg_label(v, 5) = mean(matches(:, 5), 1); % This will average the 1s
        else
            avg_label(v, 2:4) = NaN;
            avg_label(v, 5) = NaN;
        end

        % Progress update every 10%
        if mod(v, ceil(length(all_vertices)/10)) == 0
            fprintf('Progress: %d%%\n', round(v/length(all_vertices)*100));
        end
    end

    % Save averaged label
    fprintf('Saving averaged label file...\n');
    save_label(avg_label, output_file);
    fprintf('✅ Averaged label saved to: %s\n', output_file);
end

% 
% function avg_label = average_label(label_files, output_file)
%     num_labels = length(label_files);
%     all_data = cell(num_labels, 1);
%     valid_count = 0;
% 
%     % Read all label files
%     for i = 1:num_labels
%         try
%             fprintf('Reading file %d/%d: %s\n', i, num_labels, label_files{i});
%             data = read_label_file(label_files{i});
% 
%             if ~isempty(data)
%                 all_data{i} = data;
%                 valid_count = valid_count + 1;
%                 fprintf('Successfully read with %d vertices\n', size(data, 1));
%             end
%         catch ME
%             warning('Error reading file %s: %s', label_files{i}, ME.message);
%         end
%     end
% 
%     % Report summary
%     fprintf('\nProcessing Summary:\n');
%     fprintf('Total files: %d\n', num_labels);
%     fprintf('Successfully read: %d\n', valid_count);
%     fprintf('Failed/Skipped: %d\n\n', num_labels - valid_count);
% 
%     % Remove empty cells
%     all_data = all_data(~cellfun('isempty', all_data));
% 
%     if isempty(all_data)
%         error('No valid label data found. Check input files.');
%     end
% 
%     % Get all unique vertices
%     fprintf('Computing unique vertices...\n');
% 
% 
%     % Get all unique vertices from all files, even if some files lack them
%     all_vertices = unique(cell2mat(cellfun(@(x) x(:,1), all_data(~cellfun('isempty', all_data)), 'UniformOutput', false)));
% 
%     % Initialize storage for averaged label
%     avg_label = zeros(length(all_vertices), 5);
%     avg_label(:,1) = all_vertices;
% 
%     % Compute mean coordinates & intensity values
%     for v = 1:length(all_vertices)
%         v_idx = all_vertices(v);
%         matches = [];
%         for i = 1:num_labels
%             if ~isempty(all_data{i})
%                 row = all_data{i}(all_data{i}(:,1) == v_idx, :);
%                 if ~isempty(row)
%                     matches = [matches; row];
%                 end
%             end
%         end
%         if ~isempty(matches)
%             avg_label(v, 2:end) = mean(matches(:, 2:end), 1);
%         else
%             avg_label(v, 2:end) = NaN; % Placeholder if vertex missing in all files
%         end
% 
% 
% 
%         % Progress update every 10%
%         if mod(v, ceil(length(all_vertices)/10)) == 0
%             fprintf('Progress: %d%%\n', round(v/length(all_vertices)*100));
%         end
%     end
% 
%     % Save averaged label
%     fprintf('Saving averaged label file...\n');
%     save_label(avg_label, output_file);
%     fprintf('✅ Averaged label saved to: %s\n', output_file);
% end

function save_label(label_data, output_file)
    % Ensure the output folder exists
    [output_folder, ~, ~] = fileparts(output_file);
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end

    % Writes a FreeSurfer label file
    fid = fopen(output_file, 'w');
    if fid == -1
        error('Failed to open file: %s', output_file);
    end

    fprintf(fid, '# Averaged label file\n');
    fprintf(fid, '%d\n', size(label_data, 1));
    fprintf(fid, '%d %f %f %f %f\n', label_data');
    fclose(fid);
end

% Call the averaging function
try
    avg_label = average_label(label_files, output_file);
    fprintf('Label averaging completed successfully!\n');
catch ME
    fprintf('Error during label averaging:\n%s\n', ME.message);
    disp(ME.stack);
end

