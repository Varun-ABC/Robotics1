%
% invkin_iterJ_kth.m
%
% inverse kinematics using Jacobian iteration (3D)
%

function robot = invkin_iterJ_kth(robot,N,alpha , el)
    % N is number of iterations
    % alpha is step size
    
    % define unit z vector
    % target (R,p)
    des_pose = robot.T;
    Rd = robot.T(1:3,1:3);
    pTd = robot.T(1:3,4);

    % set up storage space
    q0=robot.q;
    n=length(q0); % # of joints
    q=zeros(n,N+1);
    q(:,1)=q0; % output joint displacements
    pT = zeros(3,N+1); % output p
    qT = zeros(3,N+1); % output quaternion
    % first iteration
    robot.q = q(:,1);
    robot = fwdkiniter(robot);
    % iterative update
    for i=1:N
        % forward kinematics
        
        R0t = robot.T(1:3,1:3);
        qT(:,i) = R2kth(R0t * Rd')
        %  = s(:,1)
        pT(:,i)=robot.T(1:3,4);
        % task space error: angular error and position error
        % w = [50;50;50;1;1;1];
        dX = [2 * qT(:,i); ...
            (pT(:,i) - pTd)] .*robot.Weights;
        % Jacobian update - note 10 times the gain for orientation
        % qq = q(:,i)-alpha*pinv(robot.J) * dX;
%         if norm(dX, "fro") < 5e-4 && boo == true
%             alpha = .1;
%             % fprintf("hit")
%             boo = false; 
%         end
        qq = q(:,i) - alpha * robot.J' * inv(robot.J*robot.J' + el * eye(6))*dX;
        q(:,i+1) = (qq>pi).*(-2*pi+qq) + (qq<-pi).*(2*pi+qq) + (qq<pi).*(qq>-pi).*qq;
        % q(:,i+1) = wrapToPi(qq);
        robot.q = q(:,i+1);
        robot = fwdkiniter(robot);
        if norm(des_pose - robot.T,'fro') < 1e-6
            fprintf("hit")
            break
        end
    end
    % final iteration
    robot.q = q(:,i+1); 
end
