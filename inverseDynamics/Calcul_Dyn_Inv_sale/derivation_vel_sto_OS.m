function [ACC_STO] = derivation_vel_sto_OS(VEL_STO)

n_frame = length(VEL_STO.time);
noms_champs = fieldnames(VEL_STO);
n_signal = length(noms_champs) ;

for i_sig = 2:n_signal
    
    nom_signal = noms_champs{i_sig} ;
    tmp_vec = VEL_STO.(nom_signal);
    freq = 1/(VEL_STO.time(2)-VEL_STO.time(1));
    tmp_vec = derive_colonne(tmp_vec,freq);
    ACC_STO.(nom_signal)=tmp_vec' ;

end

end
