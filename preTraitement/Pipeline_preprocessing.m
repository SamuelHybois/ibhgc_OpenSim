function Pipeline_preprocessing(rep_global,cur_sujet,cur_activity,cur_static,nom_prot)

 [~, list_c3d]=PathContent_Type(fullfile(rep_global,cur_sujet,cur_activity),'.c3d');
 nb_acquisition=length(list_c3d);
               
file_events=fullfile(rep_global,'Events',[cur_sujet '_' cur_activity(end-6:end) '_EVENTS.xlsx']);
list_events=[]; list_trials=[]; isheet=1; 
while length(list_trials)<nb_acquisition 
    [events_temp,trials]=xlsread(file_events,isheet);
    events=NaN(length(trials),15);
    events(1:size(events_temp,1),1:size(events_temp,2))=events_temp;
    list_events=[list_events; events];
    list_trials=[list_trials ; trials];
    isheet=isheet+1;
end

for ifile=1:nb_acquisition
    cur_c3d=char(list_c3d(ifile));
    line_event=find(strncmp(cur_c3d,list_trials,length(char(cur_c3d))-4));
   
    path_c3d=char(fullfile(rep_global,cur_sujet,cur_activity,cur_c3d));
    true_events=find(~isnan(list_events(line_event,:)));
    crop_inf=list_events(line_event,true_events(1:end-1));
    crop_sup=list_events(line_event,true_events(2:end));
    if 1%~exist([path_c3d(1:end-4) '_part1.trc'],'file')
       display(['Preprocessing ' char(cur_c3d) '...']) 
       preparationDataFRM(char(fullfile(rep_global,'info_global',nom_prot)),path_c3d,cur_static,crop_inf,crop_sup)
    end
    
end

end
