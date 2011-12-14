
mongoose = require('mongoose')
Schema = mongoose.Schema

conf = require(__dirname + '/oauth_providers')

UserSchema = new Schema({})




mongooseAuth  = require 'mongoose-auth'


UserSchema.plugin(mongooseAuth, 
    everymodule:
      everyauth:
          User: ->
            User
    facebook: 
      everyauth: 
          myHostname: 'http://localhost:3000'
          appId: conf.fb.appId
          appSecret: conf.fb.appSecret
          redirectPath: '/'
    twitter:
      everyauth: 
          myHostname: 'http://localhost:3000'
          consumerKey: conf.twit.consumerKey
          consumerSecret: conf.twit.consumerSecret
          redirectPath: '/'
    github:
      everyauth:
        myHostname: 'http://localhost:3000' 
        appId: conf.github.appId
        appSecret: conf.github.appSecret
        redirectPath: '/'
)

User = mongoose.model('User', UserSchema);
module.exports["User"] = mongoose.model("User")
module.exports["User"].modelName = "User"