clear;
clc;
% step1:forward problem
Nel= 16; %Number of elecs
Zc = 0.0001; % Contact impedance
curr = 1; % applied current mA
imdl= mk_common_model('b2c',Nel);

for i=1:Nel
   imdl.electrode(i).z_contact= Zc;
end
th= linspace(0,2*pi,Nel+1)';th(1)=[];
for i=1:Nel-1;
   if i<=Nel/2;
      stim(i).stim_pattern = curr*cos(th*i);
   else;
      stim(i).stim_pattern = curr*sin(th*( i - Nel/2 ));
   end
   stim(i).meas_pattern= eye(Nel)-ones(Nel)/Nel;
   stim(i).stimulation = 'Amp';
end

fmdl.stimulation = stim;

img= mk_image(imdl);

vh = fwd_solve(img); %Homogeneous

%set inHmogeneous
select_fcn = inline('(x-0.4).^2+(y-0.0).^2<0.4^2','x','y','z');
img.elem_data = 1 + elem_select(img.fwd_model, select_fcn);
vi = fwd_solve(img); 

subplot(3,2,1);
show_fem(img);

subplot(3,2,2);
show_fem(img);
plot([vh.meas, vi.meas]); 

% step2:inverse problem

% Reconstructing onto elements
imdl1= mk_common_model('a2c0',16);
imdl1.RtR_prior = @prior_laplace;
imdl1.hyperparameter.value = 0.1;

img1 = inv_solve(imdl1, vh, vi);
subplot(3,2,3);
show_fem(img1);

% Fine model
imdl2= mk_common_model('c2c0',16);
imdl2.RtR_prior = @prior_laplace;
imdl2.hyperparameter.value = 0.1;

img2 = inv_solve(imdl2, vh, vi);
subplot(3,2,4);
show_fem(img2);

% Reconstructing onto nodes
imdl1= mk_common_model('a2c0',16);
imdl1.solve = @nodal_solve;
imdl1.RtR_prior = @prior_laplace;
imdl1.hyperparameter.value = 0.1;

img1 = inv_solve(imdl1, vh, vi);
subplot(3,2,5);
show_fem(img1);

% Fine model
imdl2= mk_common_model('c2c0',16);
imdl2.solve = @nodal_solve;
imdl2.RtR_prior = @prior_laplace;
imdl2.hyperparameter.value = 0.1;

img2 = inv_solve(imdl2, vh, vi);
subplot(3,2,6);
show_fem(img2);
