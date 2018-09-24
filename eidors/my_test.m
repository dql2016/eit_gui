
clear;
clc;
% Step 1: Get data
load phantom_16elec_1planeA.mat;
% The key thing you need to know about your data are:
% The medium shape and the electrode positions 
% In this case, the measurements were made from a cylindrical tank with 16 electrodes in a plane.
% The stimulation/measurement protocol 
% In this case, the measurements were made using the adjacent stimulation and measurement (the Sheffield protocol)

% Step 2a: Create an inverse model (imdl) from the template
imdl = mk_common_model('a2d0c',16);
subplot(3,3,1);
show_fem(imdl.fwd_model,[0,1]);
% See the documentation for mk_common_model. It has lots of options. The function provides a circular model with adjacent stimulation patterns. If this is not what you want, it must be changed.

% Step 2b: Create a forward model (fmdl) that matches the shape / electrodes
% This step is not required, if mk_common_model provides you with the shape you need. Here, as an example, we create a circular tank, but also we can use many other functions.
n_rings = 12;
n_electrodes = 16;
three_d_layers = []; % no 3D
fmdl = mk_circ_tank( n_rings , three_d_layers, n_electrodes);
subplot(3,3,2);
show_fem(fmdl,[0,1]);
% then assign the fields in fmdl to imdl.fwd_model

% Step 2c: Create a forward model (fmdl) that matches the stimulation / measurement protocol
% Often the function mk_stim_patterns can do what you need; if not, you will need to:
options = {'no_meas_current','no_rotate_meas'};
[stim, meas_select] = mk_stim_patterns(16,1,'{ad}','{ad}', options,1);
imdl.fwd_model.stimulation = stim;
imdl.fwd_model.meas_select = meas_select;

subplot(3,3,3);
show_fem(imdl.fwd_model,[0,1]);

subplot(3,3,4);
show_fem(imdl.fwd_model,[1,1,1]);

% If mk_stim_patterns doesn't provide what you need, then you will need to use a function like stim_meas_list.

% Step 2d: Reconstruct the image (img) using inv_solve
data_homg = vvRef;
data_objs = vvAvg2; % from your file
img = inv_solve(imdl, data_homg, data_objs);

subplot(3,3,5);
show_fem(img.fwd_model,[1,1,1])

% Step 2e: Display the image
subplot(3,3,6);
out_img=  show_slices(img);

subplot(3,3,7);
show_fem(img,[1,1,1])
subplot(3,3,8);
show_fem(img,[0,1,0])

% tests
subplot(3,3,9);
show_current(img);

vh= fwd_solve(img);
vi= fwd_solve(img);
plot([vh.meas, vi.meas]);

% hold on;
% pp = fwd_model_parameters(fmdl);
%  image(out_img);
% img.calc_colours.ref_level = 1 %  centre of the colour scale
% img.calc_colours.clim      = 20 %  max diff from ref_level
% img.eidors_colourbar.tick_vals = [-20:20]/1;
% eidors_colourbar(img);
% img2=mk_image(imdl);
%  print_convert pc02.png
%  hold on;
%  show_fem(img,[1,1,1])
% vh = fwd_solve(img);
%  hold on;
% show_stim_meas_pattern(fmdl,'y',0,1);

% inv_mdl= select_imdl( imdl, {'Basic GN abs'} )
% [img_data, n_images]=get_img_data(img);
% J = calc_jacobian( img );
% num_elecs = num_elecs(imdl);
% num_elems = num_elems(imdl);
% n_nodes = num_nodes(imdl);
% [pass, err_str] = valid_inv_model(imdl);
% dva = calc_difference_data( data_homg, data_objs, fmdl);
% RtR_prior = calc_RtR_prior( imdl );

% Forward solvers $Id: forward_solvers01.m 3790 2013-04-04 15:41:27Z aadler $

% 2D Model
imdl= mk_common_model('d2d1c',19);

% Create an homogeneous image
img_1 = mk_image(imdl);
h1= subplot(221);
show_fem(img_1);

% Add a circular object at 0.2, 0.5
% Calculate element membership in object
img_2 = img_1;
select_fcn = inline('(x-0.2).^2+(y-0.5).^2<0.1^2','x','y','z');
img_2.elem_data = 1 + elem_select(img_2.fwd_model, select_fcn);

h2= subplot(222);
show_fem(img_2);

img_2.calc_colours.cb_shrink_move = [.3,.8,-0.02];
common_colourbar([h1,h2],img_2);

print_convert forward_solvers01a.png








