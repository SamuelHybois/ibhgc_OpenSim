function [wvec,b_const,train_acc,test_acc] = eFDA(train_data,train_label,test_data,test_label,scale)
%--------------------------
%  Given training samples and labels, find an global optimal classifier (w,b) of extended FDA
%  This program solves a convex programming problem when scale < 1 and a nonconvex problem otherwise.
%  The parameter kappa for extended FDA can influence the resulting prediction
%  performance, and when scale \approx 1 the classifier reduces to standard FDA. 
% 
%  For details of the underlying method and extended FDA see 
%  'Global Optimization methods for extended Fisher Discriminant Analysis',
%  by S. Iwata, Y. Nakatsukasa and A. Takeda, accepted to AISTAT 2014. 
%
% The main cost is in computing the distance between a point and an
% ellipsoid, and the complexity is roughly O(n^3), where n is the # of features. 

%Input parameters: 
% train_data: training samples (size = #training samples * #features)
% train_label: labels (+1 or -1) of training data (size = #training samples * 1) 
% test_data (optional): test samples (size = #test samples * #features)  
% test_label (optional): labels (+1 or -1) of test data (size = #test samples * 1) 
% scale (optional, default=1.1):  scale parameter. kappa of extended FDA is 
% set by kappa=scale*kappa_0, where kappa_0 is the convexity threshold 
%
%Outputs: 
% wvec: normal vector, w, of a classifier
% b_const: bias of a classifier
% train_acc: training accuracy
% test_acc: test accuracy (only when input includes test_data and test_label)
%--------------------------
% 
%
%


if nargin<4 
 predict_flag = 0; 
else
 predict_flag = 1; 
end
if nargin == 2 || nargin == 4   %%%nargin=2 or 4
 scale = 1.1;
elseif nargin == 3
 scale = test_data;
end

%%% Compute covariance matrices
ip = find(train_label==1);
in = find(train_label==-1);
Xp = train_data(ip,:);
Xn = train_data(in,:);
m_plus = length(ip);
m = length(train_label);

Cov_p = full(cov(Xp));  %%% Cov_p=((m_plus-1)/(m-m_plus-1))*full(cov(Xp));  %%% Cov_p=full(cov(Xp));
Cov_n = full(cov(Xn));  %%% Cov_n=full(cov(Xn));
mvp = mean(Xp);
mvn = mean(Xn);
CovMat = Cov_p+Cov_n;
meanvec = full(mvp-mvn)';
nonconvK_exact = sqrt(meanvec'*inv(CovMat)*meanvec);
k = nonconvK_exact*scale;

%%%%
%% find a global solution
%%%%
% (main cost lies here) compute the point-ellipsoid distance
[xsol,lams,timeeigA] = pointellipsoiddistance(CovMat,meanvec,k); 
%%%%
if k < nonconvK_exact
   wvec = xsol/norm(xsol);
else
   wvec = -xsol/norm(xsol);
end
if meanvec'*wvec < 0
   wvec = -wvec;
end

b_const = comp_min_b(wvec,train_label,train_data);
train_acc = robust_k_accuracy_data(train_data,train_label,wvec,b_const)/length(train_label)*100;
if predict_flag == 1
  test_acc = robust_k_accuracy_data(test_data,test_label,wvec,b_const)/length(test_label)*100;
end

end

%%-------------------------------------------------->
function [b_const] = comp_min_b(wvec,svm_label,svm_data)
% find the best b_const by solving empirical min probrem

proj_val = svm_data*wvec;
[sort_projval, sortInd] = sort(proj_val);
reorder_label = svm_label(sortInd);
cumlabel = cumsum(reorder_label);
[min_cum_y,min_ind] = min(cumlabel);
if min_ind == length(svm_label)
  b_const = -sort_projval(min_ind);
else
  b_const = -(sort_projval(min_ind)+sort_projval(min_ind+1))/2;
end
end

function accuracy = robust_k_accuracy_data(X,y,w,b)
% compute training or test accuracy 
z = size(X,1);
g = X*w+b*ones(z,1);
l = [];
for h = 1:z
  if g(h) >= 0
    l(h) = 1;
  else
    l(h) = -1;
  end
end
i = 0;
for h = 1:z
  if l(h)==y(h)
    i = i+1;
  end
end
accuracy = i;
end

