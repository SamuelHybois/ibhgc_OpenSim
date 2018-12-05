function structQ = traductionQVecteurStruct(vectQ,labelQ)

liste_q = fieldnames(labelQ) ;

if length(vectQ)==length(liste_q)
    
    for i_q = 1:length(vectQ)
        
        nom_q = liste_q{i_q} ;
        structQ.(nom_q) = vectQ(i_q) ;
        
    end
    
else disp('! Coordonnées généralisées q mal labellisées !')
    
end


end