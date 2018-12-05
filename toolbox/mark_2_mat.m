function  TR = mark_2_mat(segment,mark1,mark2,mark3,mark4,sign)
% Cette fonction permet de reconstruire la matrice 4x4 d'un segment dans 
% un repere donné, à partir des coordonnées des marqueurs de ce segment 
% dans ce même repère
%                                                               Diane H
%                                                               06/04/18

nb_frame = size(mark1,1);
TR(4,4,nb_frame) = 0;

for iframe = 1:nb_frame
    
  if strcmp(segment,'thorax') % mark1=MAN, mark2=XYP, mark3=C7, mark4=T8
    mid_C7_MAN = (mark3(iframe,:)+mark1(iframe,:))./2 ;
    mid_T8_XYP = (mark2(iframe,:)+mark4(iframe,:))./2 ;
%     mid_T8_XYP = mark2(iframe,:) ; %if ~exist(T8) 
    Y = mid_C7_MAN - mid_T8_XYP; Y = Y./norm(Y);
    Z = cross(mark1(iframe,:)-mid_T8_XYP,mark3(iframe,:)-mid_T8_XYP); Z = Z./norm(Z);
    X = cross(Y,Z); X = X./norm(X);
    Z = cross(X,Y);
%sans T8:
%     Y = mark1(iframe,:)-mark2(iframe,:); Y = Y/norm(Y);
%     Z = cross(mark1(iframe,:)-mark2(iframe,:),mark3(iframe,:)-mark2(iframe,:));; Z = Z/norm(Z);
%     X = cross(Y,Z); X = X/norm(X);
%     Z = cross(X,Y);
    O = mark1(iframe,:);
  
  elseif strcmp(segment,'scapula') % mark1=AC, mark2=MTAC_L, mark3=MTAC_M, mark4=MTAC_B)
    u1 = (mark3(iframe,:) - mark4(iframe,:)); u1=u1./norm(u1);
    u2 = (mark2(iframe,:) - mark4(iframe,:)); u2=u2./norm(u2);
    normale_plan_Scap= sign*cross(u1,u2)./norm(cross(u1,u2));
    X = normale_plan_Scap ;
    Z = sign*(mark2(iframe,:)-mark3(iframe,:)); Z = Z./norm(Z);
    Y = cross(Z,X);
    O = mark1(iframe,:);
    
  elseif strcmp(segment,'scapula_AC') % mark1=AC, mark2=MTAC_L, mark3=MTAC_M, mark4=MTAC_B)
    Z = sign*(mark1(iframe,:)-mean([mark2(iframe,:);mark3(iframe,:);mark4(iframe,:)],1)); Z = Z./norm(Z);
    Y = mark3(iframe,:)-mark4(iframe,:); Y = Y./norm(Y);
    X = cross(Y,Z); X = X./norm(X);
    Y = cross(Z,X);
    O = mark1(iframe,:);
    
  elseif strcmp(segment,'humerus') %mark1=AA, mark2=EL, mark3=EM, mark4=US
    X = mark4(iframe,:)-mark3(iframe,:); X=X./norm(X);
    Y = mark1(iframe,:)-(mark2(iframe,:)+mark3(iframe,:))/2; Y=Y./norm(Y);
    Z = sign*cross(X,Y);
    X = cross(Y,Z);
    O = mark1(iframe,:);
   
  elseif strcmp(segment,'radius') %mark1=PSR, mark2=EL, mark3=EM
    mid_radius = (mark1(iframe,:)+mark2(iframe,:))/2;
    Y = mark2(iframe,:)-mark1(iframe,:); Y=Y./norm(Y);
    Z = mark2(iframe,:)-mark3(iframe,:); Z=Z./norm(Z);
    X = cross(Y,Z);
    Z = cross(X,Y);
    O = mid_radius;
    
  elseif strcmp(segment,'hand') %mark1=PSR, mark2=PSU, mark3=MC2, mark4=MC5
    mid_wrist = (mark1(iframe,:)+mark2(iframe,:))/2;
    mid_carp = (mark3(iframe,:)+mark4(iframe,:))/2;
    Y = mid_wrist-mid_carp; Y=Y./norm(Y);
    Z = mark1(iframe,:)-mark2(iframe,:); Z=Z./norm(Z);
    X = cross(Y,Z);
    Y = cross(Z,X);
    O = mid_wrist;
    
  end %if

  TR(:,:,iframe)=[X' Y' Z' O' ; 0 0 0 1];
  
end %iframe 

end %function