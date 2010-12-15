function res = ft_mv_performance(design,post,metric)
% FT_MV_PERFORMANCE computes performance for a certain design and posterior
% given a particular metric.
%
% Supported metrics:
% 'acuracy'
% 'logprob'
% 'correlation'
% 'invresvar'
% 'contingency'
% 'cfmatrix'
%
%   Copyright (c) 2010, Marcel van Gerven
%

if isempty(metric)
  error('performance metric undefined');
end

if ~iscell(design)
  design = {design};
  post = {post};
end

% iterate over datasets
res = cell(length(design),1);
for c=1:length(design)
  
  switch lower(metric)
    
    case 'accuracy'
      
      % compute the total correct classification rate which collapses over all
      % classes and is insensitive to the relative frequency of occurrence of
      % examples from each class
      tmp = contingency(design{c},post{c});
      res{c} = sum(diag(tmp))./size(design{c},1);
      
    case 'logprob'
      
      % compute summed log probability of the real class
      res{c} = 0;
      for j=1:size(post{c},1)
        res{c} = res{c} + log(post{c}(j,design{c}(j)));
      end
      
    case 'correlation'
      
      res{c} = ones(1,size(design{c},2));
      idx = find(~all(design{c} == post{c}));
      for i=1:length(idx)
        res{c}(idx(i)) = corr(design{c}(:,idx(i)),post{c}(:,idx(i)));
      end      
      res{c}(isnan(res{c})) = 0;
      
    case 'invresvar'
      % 1 / residual variance; inverse because large values should indicate
      % better performance
      
      res{c} = 1 ./ mean((design{c} - post{c}).^2);
      
    case 'contingency'
      
      % return contingency table
      res{c} = contingency(design{c},post{c});
      
    case 'cfmatrix'
      
      % return the table of classification rates, i.e.,
      % the so-called confusion matrix
      
      tmp = contingency(design{c},post{c});
      tmp = tmp ./ repmat(sum(tmp,2),[1 size(tmp,2)]);
      tmp(isnan(tmp)) = 0;
      res{c} = tmp;
      
    otherwise
      
      error('unknown performance metric');
      
  end
  
end

if length(res) == 1
  res = res{1};
end

  function res = contingency(design,post)
    % compute contingency table with true class as rows and predicted class as
    % columns
    
    % number of classes
    numcls = size(post,2);
    
    % predicted classes with the maximum posterior probability
    [tmp,pcls] = max(post,[],2);
    
    res = zeros(numcls);
    for i=1:numcls % true class is in rows
      ii = (design==i);
      for j=1:numcls % assigned class is in columns
        jj = (pcls==j);
        res(i,j) = sum(ii(:) & jj(:));
      end
    end
  end

end