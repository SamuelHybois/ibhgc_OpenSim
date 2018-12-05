function EcritureLogError( log_error,chemin )
% écrit le fichier de log des erreurs dans le chemin.

fid=fopen(chemin,'w');

for i_log=1:max(size(log_error,1),size(log_error,2))
%     fprintf(fid,'%s\n',log_error{i_log});
    fprintf(fid,'%s/n',log_error{i_log});
end

fclose(fid);
end

