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

% Calculate a stimulation pattern
stim = mk_stim_patterns(19,1,[0,1],[0,1],{},1);

% Solve all voltage patterns
img_2.fwd_model.stimulation = stim;
img_2.fwd_solve.get_all_meas = 1;
vh = fwd_solve(img_2);

% Show first stim pattern
h1= subplot(221);
img_v = rmfield(img_2, 'elem_data');
img_v.node_data = vh.volt(:,1);
show_fem(img_v);

% Show 7th stim pattern
h2= subplot(222);
img_v = rmfield(img_2, 'elem_data');
img_v.node_data = vh.volt(:,7);
show_fem(img_v);

img_v.calc_colours.cb_shrink_move = [0.3,0.8,-0.02];
common_colourbar([h1,h2],img_v);
print_convert forward_solvers02a.png

vh= fwd_solve(img);
vi= fwd_solve(img);
plot([vh.meas, vi.meas]);