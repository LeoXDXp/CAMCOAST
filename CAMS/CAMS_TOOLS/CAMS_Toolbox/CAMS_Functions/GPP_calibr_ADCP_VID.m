function [C1_Hs,C2_Hs,C1_Tm,C2_Tl,C1_Dir,C2_Dir] = GPP_calibr_ADCP_VID(Hs,Tm,temps,Dir_v)
load('GPP_ADCP_2014.mat'); 
%On enleve les NaN des donn�es Hs, Tp, et Dir:
ind = find(isnan(Hs)==0);
Hs = Hs(ind);
temps_Hs = temps(ind);

ind = find(isnan(Tm)==0);
Tm = Tm(ind);
temps_Tm = temps(ind);

ind = find(isnan(Dir_v)==0);
Dir_v = Dir_v(ind);
temps_Dir = temps(ind);

%On renomme pour plus de claret�;
Hs_adcp=Hs_swell;
Tp_adcp=Tp;
%Correction pour les directions:
Dir_adcp = (169-Dir);
Dir_v = Dir_v-90;
clear Dir

%Definition des listes et des vecteurs days pour l'adcp et la vid�o:
liste_j_adcp=str2num(datestr(date_adcp,'yyyymmdd'));
temps_j_adcp=unique(liste_j_adcp);

%Calibration de Hs;
Hs_v=[];
Hs_ADCP=[];
date_int=[];
liste_j_v=str2num(datestr(temps_Hs,'yyyymmdd'));
temps_j_v=unique(liste_j_v);

for i=1:length(temps_j_adcp)
%Definition du vecteur temps pour l'interpolation:    
    ind_v=find(liste_j_v==temps_j_adcp(i)); % indices de "date2" (vid�o) correspondantes au day i
    date_maxvid=max(temps_Hs(ind_v)); % Date max de date_adcp vid�o du day i
    date_minvid=min(temps_Hs(ind_v));% Date min de "date2" (vid�o) du day i
 
    ind_d=find(liste_j_adcp==temps_j_adcp(i)); % indices de "date" (ADCP) correspondantes au day i
    date_test=date_adcp(ind_d); % Dates ADCP du day i
    
    ind_d1=find(date_test>=date_minvid&date_test<=date_maxvid); % Indices
    % ADCP du day i correspondants � la p�riode de fonctionnement de la
    % cam�ra (la camera ne fonctionne pas la nuit)
    
    date_int_j=date_adcp(ind_d(ind_d1)); % Dates ADCP du day i pendant la p�riode
    % de fonctionnement de la cam�ra
    
    date_int=[date_int date_int_j]; % Vecteur contenant toutes les Dates ADCP du
    % day i pendant la p�riode de fonctionnement de la cam�ra
    
%Interpolation pour Hs:
    Hs_v_j=interp1(temps_Hs(ind_v),Hs(ind_v),date_int_j); % Hs vid�o interpol�s
    % sur les temps ADCP durant le fonctionnement de la camera    
    Hs_ADCP=[Hs_ADCP;Hs_adcp(ind_d(ind_d1))]; % Hs ADCP correspondants aux
    % temps ADCP durant le fonctionnement de la camera
    Hs_v=[Hs_v Hs_v_j];
end

%Calibration Tm
Tm_v=[];
Tp_ADCP=[];
date_int=[];

liste_j_v=str2num(datestr(temps_Tm,'yyyymmdd'));
temps_j_v=unique(liste_j_v);

for i=1:length(temps_j_adcp)
%Definition du vecteur temps pour l'interpolation:    
    ind_v=find(liste_j_v==temps_j_adcp(i));
    date_maxvid=max(temps_Tm(ind_v)); 
    date_minvid=min(temps_Tm(ind_v));
    ind_d=find(liste_j_adcp==temps_j_adcp(i));
    date_test=date_adcp(ind_d);
    ind_d1=find(date_test>=date_minvid&date_test<=date_maxvid);
    date_int_j=date_adcp(ind_d(ind_d1)); 
    date_int=[date_int date_int_j]; 

%Interpolation pour Tm:    
    Tm_v_j=interp1(temps_Tm(ind_v),Tm(ind_v),date_int_j); 
    Tp_ADCP=[Tp_ADCP;Tp_adcp(ind_d(ind_d1))]; 
    Tm_v=[Tm_v Tm_v_j];
     
end

%Calibration Dir
Dir_v_int=[];
Dir_ADCP=[];
date_int=[];

liste_j_v=str2num(datestr(temps_Dir,'yyyymmdd'));
temps_j_v=unique(liste_j_v);

for i=1:length(temps_j_adcp)
%Definition du vecteur temps pour l'interpolation:    
    ind_v=find(liste_j_v==temps_j_adcp(i));
    date_maxvid=max(temps_Dir(ind_v)); 
    date_minvid=min(temps_Dir(ind_v));
    ind_d=find(liste_j_adcp==temps_j_adcp(i));
    date_test=date_adcp(ind_d);
    ind_d1=find(date_test>=date_minvid&date_test<=date_maxvid);
    date_int_j=date_adcp(ind_d(ind_d1)); 
    date_int=[date_int date_int_j]; 

%Interpolation pour Dir_v:
    Dir_v_j=interp1(temps_Dir(ind_v),Dir_v(ind_v),date_int_j); 
    Dir_ADCP=[Dir_ADCP;Dir_adcp(ind_d(ind_d1))]; 
    Dir_v_int=[Dir_v_int Dir_v_j];
     
end
 
 clear Tp;

%Objectif de la calibration: obtenir des donn�es de la vid�o ayant 
%la m�me moyenne et le m�me �cart type que celles de l'ADCP;
 
%Calcul des �carts types:
s1=nanstd(Hs_ADCP);
s2=nanstd(Hs_v);
s3=nanstd(Tp_ADCP);
s4=nanstd(Tm_v);
s5=nanstd(Dir_ADCP);
s6=nanstd(Dir_v_int);
 
%Variables interm�diaires
Hs_v2=(s1/s2).*Hs_v;
Tm_v2=(s3/s4).*Tm_v;
Dir_v2=(s5/s6).*Dir_v_int;

%D�finition des coefficients multiplicatifs pour obtenir calibrer l'�cart
%type de la video sur celui de l'ADCP
C1_Hs=round((s1/s2)*100)/100;
C1_Tm=round((s4/s3)*100)/100;
C1_Dir=round((s5/s6)*100)/100; 

%Calcul des nouvelles moyennes 
H1=nanmean(Hs_v2);
H2=nanmean(Hs_ADCP);
T1=nanmean(Tm_v);
T2=nanmean(Tp_ADCP);
D1=nanmean(Dir_v2);
D2=nanmean(Dir_ADCP);

%D�finition des coefficients permettant d'obtenir la m�me moyenne
C2_Tl=round((T2-T1)*10)/10;
C2_Hs=round((H2-H1)*10)/10;
C2_Dir=round((D2-D1)*10)/10;

%Calibration des donn�es vid�o:
Hs_cal=C1_Hs.*Hs_v+C2_Hs;
Tm_cal=C1_Tm.*Tm_v+C2_Tl;
Dir_cal=C1_Dir.*Dir_v_int+C2_Dir;


%  Hs_erms=round(rmse(Hs_cal,Hs_ADCP')*100)/100;
%  dir_erms=rmse(angi_vid,dir_interp);
%  Tm_erms=round(rmse(Tm_cal,Tp_ADCP')*100)/100;
% cor=corrcoef(angi_vid',dir_interp'); % Calcul de la correlation
% % entre les directions de houle de la video et celles de l'ADCP
% formatSpec = '    Root Mean Square Error : %d \n';
% formatSpec = '    Correlation : %d \n';
% sprintf(formatSpec,cor(1,2))


%FIGURES% 
% figure;
% subplot(3,1,1);
% plot(date_int,Hs_cal,'sk','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','k'); 
% hold on; 
% plot(date_adcp,Hs_adcp,'sr','LineWidth',2,'MarkerEdgeColor','r','MarkerFaceColor','r');
% set(gca,'XTick',date_adcp(1):1:date_adcp(end));
% set(gca,'XTickLabel',datestr(date_adcp(1):1:date_adcp(end),'dd mmm'),'fontsize',12);
% legend('video','ADCP');
% ylabel('hauteur significative des vagues');
% title({['validation Hs-vid�o'];
%     %[' RMSE ',num2str(Hs_erms),'m']})
% ylabel('Hauteur (m)','FontSize',12);
% hold off;
% 
% subplot(3,1,2);
% plot(date_int,Tm_cal,'sk','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','k'); 
% hold on ; 
% plot(date_adcp,Tp_adcp,'sr','LineWidth',2,'LineWidth',2,'MarkerEdgeColor','r','MarkerFaceColor','r'); 
% hold off
% set(gca,'XTick',date_adcp(1):1:date_adcp(end));
% set(gca,'XTickLabel',datestr(date_adcp(1):1:date_adcp(end),'dd mmm'),'fontsize',12);
% legend('video','ADCP');
% ylabel('P�riode(s)','FontSize',12);
% title({['validation Tm-vid�o'];%[' RMSE ',num2str(Tm_erms),'s']})
% 
% 
% subplot(3,1,3);
% plot(date_int,Dir_cal,'sk','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','k'); ; 
% hold on; 
% plot(date_adcp,Dir_adcp,'sr','LineWidth',2,'LineWidth',2,'MarkerEdgeColor','r','MarkerFaceColor','r'); 
% hold off
% set(gca,'XTick',date_adcp(1):1:date_adcp(end));
% set(gca,'XTickLabel',datestr(date_adcp(1):1:date_adcp(end),'dd mmm'),'fontsize',12);
% xlabel('month/day/Mars-2014','FontSize',12);
% ylabel('Incidence des vagues (�)','FontSize',12) 
% title('validation Direction de la houle','FontSize',12)
% legend('video','ADCP')
% 
% 
% hgexport(gcf, 'figure1.jpg', hgexport('factorystyle'), 'Format', 'jpeg');;

end
