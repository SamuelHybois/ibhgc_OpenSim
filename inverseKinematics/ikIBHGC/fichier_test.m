liste_ddl = fieldnames(Generalized_coordinates) ;

for i_ddl = 1:length(liste_ddl)
   nom_ddl = liste_ddl{i_ddl} ;
   DDL = Generalized_coordinates.(nom_ddl) ;
   coordGeneralisee_t.(nom_ddl) = DDL(1) ;
end

% Convertir les DDL en rotation du ik.mot de degrés en radians
for i_ddl = [1:3,7:22]
  qOpt(i_ddl) = (pi/180)*qOpt(i_ddl) ; 
end

bar([varIni;qOpt;qOpt_ikmot]')
legend('Initial','Optimal','Optimal_O_S')
fname = fieldnames(structQ) ;
set(gca, 'XTick', 1:length(fname),'XTickLabel',fname);

bar(qOpt-qOpt_ikmot)