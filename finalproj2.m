%% floor: model one car on a single-lane road
% there is nothing for the car to respond to, so it is going a constant
% speed, although speed is already being governed by rules that the driver
% will follow in the presence of other cars. when the car reaches the end
% of the finite road, a new car is launched at the start of the road, so
% that density of cars is constant over time.

%% simulation constants
dt = 0.25;
% simulation length
simLength = 100;
% numIterations
numIterations = simLength / dt;
% initialize time
t = 0;

% car struct definition 
car = struct('index',[],'desiredSpeed',[],'frustration',[],'acceleration',[],'position',[],'speed',[],'time',[]);

% model constants
decelerationConstant = -.5;
minFollowingDistance = 2;
roadLength = 100;

% model anonymous functions

% simulation loop
for n=2:(numIterations+1)
    t(n) = t(n-1) + dt;
    if n==2
        index=1;
        % initialize the first car
        car(index) = initializeCar(index,t(n));
        % current position of car 1 is: index 1, position, lane 1.
        currentPositions = [index car(index).position(end) 1];
        % currentPositions(currentPositions(1,:)==index,2) gets position 
        % of car with index index.
    elseif (car(index).position(end)>= roadLength)
        index=index+1;    
        car(index) = initializeCar(index, t(n));
    end
    car(index).time(end+1) = t(n);
    car(index).speed(end+1) = car(index).speed(end) + car(index).acceleration * dt;
    car(index).position(end+1) = car(index).position(end) + car(index).speed(end) * dt;
    car(index).frustration(end+1) = ...
        (car(index).speed(end)<car(index).desiredSpeed)* car(index).frustration(end);
    car(index).acceleration = calcAcceleration(car(index).frustration(end), ...
        car(index).speed(end),car(index).desiredSpeed, followingDistance);
    % set the current position of the car in the currentPositions matrix
    % equal to the current position of the car.
    currentPositions(currentPositions(1,:)==index,2)=car(index).position(end);
end

%% visualize
road = 0:1:roadLength;
toproad(1:roadLength+1) = 4;
bottomroad(1:roadLength+1) = 2;
midroad(1:roadLength+1) = 3;

%%
b = cell(index,1);
nImages=0;
for i=1:index
    b{i} = car(i).position;
    nImages = nImages + length(b{i});
end
%%
fig = figure;
for cr = 1:length(b)
    for idx = 1:length(b{cr})
        hold on;
        road1=plot(road,toproad,'black');
        road2=plot(road,bottomroad,'black');
        carposn=scatter(b{cr}(idx), 3,100,'filled','s','blue');
        hold off;
        ylim([-5 11]);
        xlim([0 roadLength]);
        drawnow
        frame = getframe(fig);
        delete(carposn);
        im{idx} = frame2im(frame);
    end
end
close;
%%
filename = 'testAnimated.gif'; % Specify the output file name
for idx = 1:nImages
    [A,map] = rgb2ind(im{idx},256);
    if idx == 1
        imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',.5);
    else
        imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',.05);
    end
end
