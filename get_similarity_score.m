function similarity_score = get_similarity_score(result_matrix)
% Calculate the similarity score of two songs based on distance matrix.
  weight_begin_num = 0.5;
  weight = linspace(weight_begin_num,1,size(result_matrix,1))';
  weighted_matrix = result_matrix.*weight;
  weighted_matrix = weighted_matrix(3:end,:);
  D = mean(mean(weighted_matrix(weighted_matrix<1.1)));
  similarity_score = 1-D;
  display(sprintf('Similarity score is %.4f',similarity_score));  
end
