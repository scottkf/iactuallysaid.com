exports.routes = (map) ->
  map.resources 'images'

  map.get '/rss', 'images#rss'

  map.get '/images/new/:type', 'images#new', {as: 'new_image'}
  map.post '/images/:type.:format?', 'images#create', {as: 'images'}

  map.post '/images/:id/hateit.:format?', 'images#hateit'
  map.post '/images/:id/loveit.:format?', 'images#loveit'
  map.get '/images/sort/:type', 'images#index'

  map.get '/users/:user_id', 'images#byuser'
  map.get '/users/:user_id/page/:page', 'images#byuser'
    
  map.get '/images/page/:page', 'images#index'
  map.get '/page/:page', 'images#index', {as: 'page'}

  map.get '/', 'images#index', {as: 'root'}
  map.get '/privacy', 'pages#privacy'
  map.get '/about', 'pages#about'
  map.get '/markdown', 'pages#markdown'
