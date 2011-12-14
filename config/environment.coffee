express = require 'express'
mongooseAuth  = require 'mongoose-auth'
require './mongoose_oauth'

RedisStore = require('connect-redis')(express)

redisOpts = null;
if (process.env['REDISTOGO_URL'])
    url = require('url').parse(process.env['REDISTOGO_URL'])
    redisOpts =
        port: url.port,
        host: url.hostname,
        pass: url.auth.split(':')[1]
else
  redisOpts = {}

amazon = require './amazon'
session_key = require './session_key'
app.configure ->
  cwd = process.cwd()
  form = require(cwd + '/vendor/connect-form-sync/lib/connect-form')
  app.set 'views', cwd + '/app/views'
  app.set 'view engine', 'jade'
  app.enable 'coffee'

  result = (app.settings.env == "development" ? true : false)
  if result
    app.use require('connect-less')(src: cwd + '/public/', force: result, compress: true)	
  app.use express.static(cwd + '/public', maxAge: 86400000)
  app.use form keepExtensions: true
  app.use express.bodyParser()
	app.use express.cookieParser()
	app.use express.session secret: session_key.key, store: new RedisStore(redisOpts)
	app.use express.methodOverride()
	# app.use app.router
	app.use mongooseAuth.middleware()
	app.set 'defaultLocale', 'en'

mongooseAuth.helpExpress(app)