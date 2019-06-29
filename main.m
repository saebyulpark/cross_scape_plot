
addpath(genpath(pwd))
 
song_a=readmidi('./samples/case1_song_a.mid');
song_b=readmidi('./samples/case1_song_b.mid');

pitch_or_rhythm = 1; % pitch = 1, rhythm = 2

D= get_distance_matrix (song_a, song_b, pitch_or_rhythm); 
Sim=get_similarity_score(D); 

