function [w] = main() 

% Question 1
pts = zeros(8, 3);
pts(1,:) = [-1 -1 -1];
pts(2,:) = [1 -1 -1];
pts(3,:) = [1 1 -1];
pts(4,:) = [-1 1 -1];
pts(5,:) = [-1 -1 1];
pts(6,:) = [1 -1 1];
pts(7,:) = [1 1 1];
pts(8,:) = [-1 1 1];


% Question 2
rotated_angle = (-30/180) * pi;
rotated_quat = angle_to_quat(rotated_angle, 0, 1, 0);
cam_pos = zeros(4, 3);
cam_pos(1,:) = [0 0 -5];
disp('camera location 1');
disp(cam_pos(1,:));
for i = 2 : 4
    cam_pos(i, :) = rotatePoint(cam_pos(i-1, :), rotated_quat);
    disp(strcat('camera location ', num2str(i)));
    disp(cam_pos(i, :));
end

% Question 3

disp('using roll, pitch and yaw representation for rotation, the computed matrices are:');
pitch = 0;
yaw = (-30/180)*pi;
roll = 0;
rotation_mat = euler_angle_to_mat(pitch, yaw, roll);
rpymat_1 = eye(3);
rpymat_2 = rotation_mat * rpymat_1;
rpymat_3 = rotation_mat * rpymat_2;
rpymat_4 = rotation_mat * rpymat_3;
disp(rpymat_1);
disp(rpymat_2);
disp(rpymat_3);
disp(rpymat_4);

disp('using quaternion representation for rotation, the computed matrices are:');
rotated_angle = (-30/180)*pi;
rotated_quat = angle_to_quat(rotated_angle, 0, 1, 0);
rotation_mat = quat_to_matrix(rotated_quat);
quatmat_1 = eye(3);
quatmat_2 = rotation_mat * quatmat_1;
quatmat_3 = rotation_mat * quatmat_2;
quatmat_4 = rotation_mat * quatmat_3;
disp(quatmat_1);
disp(quatmat_2);
disp(quatmat_3);
disp(quatmat_4);

disp('the difference in camera orientation for these two kinds of computing orientation is: ');
disp('difference in first frame');
disp(quatmat_1 - rpymat_1);
disp('difference in second frame');
disp(quatmat_2 - rpymat_2);
disp('difference in third frame');
disp(quatmat_3 - rpymat_3);
disp('difference in fourth frame');
disp(quatmat_4 - rpymat_4);

% Question 4
nframes = 4;
npts = size(pts, 1);
U = zeros(nframes, npts);
V = zeros(nframes, npts);
u_0 = 0;
v_0 = 0;
b_u = 1;
b_v = 1;
k_u = 1;
k_v = 1;
f = 1;
orient_pos = cat(1, quatmat_1 ,cat(1, quatmat_2, cat(1, quatmat_3, quatmat_4)));

                          
    % Perspective projection model
for frame = 1 : nframes
    for pnt = 1 : npts
        s_p = pts(pnt,:);
        t_f = cam_pos(frame, :);
        i_f = orient_pos(3 * frame - 2, :);
        j_f = orient_pos(3 * frame - 1, :);
        k_f = orient_pos(3 * frame, :);
        U(frame, pnt) = f * ( ( (s_p - t_f)*i_f') / ( (s_p - t_f) * k_f') ) * b_u + u_0;
        V(frame, pnt) = f * (( (s_p - t_f)*j_f') / ( (s_p - t_f) * k_f') ) * b_v + v_0;
    end
end

perspective_projected_x = U;
perspective_projected_y = V;

plotProjection(nframes, npts, U, V, 'perspective_projection');
    
    % Orthographic projection model
for frame = 1 : nframes
    for pnt = 1 : npts
        s_p = pts(pnt,:);
        t_f = cam_pos(frame, :);
        i_f = orient_pos(3 * frame - 2, :);
        j_f = orient_pos(3 * frame - 1, :);
        k_f = orient_pos(3 * frame, :);
        U(frame, pnt) = (s_p - t_f)*i_f' * b_u + u_0;
        V(frame, pnt) = (s_p - t_f)*j_f'* b_v + v_0;
    end
end
plotProjection(nframes, npts, U, V, 'orthographic_projection');

% Question 5
mat = zeros(8, 9);
for i = 1 : 4
    u_p = pts(i, 1);
    v_p = pts(i, 2);
    u_c = perspective_projected_x(3, i);
    v_c = perspective_projected_y(3, i);
    mat(2*i - 1, :) = [u_p, v_p, 1, 0, 0, 0, -u_c*u_p, -u_c*v_p, -u_c]; 
    mat(2*i, :) = [0, 0, 0, u_p, v_p, 1, -v_c*u_p, -v_c*v_p, -v_c];
end

[U, S, T] = svd(mat);

disp('Since this is a 8 * 9 matrix(number of row < col) => The least eigenvalue is hidden in S, and it corresponds to the last column in T');
A = reshape(T(:,9) / T(9, 9), 3,3);
A = A';
disp('The homography matrix is');
disp(A);

% TESTING PURPOSE
b= [pts(1,1); pts(1,2); 1];
c=A*b;
disp('if A is the correct homography matrix, then the following two must ouput the same result');
disp(c(1,1) / c(2,1));
disp(perspective_projected_x(3, 1) / perspective_projected_y(3, 1));

end

function [w] = conjugate(q)
    w = [q(1) q(2) q(3) q(4)];
    % conjugate a quaternion
    w(2) = -q(2);
    w(3) = - q(3);
    w(4) = -q(4);
end

function [quat] = point_to_quat(point)
    quat = cat(2, [0], point);
end

function [point] = quat_to_point(quat)
    point = quat(2:4);
end

function [w] = angle_to_quat(angle, Wx, Wy, Wz)
    w = zeros(1, 4);
    w(1) = cos(angle/2);
    w(2) = sin(angle/2) * Wx;
    w(3) = sin(angle/2) * Wy;
    w(4) = sin(angle/2) * Wz;
end

function [result] = multiplyQuat(q1, q2)
    result = zeros(1, 4);
    result(1) = q1(1)*q2(1) - q1(2)*q2(2) - q1(3)*q2(3) - q1(4)*q2(4);
    result(2) = q1(1)*q2(2) + q1(2)*q2(1) + q1(3)*q2(4) - q1(4)*q2(3);
    result(3) = q1(1)*q2(3) - q1(2)*q2(4) + q1(3)*q2(1) + q1(4)*q2(2);
    result(4) = q1(1)*q2(4) + q1(2)*q2(3) - q1(3)*q2(2) + q1(4)*q2(1);
end

function [rotated_point] = rotatePoint(point, quat)
    % quat is q: the quaternion used for rotation
    rotated_point = quat_to_point(multiplyQuat(multiplyQuat(quat, point_to_quat(point)), conjugate(quat)));                        
end

function [mat] = quat_to_matrix(q)
    mat = zeros(3, 3);
    mat(1, 1) = q(1)*q(1) + q(2)*q(2) - q(3)*q(3)- q(4)*q(4);
    mat(1, 2) = 2*(q(2)*q(3) - q(1)*q(4));
    mat(1, 3) = 2*(q(2)*q(4) + q(1)*q(3));
    mat(2, 1) = 2*(q(2)*q(3) + q(1)*q(4));
    mat(2, 2) = q(1)*q(1) + q(3)*q(3) - q(2)*q(2) - q(4)*q(4);
    mat(2, 3) = 2*(q(3)*q(4) - q(1)*q(2));
    mat(3, 1) = 2*(q(2)*q(4) - q(1)*q(3));
    mat(3, 2) = 2*(q(3)*q(4) + q(1)*q(2));
    mat(3, 3) = q(1)*q(1) + q(4)*q(4) - q(2)*q(2) - q(3)*q(3);
end

function [mat] = euler_angle_to_mat(pitch, yaw, roll)
    w = pitch;
    o = yaw;
    k = roll;
    mat = zeros(3, 3);
    mat(1,1) = cos(k)*cos(o);
    mat(1, 2) = cos(k)*sin(o)*sin(w) - sin(k)*cos(w);
    mat(1, 3) = cos(k)*sin(o)*cos(w) + sin(k)*sin(w);
    mat(2, 1) = sin(k)*cos(o);
    mat(2, 2) = sin(k)*sin(o)*sin(w) + cos(k)*cos(w);
    mat(2, 3) = sin(k)*sin(o)*cos(w) - cos(k)*sin(w);
    mat(3, 1) = -sin(o);
    mat(3, 2) = cos(o)*sin(w);
    mat(3, 3) = cos(o)*cos(w);
end

function [] = plotProjection(nframes, npts, U, V, projection_model)
    figure;
    figH = figure;
    for fr = 1 : nframes
        subplot(2,2,fr),plot(U(fr,:), V(fr,:), '*');
        for p = 1 : npts
            text(U(fr,p)+0.02, V(fr,p)+0.02, num2str(p));
        end
    end
    figName = strcat(projection_model, '.jpg');
    print(figH,'-djpeg',figName);
end

