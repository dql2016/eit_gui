function eit_aaa = eit_simulation()

imdl= mk_common_model('d2d1c',16);
img= mk_image(imdl);

vh = fwd_solve(img); %Homogeneous
select_fcn = inline('(x-0.4).^2+(y-0.0).^2<0.4^2','x','y','z');
img.elem_data = 1 + elem_select(img.fwd_model, select_fcn);
vi = fwd_solve(img); %inHmogeneous

subplot(3,2,1);
show_fem(img);

subplot(3,2,2);
show_fem(img);
plot([vh.meas, vi.meas]); 

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
end
