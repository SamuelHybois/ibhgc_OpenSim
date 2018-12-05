function st_marqueurs_cine_out = mark_scaploc2mark_scapula(st_marqueurs_cine_in,side,sign)


% 1. correction distance
d_ScapLoc = 0.09 ; %Distance en m entre les marqueurs réfléchissants et les points palpés sur la scapula
st_marqueurs_cine_corr = decalageMarqueursScapLoc(st_marqueurs_cine_in,d_ScapLoc,sign);
st_marqueurs_cine = st_marqueurs_cine_corr;

% 3. suppression des marqueurs du scapula_locator
st_marqueurs_cine = rmfield(st_marqueurs_cine,'SCLL');
st_marqueurs_cine = rmfield(st_marqueurs_cine,'SCLM');
st_marqueurs_cine = rmfield(st_marqueurs_cine,'SCLB');
st_marqueurs_cine = rmfield(st_marqueurs_cine,'SCLHL');
st_marqueurs_cine = rmfield(st_marqueurs_cine,'SCLHM');

% 4. ajout des marqueurs de la scapula
eval(['st_marqueurs_cine.AA' side ' = st_marqueurs_cine_corr.SCLL;'])
eval(['st_marqueurs_cine.AI' side ' = st_marqueurs_cine_corr.SCLB;'])
eval(['st_marqueurs_cine.TS' side ' = st_marqueurs_cine_corr.SCLM;'])
eval(['st_marqueurs_cine.SCLHL' side ' = st_marqueurs_cine_corr.SCLHL;'])
eval(['st_marqueurs_cine.SCLHM' side ' = st_marqueurs_cine_corr.SCLHM;'])

st_marqueurs_cine_out = st_marqueurs_cine;

end % function