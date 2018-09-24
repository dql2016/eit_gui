
clear;
clc;

imb=  mk_common_model('c2c',16);
e= size(imb.fwd_model.elems,1);%total elements,num_elems = num_elems(imb);
bkgnd= 1;
 
% Solve Homogeneous model
img= mk_image(imb.fwd_model, bkgnd);
vh= fwd_solve( img );

subplot(3,2,1);
show_fem(img,[1 1 1]);
print_convert('tutorial120a.png', '-density 60')

% Add Two triangular elements
img.elem_data([25,37,49:50,65:66,81:83,101:103,121:124])=bkgnd * 2;
img.elem_data([95,98:100,79,80,76,63,64,60,48,45,36,33,22])=bkgnd * 2;
vi= fwd_solve( img );

subplot(3,2,2);
show_fem(img);
print_convert('tutorial120a.png', '-density 60')

% Add -12dB SNR
vi_n= vi; 
nampl= std(vi.meas - vh.meas)*10^(-18/20);
vi_n.meas = vi.meas + nampl *randn(size(vi.meas));

% plot voltage data
subplot(3,2,3);
plot(vh.meas,'blue');
subplot(3,2,4);
plot(vi.meas,'red');

% Create Inverse Model
inv2d= eidors_obj('inv_model', 'EIT inverse');
inv2d.reconst_type= 'difference';
inv2d.jacobian_bkgnd.value= 1;

% This is not an inverse crime; inv_mdl != fwd_mdl
imb=  mk_common_model('b2c',16);
inv2d.fwd_model= imb.fwd_model;

% Guass-Newton solvers
inv2d.solve=       @inv_solve_diff_GN_one_step;
% Tikhonov prior
inv2d.hyperparameter.value = .03;
inv2d.RtR_prior=   @prior_tikhonov;
imgr(1)= inv_solve( inv2d, vh, vi);
imgn(1)= inv_solve( inv2d, vh, vi_n);

% Output image
imgn(1).calc_colours.npoints= 128;
imgr(1).calc_colours.npoints= 128;

subplot(3,2,5);
show_slices(imgr, [inf,inf,0,1,1]);
print_convert tutorial120b.png;

subplot(3,2,6);
show_slices(imgn, [inf,inf,0,1,1]);
print_convert tutorial120c.png;


clf;
show_fem(img,[1 1 1]);

