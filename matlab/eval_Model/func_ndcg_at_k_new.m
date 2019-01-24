function res=func_ndcg_at_k_new(n_k, pred, y)
%% 
% pred is the predicted relevance, an n by m matrix
% y is the ground truth relevance, an n by m matrix
% n is the number of users
% m is the number of items

pred = full(pred);
y = full(y);

% return the averaged ndcg for retrieving items for the users
[n,m]=size(pred);

%% compute the ranks of the items for each user
[dummy, I] = sort(pred, 2, 'descend');
ranks = zeros(size(pred));

[dummy, ideal_I] = sort(y, 2, 'descend');
ideal_ranks = zeros(size(pred));

res = zeros(1, n_k);
cnt = 0;
for i=1:n
	ranks(i, I(i, :)) = 1:m;
	ideal_ranks(i, ideal_I(i, :)) = 1:m;

	nz = find(y(i, :)~=0);
    nnz = length(nz);
	pos = ranks(i, nz);
	ideal_pos = ideal_ranks(i, nz);
    
    
    nominator = (power(2,I(i, nz))-1)./log(pos + 1);
    denominator = (power(2,I(i, nz))-1) ./ log(ideal_pos + 1);
    if n_k > nnz
        % pad more 0
        nominator = padarray(nominator, [0, n_k - nnz], 0, 'post');
        denominator = padarray(denominator, [0, n_k - nnz], 0, 'post');
    elseif n_k < nnz
        % truncate the tail
        nominator = nominator(1:n_k);
        denominator = denominator(1:n_k);
    end
    
    if size(find(cumsum(denominator)==0), 2) ~= 0
        tmp = zeros(1,n_k);
    else
        tmp = cumsum(nominator)./ cumsum(denominator);
        cnt = cnt + 1;
    end
    %tmp = full(tmp);
    %tmp = padarray(tmp, [0, length(k_vals) - size(tmp, 2)], 0, 'post');
	res = res + tmp;
end
res = res / cnt;
