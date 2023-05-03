% Script to collect informed consent electronically.

% Required input:
% Conset type: 1) Multisensory perception, 2) multisensory eeg
% enter participant ID
%
% The screen will prompt questions and solicit participants feedback
clear; close all;

%------------------------------------------------------
% study types:
StudyNames{1} = 'Multisensorische Wahrnehmung';
StudyNames{2} = 'Messung der Gehirnaktivität bei multisensorischer Wahrnehmung';

%------------------------------------------------------
% Conset statements
Q{1} = 'Ich habe die Informationen zur Studie gelesen und verstanden. Die Studie und die \newlinekonkrete Aufgabe wurden mir ausführlich erklärt. Ich habe die Instruktionen verstanden \newlineund hatte ausreichend Gelegenheit Fragen zu stellen.';
Q{2} = 'Mir ist bewusst, dass die Daten entsprechend der Datenschutz-Grundverordnung (DSGVO) \newlineanonym gespeichert und verarbeitet werden.';
Q{3} = 'Ich verstehe, dass meine Teilnahme an der Studie freiwillig ist und ich diese jederzeit, \newlineund ohne Angabe von Gründen, widerrufen kann, ohne dass mir daraus Nachteile \newlineentstehen. Eine eventuelle Vergütung erfolgt anteilig.';
Q{4} = 'Mir ist bewusst, dass die Daten in anonymer Form in wissenschaftlichen Studien \newlinepräsentiert und mit anderen Wissenschaftlern geteilt werden können.';

QE{1} = 'I have read and understood the information about the study. The study and the \newlineconcrete task were explained to me in detail. I understood the instructions \newlineand had sufficient opportunity to ask questions.';
QE{2} = 'I am aware that the data will be stored and processed anonymously\newline in accordance with the Data Protection Regulation (DSGVO).';
QE{3} = 'I understand that my participation in the study is voluntary and that I can cancel it at any time, \newlineand without giving reasons, without incurring any disadvantages. \newlineAny compensation will be paid proportionately.';
QE{4} = 'I am aware that the data may be presented anonymously in scientific studies \newline and shared with other scientists.';

% window position
WinPos = [-1724         125        1411         700];
WinPos2 = [ -2100         300         911         600];

% log directory
ARG.log_dir = 'C:\Users\eeglab\Desktop\CNSLAB\Consent\log'; % log path


%-------------------------------------------------------------------------------------------------
fprintf('\n--------------------------------------\n')
fprintf('Obtain informed consent. Choose study type\n')
for l=1:length(StudyNames)
  fprintf('%d   %s \n',l,StudyNames{l})
end
ConId = input('Consent Type: ');
ARG.ConId = ConId;

Subj = input('Participant Id: ','s');
ARG.Subj = Subj;
c = clock;
sname = sprintf('%s/Consent_%s_%02d%02d-%02d%02d.mat',ARG.log_dir,Subj,c(3),c(2),c(4),c(5));

%-------------------------------------------------------------------------------------------------

% set language and response cues
ARG.Sprache = input('Sprache Deutsch (1) oder Englisch (2): ');
if ~isnumeric(ARG.Sprache)
  ARG.Sprache = 1;
end

if ARG.Sprache == 1
% startint text
Text{1} = 'Elektronische Einwilligungserklärung';
Text{2} = 'Im Folgenden stellen wir Ihnen noch einige Fragen';
pause (1);
f = figure(1);clf;
set(f,'Position',WinPos);
axis; axis off
tmp = sprintf('%s \n \n Studie: %s',Text{1},StudyNames{ConId});
t = text(0.2,0.8,tmp,'FontSize',22);

c = uicontrol('Position',[500 100  200 200],'String','Weiter','Callback','uiresume(f)');
uiwait(f)
delete(t);

Ok =[];
for q=1:length(Q)
  t = text(0.05,0.8,Q{q},'FontSize',18);
  c = uicontrol('Position',[500 100  200 200],'String','Einverstanden','Callback','uiresume(f)');
  uiwait(f)
  delete(t);
  Ok(q) = 1;
  
end
ARG.Ok = Ok;
ARG.clock = clock;

save(sname,'ARG');

tmp = sprintf('%s',Text{2});
t = text(0.2,0.8,tmp,'FontSize',18);
pause(1);
close;

% General questionaire

warning off
Text = 'Tragen Sie normalerweise eine Brille oder Kontaktlinsen?';

AQ{1} = MFquestdlg(WinPos2,Text,'Frage 1/5','Ja','Nein','Keine Angabe','KA');

Text = 'Wurde bei Ihnen jemals eine neurologische Krankheit diagnostiziert? (z.B.: Epilepsie, Autismus, Schizophrenie, Parkinson)';
AQ{2} = MFquestdlg(WinPos2,Text,'Frage 2/5','Ja','Nein','Keine Angabe','KA');
Text = 'Haben Sie bekannte Hördefizite?';
AQ{3} = MFquestdlg(WinPos2,Text,'Frage 3/5','Ja','Nein','Keine Angabe','KA');

Text = 'Ihr Geschlecht';
AQ{4} = MFquestdlg(WinPos2,Text,'Frage 4/5','M','W','Keine Angabe','KA');



prompt = {'Ihr Alter';};
dlgtitle = 'Input';
dims = [1 30];
definput = {''};
AQ{5}  = MFinputdlg(WinPos2,prompt,dlgtitle,dims,definput);

warning on
ARG.AQ = AQ;
save(sname,'ARG');
close all;


else
% startint text
Text{1} = 'Electronic Consent';
Text{2} = 'In the following we ask you some questions';
pause (1);
f = figure(1);clf;
set(f,'Position',WinPos);
axis; axis off
tmp = sprintf('%s \n \n Studie: %s',Text{1},StudyNames{ConId});
t = text(0.2,0.8,tmp,'FontSize',22);

c = uicontrol('Position',[500 100  200 200],'String','OK','Callback','uiresume(f)');
uiwait(f)
delete(t);

Ok =[];
for q=1:length(QE)
  t = text(0.05,0.8,QE{q},'FontSize',18);
  c = uicontrol('Position',[500 100  200 200],'String','Agree','Callback','uiresume(f)');
  uiwait(f)
  delete(t);
  Ok(q) = 1;
  
end
ARG.Ok = Ok;
ARG.clock = clock;

save(sname,'ARG');

tmp = sprintf('%s',Text{2});
t = text(0.2,0.8,tmp,'FontSize',18);
pause(1);
close; 

% General questionaire

warning off
Text = 'Do you normally wear glasses or contact lenses?';

AQ{1} = MFquestdlg(WinPos2,Text,'Frage 1/5','Yes','No','No specification ','KA');

Text = 'Have you ever been diagnosed with a neurological disease? (e.g.: epilepsy, autism, schizophrenia, Parkinsons disease)';
AQ{2} = MFquestdlg(WinPos2,Text,'Frage 2/5','Yes','No','No specification ','KA');
Text = 'Do you have any known hearing deficits?';
AQ{3} = MFquestdlg(WinPos2,Text,'Frage 3/5','Yes','No','No specification ','KA');

Text = 'Your gender';
AQ{4} = MFquestdlg(WinPos2,Text,'Frage 4/5','M','F','No specification ','KA');



prompt = {'Your age';};
dlgtitle = 'Input';
dims = [1 30];
definput = {''};
AQ{5}  = MFinputdlg(WinPos2,prompt,dlgtitle,dims,definput);

warning on
ARG.AQ = AQ;
save(sname,'ARG');
close all;

end
