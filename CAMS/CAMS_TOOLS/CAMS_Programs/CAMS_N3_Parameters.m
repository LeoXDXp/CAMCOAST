function CAMS_N3_Parameters(dirN2_p,dirN2_d,dirN2_s,dirN3)

%Extraction de Hm, Tm, et dateT:
cd(dirN2_p);
liste=dir('GPP_Param*.mat');
Hsn=[];Tmn=[];date=[];
for i=1:length(liste)   
    load(liste(i).name)
    Hsn=[Hsn hsT];
    Tmn=[Tmn TmT];
    date=[date dateT]; 
end 
[date_p ordX]=sort(date);
Hs=Hsn(ordX);
Tm=Tmn(ordX); 

%Extraction of direction and associated dates:
cd(dirN2_d);
liste=dir('*Dir*.mat');
Dir=[]; date_d=[];

for i=1:length(liste)   
load(liste(i).name)
Dir =[Dir angi];
date_d=[date_d  dati]; 
end 
    [date_d ordX]=sort(date_d);
    Dir = Dir(ordX); 

%Extraction of the dimension line:
cd(dirN2_s);
liste=dir('GPP_ligne-eau_*.mat');
Yn=[];date=[];
for i=1:length(liste)
    load(liste(i).name)
    Yn=[Yn Y];
    date=[date dateavg]; 
    [MT ordX]=sort(date);
    MY=Yn(:,ordX);
end 

%Elimination of outliers
indHs = find(Hs > (2.*nanstd(Hs)+nanmean(Hs)));
Hs(indHs) = NaN;

% For the dimension line
ind=find(nanmean(MY)>=50&nanmean(MY)<=80); % Indices of exploitable water lines
MYe=nanmean(MY(:,ind)); % instantaneous vector (every 15 min) of exploitable waterline averaged long-shore
date_s=MT(ind);

% TIME SERIES Hs, Tp, Dir and MY
% Creation of time series with NaN at times when there is no data

% Série temporelle avec des intervalles de 15 min = 1/96 day Julien
% Time series with 15 min intervals = 1/96 Julien day	
temps = min([date_p(1),date_d(1),date_s(1)]):1/96:max([date_p(end),date_d(end),date_s(end)]);

% Extraction of the values of "Hs_gpp" and "Tp_gpp" (video) corresponding to "time".
Hs_temps = nan(1,length(temps));
Tm_temps = nan(1,length(temps));
Dir_temps = nan(1,length(temps));
MYe_temps = nan(1,length(temps));
% We want to obtain a time series with "NaN" at the times of the time vector where we do not have data.
for i=1:size(temps,2)  
% We look for the dates for which we have a value of Hs. The +0.00007 (= 06 min) allows to have a margin of error on the dates.
    ind_t = find(date_p >= temps(i)-0.00007 & date_p <= temps(i)+0.00007);
    ind_d = find(date_d >= temps(i)-0.00007 & date_d <= temps(i)+0.00007);
    ind_s = find(date_s>= temps(i)-0.00007 & date_s <= temps(i)+0.00007);

    if length(ind_t)==1
        Hs_temps(i) = Hs(ind_t);
        Tm_temps(i) = Tm(ind_t);       
%     else
%         Hs_temps(i) = NaN;
%         Tm_temps(i) = NaN;
    end
    
    if length(ind_d)==1
        Dir_temps(i) = Dir(ind_d);
%     else
%         Dir_temps(i) = NaN;
    end
    
    if length(ind_s)==1
        MYe_temps(i) = MYe(ind_s);      
%     else
%          MYe_temps(:,i) = NaN;
    end
end

Hs = Hs_temps;
Tm = Tm_temps;
Dir = Dir_temps;
MY = MYe_temps;
    
%CALIBRATION
%Calcul des coefficients de calibration
[C1_Hs,C2_Hs,C1_Tm,C2_Tm,C1_Dir,C2_Dir]  = GPP_calibr_ADCP_VID(Hs,Tm,temps,Dir);

cd(dirN3);
save('GPP_N3_Coeff_Calibration','C1_Hs','C2_Hs','C1_Tm','C2_Tm','C1_Dir','C2_Dir');

%Hs Calibrée
Hs =(Hs.*C1_Hs) + C2_Hs; 

%Tm Calibrée 
Tm =(Tm.*C1_Tm) + C2_Tm; 

%Dir Calibrée
Dir = (Dir.*C1_Dir) + C2_Dir;
 
% DAILY AVERAGES AND TYPICAL WAVE PARAMETER EXCLUSIONS
% Daily average and standard deviations of Hs and Tm:

% Vectors time, list of days.
liste_j = datenum((datestr(temps,'yyyymmdd')),'yyyymmdd');% list of days of the time vector, a day appears several times.
temps_j = unique(liste_j); % list of days of the time vector, each day appears once

Hs_j = []; 
Std_Hs_j = [];
Tm_j = [];
Std_Tm_j = [];
Dir_j=[];
Std_dir_j=[];
MY_j = []; 
Std_MY_j = [];    
for j = 1 : length(temps_j)
        ind_mj = find(liste_j == temps_j(j));
        
        Hs_j = [Hs_j nanmean(Hs(ind_mj))];
        Std_Hs_j = [Std_Hs_j nanstd(Hs(ind_mj))];
        
        Tm_j = [Tm_j nanmean(Tm(ind_mj))];
        Std_Tm_j = [Std_Tm_j nanstd(Tm(ind_mj))];
        
        Dir_j=[Dir_j nanmean(Dir(ind_mj))];
        Std_dir_j=[Std_dir_j nanstd(Dir(ind_mj))];
        
        MY_j = [MY_j nanmean(MY(ind_mj))];
        Std_MY_j = [Std_MY_j nanstd(MY(ind_mj))];
                       
end

% MONTHLY AVERAGES AND TYPICAL DEPTHS OF WAVE PARAMETERS

% Vectors time, list of days
liste_m = datenum((datestr(temps,'yyyymm')),'yyyymm');% list of months of the time vector, a month appears several times.
temps_m = unique(liste_m); %list of months of the time vector, each month appears once

Hs_m = []; 
Std_Hs_m = [];
Tm_m = [];
Std_Tm_m = [];
Dir_m=[];
Std_dir_m=[];
MY_m = []; 
Std_MY_m = [];

for j = 1 : length(temps_m)
        ind_mj = find(liste_m == temps_m(j));
        
        Hs_m = [Hs_m nanmean(Hs(ind_mj))];
        Std_Hs_m = [Std_Hs_m nanstd(Hs(ind_mj))];
        
        Tm_m = [Tm_m nanmean(Tm(ind_mj))];
        Std_Tm_m = [Std_Tm_m nanstd(Tm(ind_mj))];
        
        Dir_m=[Dir_m nanmean(Dir(ind_mj))];
        Std_dir_m=[Std_dir_m nanstd(Dir(ind_mj))];
        
        MY_m = [MY_m nanmean(MY(ind_mj))];
        Std_MY_m = [Std_MY_m nanstd(MY(ind_mj))];        
end


% AVERAGE FIGURES DAILY
fig_j = figure;;
    subplot(3,1,1);
     plot(temps_j,Hs_j,'LineWidth',2); 
     title ('Daily evolution of significant height');
     %xlim([min(date2) max(date2)]);
     xlabel('time (YY/mm)');
     ylabel ('<Hs_j>_Y (m)'); set(gca,'XTick',temps_j(1):60:temps_j(end));
     set(gca,'XTick',temps_j(1):60:temps_j(end));
     set(gca,'XTickLabel',datestr(temps_j(1):60:temps_j(end),'YY/mm'));
     legend('significant height'); 

    subplot(3,1,2);
     plot(temps_j,Tm_j,'LineWidth',2); 

     %xlim([min(date2) max(date2)]);
     title ('day-to-day evolution of the average period');
     xlabel('time (YY/mm)');
     ylabel ('<Tmjr>_Y (m)');
     set(gca,'XTick',temps_j(1):60:temps_j(end));
     set(gca,'XTickLabel',datestr(temps_j(1):60:temps_j(end),'YY/mm'));
     legend('average period'); 

     subplot(3,1,3)

    plot(temps_j,Dir_j,'LineWidth',2);
    legend('Daily Direction','Location','NorthEast');
    ylabel('Direction(°)')
    set(gca,'XTick',temps_j(1:31:end))
    set(gca,'XTickLabel',datestr(temps_j(1:31:end),'yy/mm'));
    xlabel('time (YY/mm)')
    set(gcf,'Color','w')
    title('Evolution of the direction of GPP waves by video')
    %patch([temps_j(1) temps_j(end)], [0 0], [1 0 0],'LineWidth',2);
    a=Dir_j(1);
    b=Dir_j(end);
    text(temps_j(end-100),-3,'Cross-shore impact');
    ylim([min(Dir_j)-5 max(Dir_j)+5])
%xlim([(temps_j(1)-1) (temps_j(end)+1)])


fig_m = figure;
    subplot(3,1,1);
        plot(temps_m,Hs_m,'LineWidth',2); hold on; plot(temps_m,Hs_m-Std_Hs_m,'r','LineWidth',2); plot(temps_m,Hs_m+Std_Hs_m,'r','LineWidth',2)
        title ('Monthly evolution of significant height');
        %xlim([min(date2) max(date2)]);
        xlabel('time (YY/mm)');
        ylabel ('<Hs_j>_Y (m)'); set(gca,'XTick',temps_m(1):60:temps_m(end));
        set(gca,'XTick',temps_m(1):60:temps_m(end));
        set(gca,'XTickLabel',datestr(temps_m(1):60:temps_m(end),'YY/mm'));
        legend('Significant Height','ecart-type'); hold off

        subplot(3,1,2);
        plot(temps_m,Tm_m,'LineWidth',2); 
        hold on; 
        plot(temps_m,Tm_m-Std_Tm_m,'r','LineWidth',2);
        plot(temps_m,Tm_m+Std_Tm_m,'r','LineWidth',2);
        %xlim([min(date2) max(date2)]);
        title ('Daily evolution of the average period');
        xlabel('time (YY/mm)');
        ylabel ('<Tmjr>_Y (m)');
        set(gca,'XTick',temps_m(1):60:temps_m(end));
        set(gca,'XTickLabel',datestr(temps_m(1):60:temps_m(end),'YY/mm'));
        legend('Average Period','ecart-type'); hold off

    subplot(3,1,3)
        plot(temps_m,Dir_m,'xb','LineWidth',2);
        legend('Daily Direction','Location','NorthEast');
        ylabel('Direction(°)')
        set(gca,'XTick',temps_j(1:31:end))
        set(gca,'XTickLabel',datestr(temps_j(1:31:end),'yy/mm'));
        xlabel('time (YY/mm)')
        set(gcf,'Color','w')
        title('Evolution of the direction of GPP waves by video')
        %patch([temps_j(1) temps_j(end)], [0 0], [1 0 0],'LineWidth',2);
        a=Dir_j(1);
        b=Dir_j(end);
        text(temps_j(end-100),-3,'Cross-shore impact');
        ylim([min(Dir_j)-5 max(Dir_j)+5])
        %xlim([(temps_j(1)-1) (temps_j(end)+1)])
        

fig_s = figure;
    subplot(2,1,1);
        plot(temps_j,MY_j-MY_j(1),'LineWidth',2);
        title ('Daily evolution of the water line');
        %xlim([min(date2) max(date2)]);
        xlabel('time (YY/mm)');
        ylabel ('<Position trait de côte (m)'); set(gca,'XTick',temps_j(1):60:temps_j(end));
        set(gca,'XTick',temps_j(1):60:temps_j(end));
        set(gca,'XTickLabel',datestr(temps_j(1):60:temps_j(end),'YY/mm'));
        legend('Water Line);

    subplot(2,1,2);
        plot(temps_m,MY_m,'LineWidth',2); hold on; plot(temps_m,MY_m-Std_MY_m,'--','color','red'); plot(temps_m,MY_m+Std_MY_m,'--','color','red')
        title ('Monthly evolution of the water line');
        %xlim([min(date2) max(date2)]);
        xlabel('time (YY/mm)');
        ylabel ('Position trait de côte (m)'); set(gca,'XTick',temps_j(1):60:temps_j(end));
        set(gca,'XTick',temps_j(1):60:temps_j(end));
        set(gca,'XTickLabel',datestr(temps_j(1):60:temps_j(end),'YY/mm'));
        legend('Water Line,'ecart-type'); hold off

        
cd(dirN3);

saveas(fig_j,'GPP_N3_Evolution_parametres_days.jpg');
saveas(fig_m,'GPP_N3_Evolution_parametres_months.jpg');
saveas(fig_s,'GPP_N3_Evolution_Shoreline_days.jpg');

filename_day = ['GPP_N3_Days_' datestr(temps(1),'yyyymmdd') '-' datestr(temps(end),'yyyymmdd') '.txt'];
fid1 = fopen(filename_day,'wt');
fprintf(fid1,'%s\t',' Date  ');
fprintf(fid1,'%s\t',' Hs(m)  ');
fprintf(fid1,'%s\t',' Tp(s)  ');
fprintf(fid1,'%s\t','Dir(°)');
fprintf(fid1,'%s\n','Trait de côte(m)');

for i=1:length(Hs_j)
    fprintf(fid1,'%s\t',datestr(temps_j(i)));
    fprintf(fid1,'%8.4f\t',Hs_j(i));   
    fprintf(fid1,'%8.4f\t',Tm_j(i));
    fprintf(fid1,'%1.0f\t',Dir_j(i));
    fprintf(fid1,'%8.4f\n',MY_j(i));
end

filename_months = ['GPP_N3_Months_' datestr(temps(1),'yyyymmdd') '-' datestr(temps(end),'yyyymmdd') '.txt'];
fid2 = fopen(filename_months,'wt');
fprintf(fid2,'%s\t',' Date  ');
fprintf(fid2,'%s\t',' Hs(m)  ');
fprintf(fid2,'%s\t',' Std(Hs)(m)  ');
fprintf(fid2,'%s\t',' Tp(s)  ');
fprintf(fid2,'%s\t',' Std(Tp)(s) ');
fprintf(fid2,'%s\t',' Dir(°)  ');
fprintf(fid2,'%s\t',' Std(Dir)(°)  ');
fprintf(fid2,'%s\t','Trait de côte(m)');
fprintf(fid2,'%s\n',' Std(trait côte)(m)');

for i=1:length(Hs_m)
    fprintf(fid2,'%s\t',datestr(temps_m(i)));
    fprintf(fid2,'%8.4f\t',Hs_m(i));
    fprintf(fid2,'%8.4f\t',Std_Hs_m(i));
    fprintf(fid2,'%8.4f\t',Tm_m(i));
    fprintf(fid2,'%8.4f\t',Std_Tm_m(i));
    fprintf(fid2,'%8.4f\t',Dir_m(i));
    fprintf(fid2,'%8.4f\t',Std_dir_m(i));
    fprintf(fid2,'%8.4f\t',MY_m(i));
    fprintf(fid2,'%8.4f\n',Std_MY_m(i));
    
end

cd(dirN3);
filename = ['GPP_N3_Parameters_' datestr(temps(1),'yyyymmdd') '-' datestr(temps(end),'yyyymmdd')];
save(filename,'temps_j','Hs_j','Tm_j','Dir_j','MY_j','Std_Hs_j','Std_MY_j','Std_Tm_j','Std_dir_j',...
    'temps_m','Hs_m','Tm_m','Dir_m','MY_m','Std_Hs_m','Std_Tm_m','Std_dir_m','Std_MY_m');
end



