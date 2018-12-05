function Struct_MH_ISB = calcul_MH_ISB(Struct_MH,struct_OSIM,Struct_OSIM_gen)

%%%%EN DUR%%%%%
List = {'TS_r','AA_r','AI_r','AC_r','TS_l','AA_l','AI_l','AC_l','Yt'};
%%%%%%%%%%%%%%%
s = {'_r','_l'};
% Lecture des positions des marqueurs dans le modèle osim (coordonnées
% relatives, dans chaque segment).
bodies = fieldnames(Struct_MH);
nb_frame = size(Struct_MH.(bodies{1}).MH,3);
MH_body=zeros(4,4,nb_frame);

%1) On récupère les coordonnées des points d'intérêt dans R0
coord_R0_gen=struct;

for i_frame = 1:nb_frame % On passe les coordonnées des marqueurs des segments vers R0
    for i_marker=1:length(Struct_OSIM_gen.Model.MarkerSet.objects.Marker)
        if ~isempty(find( ( not (cellfun( @isempty , strfind( List , Struct_OSIM_gen.Model.MarkerSet.objects.Marker(i_marker).ATTRIBUTE.name) ))) ==1, 1))
            Name_Body_for_marker=Struct_OSIM_gen.Model.MarkerSet.objects.Marker(i_marker).body;
            
            
            for i_body = 1:length(struct_OSIM.Model.BodySet.objects.Body)
                if strcmp(struct_OSIM.Model.BodySet.objects.Body(i_body).ATTRIBUTE.name,Name_Body_for_marker)
                    scale_factors =struct_OSIM.Model.BodySet.objects.Body(i_body).VisibleObject.scale_factors;
                end
            end
            
            coord_marker=scale_factors .* Struct_OSIM_gen.Model.MarkerSet.objects.Marker(i_marker).location;
            
            MH_body(:,:,i_frame)=Struct_MH.(Name_Body_for_marker).MH(:,:,i_frame);
            
            coord_marker_R0=MH_body(:,:,i_frame)*[coord_marker 1]';
            
            nom_mrk_R0=Struct_OSIM_gen.Model.MarkerSet.objects.Marker(i_marker).ATTRIBUTE.name;
            
            coord_R0_gen.(nom_mrk_R0)(i_frame,:)=coord_marker_R0(1:3)';
        end
        
    end
end

%%%%%%%%%%%%%%%%%%%% Repère scapula ISB %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i_s = 1:length(s)
    side = s(i_s);
    AA = ['AA' char(side)];
    TS = ['TS' char(side)];
    AI = ['AI' char(side)];
    scap = ['scapula' char(side)];
    
    for i_f = 1 :nb_frame
        %          Os_AA_R0 = coord_R0_gen.(AA)(i_f,:) - Struct_MH.(scap).MH(1:3,4,i_frame)' ;
        
        if i_s==1
            Zs_R0(i_f,:) = (coord_R0_gen.(AA)(i_f,:)  - coord_R0_gen.(TS)(i_f,:))/...
                norm( coord_R0_gen.(AA)(i_f,:)  - coord_R0_gen.(TS)(i_f,:) );
        else
            Zs_R0(i_f,:) = -(coord_R0_gen.(AA)(i_f,:)  - coord_R0_gen.(TS)(i_f,:))/...
                norm( coord_R0_gen.(AA)(i_f,:)  - coord_R0_gen.(TS)(i_f,:) );
        end
        
        Xs_R0(i_f,:) = -cross(Zs_R0(i_f,:),coord_R0_gen.(AA)(i_f,:)  - coord_R0_gen.(AI)(i_f,:))/...
            norm( cross( Zs_R0(i_f,:) , coord_R0_gen.(AA)(i_f,:)  - coord_R0_gen.(AI)(i_f,:) ) );
        
        Ys_R0(i_f,:) = cross(Zs_R0(i_f,:),Xs_R0(i_f,:));
        
        
        Struct_MH_ISB.(scap).MH(:,:,i_f) = [Xs_R0(i_f,:)',Ys_R0(i_f,:)',Zs_R0(i_f,:)',coord_R0_gen.(AA)(i_f,:)';0 0 0 1];
        Struct_MH_ISB.(scap).where = 'MH_R0_Rs';
        
        
        %%%%%%%%%%%%%%% Vérif %%%%%%%%%%%
%         if i_f ==1
%             for i_body = 1:length(struct_OSIM.Model.BodySet.objects.Body)
%                 if strcmp(struct_OSIM.Model.BodySet.objects.Body(i_body).ATTRIBUTE.name,scap)
%                     scale_factors =struct_OSIM.Model.BodySet.objects.Body(i_body).VisibleObject.scale_factors;
%                 end
%             end
%             
%             Obj = lire_fichier_vtp(['F:\M2_Stage\Data_treatement\DATABASE_Scaploc_Prel_last\M1\info_global\Geometry\' scap '.vtp']);
%             Obj.Polygones = Obj.Polygones +1 ;
%             affiche_objet_movie(Obj)
%             XX1=scale_factors(1)*Obj.Noeuds(:,1)';
%             XX2=scale_factors(2)*Obj.Noeuds(:,2)';
%             XX3=scale_factors(3)*Obj.Noeuds(:,3)';
%             Noeuds = Struct_MH.(scap).MH(:,:,i_frame) * [ XX1;XX2;XX3  ; ones( [1,length(Obj.Noeuds)] ) ];
%             Obj.Noeuds = Noeuds(1:3,:)';
%             affiche_objet_movie(Obj)
%             hold on
%             scatter3(coord_R0_gen.(AA)(i_f,1),coord_R0_gen.(AA)(i_f,2),coord_R0_gen.(AA)(i_f,3),'rs')
%             scatter3(Struct_MH.(scap).MH(1,4,i_frame),Struct_MH.(scap).MH(2,4,i_frame),Struct_MH.(scap).MH(3,4,i_frame),'r*')
%             scatter3(coord_R0_gen.(AI)(i_f,1),coord_R0_gen.(AI)(i_f,2),coord_R0_gen.(AI)(i_f,3),'r*')
%             scatter3(coord_R0_gen.(TS)(i_f,1),coord_R0_gen.(TS)(i_f,2),coord_R0_gen.(TS)(i_f,3),'r*')
%             
%             affiche_repere(coord_R0_gen.(AA)(i_f,:),Struct_MH_ISB.(scap).MH(1:3,1:3,i_f)',[0.001,0.001,0.001])
%             quiver3(coord_R0_gen.(AA)(i_f,1),coord_R0_gen.(AA)(i_f,2),coord_R0_gen.(AA)(i_f,3),Zs_R0(i_f,1),Zs_R0(i_f,2),Zs_R0(i_f,3),0.05)
%             quiver3(coord_R0_gen.(AA)(i_f,1),coord_R0_gen.(AA)(i_f,2),coord_R0_gen.(AA)(i_f,3),Ys_R0(i_f,1),Ys_R0(i_f,2),Ys_R0(i_f,3),0.05)
%             quiver3(coord_R0_gen.(AA)(i_f,1),coord_R0_gen.(AA)(i_f,2),coord_R0_gen.(AA)(i_f,3),Xs_R0(i_f,1),Xs_R0(i_f,2),Xs_R0(i_f,3),0.05)
%         end
    end
end
%%%%%%%%%%%%%%%%%%%% Repère scapula ISB %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%% Repère clavicule ISB %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i_s = 1:length(s)
    side = s(i_s);
    AC = ['AC' char(side)];
    
    clav = ['clavicle' char(side)];
    
    for i_f = 1 :nb_frame
        
        Yt(i_f,:) = ( coord_R0_gen.Yt(i_f,:) - Struct_MH.thorax.MH(1:3,4,i_f)') /...
            norm(coord_R0_gen.Yt(i_f,:) - Struct_MH.thorax.MH(1:3,4,i_f)');
        
        if i_s ==1
        Zc_R0(i_f,:) = (coord_R0_gen.(AC)(i_f,:)  - Struct_MH.(clav).MH(1:3,4,i_f)')/...
            norm( coord_R0_gen.(AC)(i_f,:)  - Struct_MH.(clav).MH(1:3,4,i_f)' );
        else
            Zc_R0(i_f,:) = -(coord_R0_gen.(AC)(i_f,:)  - Struct_MH.(clav).MH(1:3,4,i_f)')/...
            norm( coord_R0_gen.(AC)(i_f,:)  - Struct_MH.(clav).MH(1:3,4,i_f)' );
        end
        
            Xc_R0(i_f,:) = cross(Yt(i_f,:),Zc_R0(i_f,:))/...
                norm( cross( Yt(i_f,:) , Zc_R0(i_f,:) ) );
            Yc_R0(i_f,:) = cross(Zc_R0(i_f,:),Xc_R0(i_f,:));

        
        Struct_MH_ISB.(clav).MH(:,:,i_f) = [Xc_R0(i_f,:)',Yc_R0(i_f,:)',Zc_R0(i_f,:)',Struct_MH.(clav).MH(1:3,4,i_f);0 0 0 1];
        Struct_MH_ISB.(clav).where = 'MH_R0_Rs';
        
        
        %%%%%%%%%%%%% Vérif %%%%%%%%%%%
%                 if i_f ==1
%                     for i_body = 1:length(struct_OSIM.Model.BodySet.objects.Body)
%                         if strcmp(struct_OSIM.Model.BodySet.objects.Body(i_body).ATTRIBUTE.name,clav)
%                             scale_factors =struct_OSIM.Model.BodySet.objects.Body(i_body).VisibleObject.scale_factors;
%                         end
%                     end
%         
%                     Obj = lire_fichier_vtp(['D:\2017-Stage-PUCHAUDPierre\Manips\BL_V4\M1\SA09AS_T3S_R1\modele\Geometry\' clav '.vtp']);
%                     Obj.Polygones = Obj.Polygones +1 ;
%                     % affiche_objet_movie(Obj)
%         
%                     Noeuds = Struct_MH.(clav).MH(:,:,i_frame) * [ scale_factors'.*Obj.Noeuds' ; ones( [1,length(Obj.Noeuds)] ) ];
%                     Obj.Noeuds = Noeuds(1:3,:)';
%                     affiche_objet_movie(Obj)
%                     hold on
%                     scatter3(Struct_MH.(clav).MH(1,4,i_frame),Struct_MH.(clav).MH(2,4,i_frame),Struct_MH.(clav).MH(3,4,i_frame),'r*')
%                     affiche_repere(Struct_MH.(clav).MH(1:3,4,i_f)',Struct_MH_ISB.(clav).MH(1:3,1:3,i_f)',[0.005,0.005,0.005])
%                 end
                
%                 if i_f ==1
%                     for i_body = 1:length(struct_OSIM.Model.BodySet.objects.Body)
%                         if strcmp(struct_OSIM.Model.BodySet.objects.Body(i_body).ATTRIBUTE.name,clav)
%                             scale_factors =struct_OSIM.Model.BodySet.objects.Body(i_body).VisibleObject.scale_factors;
%                         end
%                     end
%         
%                     Obj = lire_fichier_vtp(['D:\2017-Stage-PUCHAUDPierre\Manips\BL_V4\M1\SA09AS_T3S_R1\modele\Geometry\' clav '.vtp']);
%                     Obj.Polygones = Obj.Polygones +1 ;
%                     % affiche_objet_movie(Obj)
%         
%                     Noeuds = Struct_MH_ISB.(clav).MH(:,:,i_frame) * [ scale_factors'.*Obj.Noeuds' ; ones( [1,length(Obj.Noeuds)] ) ];
%                     Obj.Noeuds = Noeuds(1:3,:)';
%                     affiche_objet_movie(Obj)
%                     hold on
%                     scatter3(Struct_MH_ISB.(clav).MH(1,4,i_frame),Struct_MH_ISB.(clav).MH(2,4,i_frame),Struct_MH_ISB.(clav).MH(3,4,i_frame),'r*')
%                     affiche_repere(Struct_MH_ISB.(clav).MH(1:3,4,i_f)',Struct_MH_ISB.(clav).MH(1:3,1:3,i_f)',[0.005,0.005,0.005])
%                 end
    end
    %%%%%%%%%%%%%%%%%%%% Repère scapula ISB %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    
    
end

