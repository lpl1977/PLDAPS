function loadPLDAPS()
%loadPLDAPS   load the pldaps folders into the matlab path

    %add the path to you PLDAPS code and other Dirs you want to have added
%     %(your stimuli
%     dirs{1}='~/Documents/PLDAPS';
% %     dirs{2}='~/Documents/stimuli';
 
 PLDAPSPath=mfilename('fullpath');
 seps=strfind(PLDAPSPath,filesep); 
 PLDAPSPath=PLDAPSPath(1:seps(end-1)-1);

    dirs{1}=PLDAPSPath;
    
    for j=1:length(dirs)
        a=genpath(dirs{j});
        b=textscan(a,'%s','delimiter',':');
        b=b{1};
        b(~cellfun(@isempty,strfind(b,'.git')))=[];
        addpath(b{:})
        display([dirs{j} ' added to the path\n']);
    end
end