function [Sim]=get_similarity_score(result_matrix)
      

%%
weight_begin_num=0.5;
weight=linspace(weight_begin_num,1,size(result_matrix,1))';
weighted_matrix=result_matrix.*weight;
weighted_matrix=weighted_matrix(3:end,:);
D=mean(mean(weighted_matrix(weighted_matrix<1.1)));

Sim=1-D;
display(sprintf('Similarity score is %.4f',Sim));

end


