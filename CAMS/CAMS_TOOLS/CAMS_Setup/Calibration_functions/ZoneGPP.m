%ZoneAlg.m
%Modif du 20100316

function ZoneGPP(ImageTaller,res)

A=imread(ImageTaller); 

% R�solution de la zone
resx = res % ~=perpendiculaire � la c�te 
resy = res % ~=parrall�le � la c�te


figure(1)
clf
image(A)
set(gcf,'Color','w')


% R�cup�ration des points de la zone
[a,b]=ginput;

ni=size(A,1)
nj=size(A,2)

% Stockage des coordonn�es des pixels de l'image
for i=1:resx:ni
  x(i,1:resy:nj)=i;
  y(i,1:resy:nj)=1:resy:nj;
end

% Vectorisation de coordonn�es de l'images
x=reshape(x,1,[]);
y=reshape(y,1,[]);

% R�cup�ration des pixels de la zone
ind = inpolygon(x,y,b,a);
indo = find(ind==1);
x1 = x(indo);
y1 = y(indo);

% Affichage de la zone sur l'image
hold on
a(length(b)+1)=a(1);
b(length(b)+1)=b(1);
FF=fill(a,b,'r');
set(FF,'FaceAlpha',0.25)
hold off

% Stockage de la zone dans un fichier
% save([Rchemin 'ZoneTV_C' num2str(cam)],'resx','resy','x1','y1','indo');

save(['./ZoneGPP'],'resx','resy','x1','y1','indo');
disp(['Nombre de points dans la zone : ',num2str(length(indo))])
