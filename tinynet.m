function res = tinynet(net, x, dzdy)
doder = (nargin >= 3) ;

n = numel(net.layers) ;

res = struct(...
  'x', cell(1,n+1), ...
  'dzdx', cell(1,n+1), ...
  'dzdw', cell(1,n+1), ...
  'time', num2cell(zeros(1,n+1)), ...
  'backwardTime', num2cell(zeros(1,n+1))) ;
res(1).x = x ;

for i=1:n
  l = net.layers{i} ;
  res(i).time = tic ;
  switch l.type
    case 'conv'
      res(i+1).x = gconv(res(i).x, l.w) ;      
    case 'pool'
      res(i+1).x = gpool(res(i).x, l.pool) ;
    case 'normalize'    
      res(i+1).x = gnormalize(res(i).x, l.param) ;
    case 'fully'
      res(i+1).x = gfully(res(i).x, l.w) ;
    case 'softmax'
      res(i+1).x = gsoftmax(res(i).x) ;
    case 'loss'
      res(i+1).x = gloss(res(i).x, l.class) ;
    case 'vec'
      res(i+1).x = gvec(res(i).x) ;
    case 'relu'
      res(i+1).x = grelu(res(i).x) ;
    otherwise
      error('Unknown layer type %s', l.type);
  end
  res(i).time = toc(res(i).time) ;
end

if doder
  res(n+1).dzdx = dzdy ;
  for i=n:-1:1
    l = net.layers{i} ;
    res(i).backwardTime = tic ;
    switch l.type
      case 'conv'
        [res(i).dzdw, res(i).dzdx] = gconv(res(i).x, l.w, res(i+1).dzdx) ;
      case 'pool'
        res(i).dzdx = gpool(res(i).x, l.pool, res(i+1).dzdx) ;
      case 'normalize'
        res(i).dzdx = gnormalize(res(i).x, l.param, res(i+1).dzdx) ;
      case 'fully'
        [res(i).dzdx, res(i).dzdw] = gfully(res(i).x, l.w, res(i+1).dzdx) ;
      case 'softmax'
        res(i).dzdx = gsoftmax(res(i).x, res(i+1).dzdx) ;
      case 'loss'
        res(i).dzdx = gloss(res(i).x, l.class, res(i+1).dzdx) ;
      case 'vec'
        res(i).dzdx = gvec(res(i).x, res(i+1).dzdx) ;
      case 'relu'
        res(i).dzdx = grelu(res(i).x, res(i+1).dzdx) ;
    end
    res(i).backwardTime = toc(res(i).backwardTime) ;

  end
end