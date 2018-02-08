clearvars
% close all
set(0,'DefaultFigureWindowStyle','docked')
global C
C.q_0 = 1.60217653e-19;             % electron charge
C.hb = 1.054571596e-34;             % Dirac constant
C.h = C.hb * 2 * pi;                    % Planck constant
C.m_0 = 9.10938215e-31;             % electron mass
C.kb = 1.3806504e-23;               % Boltzmann constant
C.eps_0 = 8.854187817e-12;          % vacuum permittivity
C.mu_0 = 1.2566370614e-6;           % vacuum permeability
C.c = 299792458;                    % speed of light


% -i hb dP/dt = - hb^2/2m dP^2/dx^2 + V(x)P
% -i hb (P - Pp)/dt = G P
% BE:
%   (P - Pp) =  i dt/hb G P
%   (1-i dt/hb G)*P =   Pp
%   H*P =   Pp
%   P = inv(H)*Pp


% vw = [0,90];
vw = [10,30];

nx = 501;
l = 10e-9;
x =linspace(0, l, nx);

d = x(2) - x(1);

w = 1.0e-9;
ny = round(w/d)+1;
% ny = 2;
w = (ny-1)*d;
y =linspace(0, w, ny);

nn = nx*ny;

% bcs = '0000';
bcs = '00PP';

% pot = @Pot_const2D;
% paras = [0 * C.q_0];

% pot = @Pot_well2D;
% paras = [l/4,l/2,w/4,w/2,175*C.q_0,0*C.q_0];

% pot = @Pot_Dwell;
% paras = [l/16,l/4,l/2,75*C.q_0,0*C.q_0];

pot = @Pot_para2D;
paras = [100/(l^2)*C.q_0,l/2,w/2];

d2 = d^2;
B = (C.hb^2) / (2 * C.m_0);
G = sparse(nx*ny,nx*ny);

% Cap = CAPFct(x, [len * 0.15, 1]);
Cap(1:nx,1:ny) = 0;

nSteps = 1000;
Tmax = 50e-15;
Tmax0 = 1e-13;

K0 = C.m_0 * (l / Tmax0) / C.hb * 20; % P = hb*k k = mv/hb;
K0 = 0;
[Ym,Xm] = meshgrid(y,x);

P0map(1:nx,1:ny) = exp(1i * K0 * Xm).*...
    exp(-((Xm - l/4).^2/(l/50)^2)).*...
    exp(-((Ym - w/2).^2)/((w/4)^2));

for i = 1:nx
    for j = 1:ny
        n = i + (j - 1) * nx;
        
        nxm = i - 1 + (j-1)*nx;
        nxp = i + 1 + (j-1)*nx;
        nym = i + (j-1-1)*nx;
        nyp = i + (j-1+1)*nx;
        
        Poten(i,j) = pot(x(i), y(j), paras) + Cap(i,j);
        
        if i == 1
            if bcs(1) == '0'
                G(n, n) = B / d2;
            elseif j == 1
                G(n, n) = B * 2 / d2 + Poten(i,j);
                G(n,nxp) = -B / d2;
                G(n,nyp) = -B / d2;
            elseif j == ny
                G(n, n) = B * 2 / d2 + Poten(i,j);
                G(n,nxp) = -B / d2;
                G(n,nym) = -B / d2;
            else
                G(n, n) = B * 3 / d2 + Poten(i,j);
                G(n,nxp) = -B / d2;
                G(n,nym) = -B / d2;
                G(n,nyp) = -B / d2;
            end
        elseif i == nx
            if bcs(2) == '0'
                G(n, n) = B / d2;
            elseif j == 1
                G(n, n) = B * 2 / d2 + Poten(i,j);
                G(n,nxm) = -B / d2;
                G(n,nyp) = -B / d2;
            elseif j == ny
                G(n, n) = B * 2 / d2 + Poten(i,j);
                G(n,nxm) = -B / d2;
                G(n,nym) = -B / d2;
            else
                G(n, n) = B * 3 / d2 + Poten(i,j);
                G(n,nxm) = -B / d2;
                G(n,nym) = -B / d2;
                G(n,nyp) = -B / d2;
            end
        elseif j == 1
            if bcs(3) == '0'
                G(n, n) = B / d2;
            else
                G(n, n) = B * 3 / d2 + Poten(i,j);
                G(n,nxm) = -B / d2;
                G(n,nxp) = -B / d2;
                G(n,nyp) = -B / d2;
            end
        elseif j == ny
            if bcs(4) == '0'
                G(n, n) = B / d2;
            else
                G(n, n) = B * 3 / d2 + Poten(i,j);
                G(n,nxm) = -B / d2;
                G(n,nxp) = -B / d2;
                G(n,nym) = -B / d2;                
            end
        else
            G(n, n) = B * 4 / d2 + Poten(i,j);
            G(n,nxm) = -B / d2;
            G(n,nxp) = -B / d2;
            G(n,nym) = -B / d2;
            G(n,nyp) = -B / d2;
        end
        
        P0(n) = P0map(i,j);
    end
end

Pp = P0.';

% [V,D] = eig(G);
%
% [Ds,Pr]=sort(diag(D));
% D=D(Pr,Pr);
% V=V(:,Pr);
%
% subplot(2,1,1), plot(x,Poten/C.q_0);
% subplot(2,1,2), plot(x,V(:,1:5))
%
% figure

% Gi = inv(G);

subplot(3, 1, 1), surf(x, y, real(Poten.' / C.q_0),'linestyle','none');
view(vw)
% hold
% subplot(3, 1, 1), plot(x, imag(Poten / C.q_0), 'r');

maxP0 = max(max(abs(P0map)));
subplot(3, 1, 2), surf(x,y, real(P0map).','linestyle','none');
view(vw)
% hold on
% subplot(3, 1, 2), plot(x, real(P0map(:,1)), 'r');hold on
% subplot(3, 1, 2), plot(x, imag(P0map(:,1)), 'b');
% subplot(3, 1, 2), plot(x, abs(P0map(:,1)), 'k');
% zlim([-1,1]);
% hold off



% f = getframe;
% [im,map] = rgb2ind(f.cdata, 256, 'nodither');
% im(1, 1, 1, 20) = 0;
%
% set(gca,'nextplot','replacechildren','visible','off')

% Norm=zeros(1, nSteps);
% Norm(1) = sum(abs(Pp).^2);
% subplot(3, 1, 3), plot(Norm, 'b');
% axis([0 nSteps 0 Norm(1)*1.1])

dt = Tmax / nSteps;

H = speye(nn) - 1i * dt / C.hb * G;
Hp = speye(nn) + 1i * dt / C.hb * G;

[l,u] = lu(Hp);

for j = 1:nSteps
    %      P = u\(l\(Pp'));
    P = u\(l\(H*Pp));
    
    
    Pmap = reshape(P,[nx,ny]);
    
%     subplot(3, 1, 2), plot(x, real(Pmap(:,1)), 'r');hold on
%     subplot(3, 1, 2), plot(x, imag(Pmap(:,1)), 'b');
%     subplot(3, 1, 2), plot(x, abs(Pmap(:,1)), 'k');
%     zlim([-1,1]);
%     hold off

    subplot(3, 1, 3), surf(x,y, real(Pmap).','linestyle','none');
    view(vw)
    zlim([-1,1]);
    
    pause(0.05)
    
    Pp = P;
end

% imwrite(im, map, 'imagefile.gif', 'DelayTime', 0, 'LoopCount', inf);
%
% subplot(3, 1, 2), plot(x,V(:,1:5))
