% Activate path
addpath(genpath(pwd))

% Load midi files
song_a = readmidi('./samples/case1_song_a.mid');
song_b = readmidi('./samples/case1_song_b.mid');

% Select pitch/rhythm mode
pitch_or_rhythm = 1; % pitch = 1, rhythm = 2

% Caculate distance matrix and similarity score
dist_mat = get_distance_matrix (song_a, song_b, pitch_or_rhythm); 
similarity_score = get_similarity_score(dist_mat); 
