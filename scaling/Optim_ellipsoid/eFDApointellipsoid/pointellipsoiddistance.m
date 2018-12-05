function [xsol,lams,timeeigA,xall] = pointellipsoiddistance(A,b,k)
% [xsol,lams,timeeigA,xall] = pointellipsoiddistance(A,b,k)
% Given an ellipse, find the point nearest to the origin. 
%
% xsol is the point on the ellipsoid nearest the origin, and the distance is norm(xsol). 
% The ellipsoid is determined as the points x for which
% (x-b)'*(inv(A))*(x-b) = k^2. 
% If the distance between a point v and the ellipsoid is needed, run 
% [xsol,lams] = pointellipsoiddistance(A,b-v,k)
% 
% With 3 or fewer outputs the code runs a fast algorithm
% [xsol,lams,timeeigA] = pointellipsoiddistance(A,b,k)
% finds only the global minimizer xsol (faster, size <=10000). 
% 
% With 4 or more outputs the code runs a slower algorithm (finds all KKT points)
% [xsol,lams,timeeigA,xall,lams] = pointellipsoiddistance(A,b,k)
% also finds all the KKT points, columns of xall (slower, size <=3000). 
%
% Input parameters: 
% A: nxn, covariance matrix 
% b: nx1, center vector
% k: >0 scalar, "radius" of ellipse (default:1)
%
% Outputs: 
% xsol: (nx1) nearest point on ellipse, minimal distance is norm(xsol)
% lams: (1x1 or 2nx1) Lagrange multipliers 
% timeeigA: (1x1) runtime for the eigendecomposition of A
% xall: (nx2n) lists all the KKT points: outputting this switches the method
% to a slower version. 
%
% This code handles nongeneric cases in two ways: 
% (i) singular A (positive semidefinite) is allowed. 
% (ii) treats the case where the Lagrange multiplier coincides with an
% eigenvalue
% 

n = length(A); O = zeros(n); Ovec = zeros(n,1); % preparation

tol = 1e-13;

if nargin<3, k = 1; end

if norm(A-diag(diag(A)),'fro')>tol*norm(A,'fro') % A not diagonal, compute eigendecomposition
tStart = tic; [Q,D] = eig(A); timeeigA = toc(tStart); % eigendecomposition and time it 
D = diag(D);
else % A is diagonal
Q = speye(n); D = diag(A); timeeigA = 0;
end

% deal with singular case
y = Q'*b;
IXp = find(abs(D)/max(abs(D))>tol);
IXc = find(abs(D)/max(abs(D))<=tol);
d0 = D(IXp); y0 = y(IXp); % extract only positive eigenvalues in case A is singular


if nargout<4 % just the global solution
ct = Q'*b;
% Since B is singular, next find a shift step so that (A-step*B) is nonsingular
lmin = 0; % should make f(lmin)>0
step = max(D)/sqrt(n);
while fval(lmin,D,ct,k)<0
    lmin = lmin-step; 
    step = step*1.5; % gradually increase step size    
end

% form generalized eigenproblem M0-\lam M1
M0 = sparse(2*n+1,2*n+1);M1 = M0; 
M0(1,1) = k^2;
M0(1,end-n+1:end) = ct';
M0(end-n+1:end,1) = ct;
M0(2:n+1,2:n+1) = -spdiags(D,0,n,n); 
M0(2:n+1,n+2:end) = -spdiags(D,0,n,n); 
M0(n+2:end,2:n+1) = -spdiags(D,0,n,n); 
M1(2:n+1,n+2:end) = speye(n); 
M1(n+2:end,2:n+1) = speye(n); 

M1 = -M1;
[V,lams] = eigs(M1,M0-lmin*M1,1,'lr'); % compute the leftmost eigenpair
lams = real(lmin+1/lams);
v = real(V);
 if abs(v(1))>tol % generic case
  x1t = -(lams/v(1))*v(2:n+1);
  x1t = Q*x1t; 
  xsol = x1t; 
  mindis = norm(x1t);    
 else
    %should be min(abs(lams-D))<tol*norm(A,'fro')
    Ip = find(abs(lams-D)/max(abs(D))>sqrt(tol));
    Ic = find(abs(lams-D)/max(abs(D))<sqrt(tol));
    if norm(y(Ic))>tol, % not a KKT point, recompute
[V,lams] = eigs(M1,M0-lmin*M1,2,'lr'); % compute the leftmost eigenpair
lams = real(lmin+1/lams);
v = real(V);
  x1t = -(lams/v(1))*v(2:n+1);
  x1t = Q*x1t; 
  xsol = x1t; 
  mindis = norm(x1t);            
    else % check if solution(s) exist 
        yt = zeros(n,1); 
        yt(Ip) = D(Ip).*y(Ip)./(lams*ones(size(D(Ip)))-D(Ip)); % assign appropriate values for determined indices
    if sum(((yt(Ip)-y(Ip)).^2)./D(Ip))>k^2,  % no feasible solution
    else % solution exist, non-unique
        yt(Ic) = sqrt(lams*(k^2-sum(((yt(Ip)-y(Ip)).^2)./D(Ip))))/sqrt(length(Ic));
    % should be 1 = (yt(IXp)-y(IXp))'*(diag(D(IXp))\(yt(IXp)-y(IXp)))/k^2    
    end
    xsol = Q*yt;     
    end         
 end


else % compute ALL KKT points; about 10 times slower 
    
M0 = [k^2 Ovec' b';Ovec -A -A;b -A O];
M1 = [zeros(1,2*n+1);Ovec -O eye(n);Ovec eye(n) O];

%[V,lam] = eig(M0,-M1); lam = diag(lam); % full eigendecomposition, this will take long for n>1000. 
lam = eig(M0,-M1); % just compute eigenvalues. This makes life better. 

IX = find(imag(lam)==0 & abs(lam)<1/tol); % pick real Lagrange multipliers
lams = lam(IX); 

xall = zeros(n,length(lams)); 
yy = xall;
mindis = inf;

r = lams; 
y = Q'*b;

dis = zeros(1,length(r));
for it = 1:length(r)
    % treat exceptionally in the non-generic case where r(it) matches eigenvalue 
    if min(abs(r(it)-D))<tol*norm(A,'fro')
    Ip = find(abs(r(it)-D)/max(abs(D))>tol);
    Ic = find(abs(r(it)-D)/max(abs(D))<tol);
    if norm(y(Ic))>tol, % not a KKT point
        xall(:,it) = nan(n,1); 
    else % check if solution(s) exist 
        yt(Ip) = D(Ip).*y(Ip)./(r(it)*ones(size(D(Ip)))-D(Ip)); % assign appropriate values for determined indices
    if sum(((yt(Ip)-y(Ip)).^2)./D(Ip))>k^2,  % no feasible solution
        keyboard
    else % solution exist, non-unique
        yt(Ic) = sqrt(r(it)*(k^2-sum(((yt(Ip)-y(Ip)).^2)./D(Ip))))/sqrt(length(Ic));
    % should be 1 = (yt(IXp)-y(IXp))'*(diag(D(IXp))\(yt(IXp)-y(IXp)))/k^2
    end
    end
    else % generic case; this should happen 99.9999% of the time        
yy(:,it) = -r(it)*((diag(diag(D)-r(it)*eye(n)).\y)); 
yy(IXc,it) = y(IXc); % force singular components
yt = yy(:,it);
    end
scale = (yt(IXp)-y(IXp))'*(diag(D(IXp))\(yt(IXp)-y(IXp)))/k^2; yt = (yt-y)/sqrt(scale)+y;  % scale to force on ellipse            
xall(:,it) = Q*yt; 
dis(it) = norm(xall(:,it));
end

[mindis,IX] = min(dis);  % find point from candidates satisfying KKT
xsol = xall(:,IX);

end
end


function flam = fval(lam,d,y,k)
% returns rational function f(lam)
% for f(lam) = k^2-\sum(diyi^2/(lam-di)^2)=0
flam = k^2;
for it = 1:length(d)
    flam = flam - d(it)*(y(it)^2)/(lam-d(it))^2;
end
end
