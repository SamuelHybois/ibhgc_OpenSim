function     st_marqueurs_cine = recalage_rigide_absent(st_marqueurs_cine,Marqueurs_Segment,cur_seg,path_static_trc)
%% #############################################################################################################################
% Haering Diane, IBHGC
% 30/05/2018

% st_marqueurs_cine : structure contenant les coordonnées de tous les marqueurs
% Marqueurs_Segment : liste des marqueurs du segment à traiter : exemple : {'C7', 'MAN', 'XYP', 'T8', 'T12', 'COTG', 'COTD'}
% path_static_trc :
% cur_seg : 
%
% #############################################################################################################################
%%   

% Read static file
    st_marqueurs_static = lire_donnees_trc(path_static_trc);
    noms_marqueurs_static = st_marqueurs_static.noms;
    coord_marqueurs_static = st_marqueurs_static.coord;

% Initialize present and absent markers 
    nb_marqueurs_segment = length(Marqueurs_Segment);
    Marqueurs_presents = [];
    Marqueurs_absents = [];
    Marqueurs_static = [];
    
    for i_mark = 1:nb_marqueurs_segment
        try
           st_marqueurs_cine.(Marqueurs_Segment{i_mark});
           Marqueurs_presents = [Marqueurs_presents; i_mark];
        catch
           Marqueurs_absents = [Marqueurs_absents; i_mark];
        end
        Marqueurs_static = [Marqueurs_static; find(strcmp(Marqueurs_Segment{i_mark},noms_marqueurs_static))];
    end
    Marqueurs_static = [Marqueurs_static*3-2 Marqueurs_static*3-1 Marqueurs_static*3]';
    coord_marqueurs_static = coord_marqueurs_static(:,Marqueurs_static(:));
    
    if numel(Marqueurs_presents)>=3 %il faut au moins 3 marqueurs presents pour effectuer le recalage rigide 
        true_frame = find(sum(isnan([st_marqueurs_cine.(Marqueurs_Segment{Marqueurs_presents(1)})(:,:)...
                                        st_marqueurs_cine.(Marqueurs_Segment{Marqueurs_presents(2)})(:,:)...
                                        st_marqueurs_cine.(Marqueurs_Segment{Marqueurs_presents(end)})(:,:)] ) ,2) ==0)';
        nb_frame = size(st_marqueurs_cine.(Marqueurs_Segment{Marqueurs_presents(1)})(:,:),1);
        
        % Initialize static segment frame
         As = coord_marqueurs_static(1,[Marqueurs_presents(1)*3-2 Marqueurs_presents(1)*3-1 Marqueurs_presents(1)*3])';
         Bs = coord_marqueurs_static(1,[Marqueurs_presents(2)*3-2 Marqueurs_presents(2)*3-1 Marqueurs_presents(2)*3])';
         Cs = coord_marqueurs_static(1,[Marqueurs_presents(end)*3-2 Marqueurs_presents(end)*3-1 Marqueurs_presents(end)*3])';
         Xs = (Cs-As)./norm(Cs-As);
         Ys = (Bs-As)./norm(Bs-As);
         Zs = cross(Xs,Ys)./norm(cross(Xs,Ys));
         Xs = cross(Ys,Zs);
         Rs = [Xs Ys Zs As;0 0 0 1];
        
         for imark = 1:length(Marqueurs_absents)
             % Missing marker in static
             Ds = [coord_marqueurs_static(1,[Marqueurs_absents(imark)*3-2 Marqueurs_absents(imark)*3-1 Marqueurs_absents(imark)*3]) 1]'; % in static
             D0 = NaN(nb_frame,3);

             for iframe = true_frame
                % Segment frame during curent move
                 A = st_marqueurs_cine.(Marqueurs_Segment{Marqueurs_presents(1)})(iframe,:)';
                 B = st_marqueurs_cine.(Marqueurs_Segment{Marqueurs_presents(2)})(iframe,:)';
                 C = st_marqueurs_cine.(Marqueurs_Segment{Marqueurs_presents(end)})(iframe,:)';
                 X = (C-A)./norm(C-A);
                 Y = (B-A)./norm(B-A);
                 Z = cross(X,Y)./norm(cross(X,Y));
                 X = cross(Y,Z);
                 R0 = [X Y Z A;0 0 0 1];  

                % missing markers coordinates
                D0_temp = R0*(Rs\Ds); % in move 
                D0(iframe,:)=D0_temp(1:3);   

                %%% !! A essayer ?!!%%%
                %[Registered_Data] = fct_recalage(Cluster_Reference,Cluster_to_register,Data_to_register)

             end %iframe

             % Add marker in current move
             st_marqueurs_cine.(Marqueurs_Segment{Marqueurs_absents(imark)}) = D0;

%             % Vérifications
%             figure, hold on,         
%             plot3(As(1),As(2),As(3),'*k'),text(As(1)-0.005,As(2)-0.05,As(3)-0.005,Marqueurs_Segment{Marqueurs_presents(1)})
%             plot3(Bs(1),Bs(2),Bs(3),'*k'),text(Bs(1)-0.005,Bs(2)-0.05,Bs(3)-0.005,Marqueurs_Segment{Marqueurs_presents(2)})
%             plot3(Cs(1),Cs(2),Cs(3),'*k'),text(Cs(1)-0.005,Cs(2)-0.05,Cs(3)-0.005,Marqueurs_Segment{Marqueurs_presents(end)})
%             plot3(Ds(1),Ds(2),Ds(3),'*r'),text(Ds(1)-0.005,Ds(2)-0.05,Ds(3)-0.005,Marqueurs_Segment{Marqueurs_absents(imark)})
%     
%             plot3(A(1),A(2),A(3),'ok'),text(A(1)-0.005,A(2)-0.005,A(3)-0.005,Marqueurs_Segment{Marqueurs_presents(1)})
%             plot3(B(1),B(2),B(3),'ok'),text(B(1)-0.005,B(2)-0.005,B(3)-0.005,Marqueurs_Segment{Marqueurs_presents(2)})
%             plot3(C(1),C(2),C(3),'ok'),text(C(1)-0.005,C(2)-0.005,C(3)-0.005,Marqueurs_Segment{Marqueurs_presents(end)})
%             plot3(D0_temp(1),D0_temp(2),D0_temp(3),'or'),text(D0_temp(1)-0.005,D0_temp(2)-0.005,D0_temp(3)-0.005,Marqueurs_Segment{Marqueurs_absents(imark)})
%             axis equal         
%              norm2([D0_temp(1:3)-A, D0_temp(1:3)-B, D0_temp(1:3)-C, B-A, C-B, A-C]')...
%              - norm2([Ds(1:3)-As, Ds(1:3)-Bs, Ds(1:3)-Cs, Bs-As, Cs-Bs, As-Cs]')

         end %imark
    else display(['!!! Pas assez de marqueurs presents pour faire le recalage rigide de ' cur_seg ' !!!'])
    end %if nb_mark_present>=3
end %function
