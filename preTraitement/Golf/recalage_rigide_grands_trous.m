function  st_marqueurs_cine = recalage_rigide_grands_trous(st_marqueurs_cine,Marqueurs_Segment)

%% #############################################################################################################################
% Sauret Christophe, IBHGC
% 05/05/2017

% st_marqueurs_cine : structure contenant les coordonn�es de tous les marqueurs
% Marqueurs_Segment : liste des marqueurs du segment � traiter : exemple : {'C7', 'MAN', 'XYP', 'T8', 'T12', 'COTG', 'COTD'}
% #############################################################################################################################
%%

        nb_marqueurs_segment = length(Marqueurs_Segment);
        Mat = zeros(size(st_marqueurs_cine.(Marqueurs_Segment{1}),1),nb_marqueurs_segment);
        
        for i_col = 1:nb_marqueurs_segment
            Mat(:,i_col)=st_marqueurs_cine.(Marqueurs_Segment{i_col})(:,1);          
        end
        
      A = isnan(Mat);
      ind = find(sum(A,2)>=1);
      
      for i_ind = 1:length(ind)
          % on verifie qu'il y a bien au moins 3 marqueurs pour faire un recalage rigide
          Marqueurs_presents = A(ind(i_ind),:)==0;
          
          
          % on compte combien il y a de marqueurs manquants � recaler
          Marqueurs_abscents = A(ind(i_ind),:)==1;
          Qui_est_abscent = find( Marqueurs_abscents==1);
          
          for i_marqueurs_abscents = 1:sum( Marqueurs_abscents)
              
              
              if sum(Marqueurs_presents)>=3
                  % on cherche sur les frames proches une frame ou le marqueur est presents
                  ok=0; i=0;
                  while ok==0
                      i = i+1;
                      
                      % on cherche sur la frame d'avant
                      if ind(i_ind)-i>=1
                          if ~isnan(Mat(ind(i_ind)-i,Qui_est_abscent))
                              Marqueurs_presents_i = -(A(ind(i_ind)-i,:)==0) - Marqueurs_presents;
                              Qui_presents_both_frames = find(Marqueurs_presents_i==-2); % les marqueurs sont pr�sents dans les deux frames (i et frame � corriger)
                              if size(Qui_presents_both_frames,2)>=3
                                  cluster_initial = zeros(size(Qui_presents_both_frames,2),3);
                                  cluster_reference = zeros(size(Qui_presents_both_frames,2),3);
                                  for i_m = 1:size(Qui_presents_both_frames,2)
                                      cluster_initial(i_m,:) =  st_marqueurs_cine.(Marqueurs_Segment{Qui_presents_both_frames(i_m)})(ind(i_ind)-i,:);
                                      cluster_reference(i_m,:) =  st_marqueurs_cine.(Marqueurs_Segment{Qui_presents_both_frames(i_m)})(ind(i_ind),:);
                                  end
                                  
                                  Marqueur_a_recaler =  st_marqueurs_cine.(Marqueurs_Segment{Qui_est_abscent(i_marqueurs_abscents)})(ind(i_ind)-i,:); % en met en dernier le marqueur a recaler
                                  Registered_marker = fct_recalage(cluster_reference, cluster_initial, Marqueur_a_recaler);
                                  st_marqueurs_cine.(Marqueurs_Segment{Qui_est_abscent(i_marqueurs_abscents)})(ind(i_ind),:)=Registered_marker;
                                  % mise � jour des variable Mat et A
                                  Mat(ind(i_ind),Qui_est_abscent(i_marqueurs_abscents))=Registered_marker(1);
                                  A(ind(i_ind),Qui_est_abscent(i_marqueurs_abscents))=0;
                                  ok=1; % pour sortir du while
                                  
                              else %on ne peut rien faire
                              end
                              
                          else % on ne peut rien faire
                          end
                      end
                      
                      % si �a n'a pas march� avec la frame d'avant on teste avec la frame d'apr�s
                      if ind(i_ind)+i<=size(Mat,1)
                          if ~isnan(Mat(ind(i_ind)+i,Qui_est_abscent))
                              Marqueurs_presents_i = -(A(ind(i_ind)+i,:)==0) - Marqueurs_presents;
                              Qui_presents_both_frames = find(Marqueurs_presents_i==-2); % les marqueurs sont pr�sents dans les deux frames (i et frame � corriger)
                              if size(Qui_presents_both_frames,2)>=3
                                  cluster_initial = zeros(size(Qui_presents_both_frames,2),3);
                                  cluster_reference = zeros(size(Qui_presents_both_frames,2),3);
                                  for i_m = 1:size(Qui_presents_both_frames,2)
                                      cluster_initial(i_m,:) =  st_marqueurs_cine.(Marqueurs_Segment{Qui_presents_both_frames(i_m)})(ind(i_ind)+i,:);
                                      cluster_reference(i_m,:) =  st_marqueurs_cine.(Marqueurs_Segment{Qui_presents_both_frames(i_m)})(ind(i_ind),:);
                                  end
                                  
                                  Marqueur_a_recaler =  st_marqueurs_cine.(Marqueurs_Segment{Qui_est_abscent(i_marqueurs_abscents)})(ind(i_ind)+i,:); % en met en dernier le marqueur a recaler
                                  Registered_marker = fct_recalage(cluster_reference, cluster_initial, Marqueur_a_recaler);
                                  st_marqueurs_cine.(Marqueurs_Segment{Qui_est_abscent(i_marqueurs_abscents)})(ind(i_ind),:)=Registered_marker;
                                  % mise � jour des variable Mat et A
                                  Mat(ind(i_ind),Qui_est_abscent(i_marqueurs_abscents))=Registered_marker(1);
                                  A(ind(i_ind),Qui_est_abscent(i_marqueurs_abscents))=0;
                                  ok=1; % pour sortir du while
                                  
                              else %on ne peut rien faire
                              end
                              
                          else % on ne peut rien faire
                          end
                      end
                      if ind(i_ind)+i>size(Mat,1) && ind(i_ind)-i<1
%                           disp('Un Marqueurs n''est pr�sent sur aucune frame.')
                          break
                      end
                  end
              end
          end
      end
end
