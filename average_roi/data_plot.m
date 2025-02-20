% Load the data
n = size(ids, 2) % number of subjects
plot_data = combined_data(:, 5)/n;  % Extracts the 5th column


% Generate x-axis (index for each data point)
x = 1:length(plot_data);

% Scatter Plot (Y-axis as Data)
figure;
scatter(x, plot_data, 'b', 'filled');
xlabel('Index');
ylabel('Averaged Data');
title('Scatter Plot of Averaged Data');
grid on;

% Fit a Normal Distribution
pd = fitdist(plot_data, 'Normal');

% Generate Normal Distribution for Y-Axis
y_values = linspace(min(plot_data), max(plot_data), 100);
pdf_values = normpdf(y_values, pd.mu, pd.sigma);

% Normalize PDF for visualization on the y-axis
pdf_values = pdf_values / max(pdf_values) * max(x) * 0.8; % Scale for visibility

% Overlay Normal Distribution Curve on the Y-Axis
hold on;
plot(pdf_values, y_values, 'r', 'LineWidth', 2); % Red line for Normal PDF
legend('Data Points', 'Fitted Normal Distribution');

% Display estimated parameters
disp(['Estimated Mean: ', num2str(pd.mu)]);
disp(['Estimated Std Dev: ', num2str(pd.sigma)]);

% Suggest a Threshold (e.g., Mean + 1 SD)
threshold = pd.mu + pd.sigma;
yline(threshold, '--k', 'Threshold'); % Dashed black line
disp(['Suggested Threshold: ', num2str(threshold)]);
