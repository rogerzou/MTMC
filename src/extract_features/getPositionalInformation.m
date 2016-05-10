function wrl_pos = getPositionalInformation(thisModel)

if isempty(thisModel), return; end

% obtain a matrix 
bb = cellfun(@(x) x.bb', thisModel, 'uniformoutput', false);
for i = 1 : numel(bb)
    if isempty(bb{i}), bb{i}=bb{i-1}; end
end
bb = [bb{:}]';
bb(:, [3 4]) = bb(:, [3 4]) - bb(:, [1 2]);
wrl_pos = cellfun(@(x) x.frame, thisModel)';
wrl_pos = [wrl_pos, bb];

% TODO should be changed to have ground plane information
