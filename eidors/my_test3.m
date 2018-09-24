
% step1:Build a good FEM of the phantom

Nel= 32; %Number of elecs
Zc = .0001; % Contact impedance
curr = 20; % applied current mA

th= linspace(0,360,Nel+1)';th(1)=[];
els = [90-th]*[1,0]; % [radius (clockwise), z=0]
elec_sz = 1/6;
fmdl= ng_mk_cyl_models([0,1,0.1],els,[elec_sz,0,0.03]);

for i=1:Nel
   fmdl.electrode(i).z_contact= Zc;
end

% Trig stim patterns
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

subplot(3,3,1);
show_fem(fmdl,[0,1])
print_convert('rpi_data01a.png','-density 60');


% step2:Load and preprocess data
load Rensselaer_EIT_Phantom;
vh = real(ACT2006_homog);
vi = real(ACT2000_phant);

if 1
% Preprocessing data. We ensure that each voltage sequence sums to zero
  for i=0:30
    idx = 32*i + (1:32);
    vh(idx) = vh(idx) - mean(vh(idx));
    vi(idx) = vi(idx) - mean(vi(idx));
  end
end


% step3:Difference imaging
% one:Using a very simple model
% simple inverse model -> replace fields to match this model
imdl = mk_common_model('b2c2',32);
imdl.fwd_model = mdl_normalize(imdl.fwd_model, 0);

imdl.fwd_model.electrode = imdl.fwd_model.electrode([8:-1:1, 32:-1:9]);

imdl.fwd_model = rmfield(imdl.fwd_model,'meas_select');
imdl.fwd_model.stimulation = stim;
imdl.hyperparameter.value = 1.00;

% Reconstruct image
img = inv_solve(imdl, vh, vi);
img.calc_colours.cb_shrink_move = [0.5,0.8,0.02];
img.calc_colours.ref_level = 0;

subplot(3,3,2);
show_fem(img,[1,1]); axis off; axis image
print_convert('rpi_data02a.png','-density 60');

% second:Using a the accurate electrode model
imdl.fwd_model = fmdl; 
img = inv_solve(imdl , vh, vi);
img.calc_colours.cb_shrink_move = [0.5,0.8,0.02];
img.calc_colours.ref_level = 0;

subplot(3,3,3);
show_fem(img,[1,1]); axis off; axis image
print_convert('rpi_data03a.png','-density 60');

% step4:Estimating actual conductivities
% In order to estimate the actual conductivity values, we need to scale for the applied voltage, tank size (in 3D) and background conductivity
imdl.fwd_model.nodes= imdl.fwd_model.nodes*15; % 30 cm diameter

% Estimate the background conductivity
imgs = mk_image(imdl);
vs = fwd_solve(imgs); vs = vs.meas;

pf = polyfit(vh,vs,1);

imdl.jacobian_bkgnd.value = pf(1)*imdl.jacobian_bkgnd.value;
imdl.hyperparameter.value = imdl.hyperparameter.value/pf(1)^2;

img = inv_solve(imdl, vh, vi);
img.calc_colours.cb_shrink_move = [0.5,0.8,0.02];
img.calc_colours.ref_level = 0;

subplot(3,3,4);
show_fem(img,[1,1]); 
axis off; 
axis image
print_convert('rpi_data04a.png','-density 60');

% This can even be a quick way to use a difference solver for absolute imaging
imgs = mk_image(imdl);
vs = fwd_solve(imgs); vs = vs.meas;
imdl.hyperparameter.value = 1.00;
img = inv_solve(imdl, vs, vi);
img.elem_data = pf(1) + img.elem_data*0.5;
img.calc_colours.cb_shrink_move = [0.5,0.8,0.02];

subplot(3,3,5);
show_fem(img,[1,1]); 
axis off;
axis image
print_convert('rpi_data05a.png','-density 60');



vh= fwd_solve(img);
vi= fwd_solve(img);
subplot(3,3,9);
plot([vh.meas, vi.meas]);