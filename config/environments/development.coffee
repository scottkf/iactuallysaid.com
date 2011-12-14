express = require('express')
app.configure 'development', ->
    app.disable 'view cache'
    app.disable 'model cache'
    app.disable 'eval cache'
    app.use express.errorHandler dumpExceptions: true, showStack: true
    app.set 'translationMissing', 'display'

