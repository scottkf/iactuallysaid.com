require('../test_helper.js').controller 'images', module.exports

sinon = require('sinon')

ValidAttributes = ->
    {
        
    }

module.exports['images controller'] = {
    'GET new': (test) ->
        test.get '/images/new', ->
            test.assign 'title', 'New image'
            test.assign 'image'
            test.success()
            test.render 'new'
            test.render 'form.' + app.set('view engine')
            test.done()

    'GET index': (test) ->
        test.get '/images', ->
            test.success()
            test.render 'index'
            test.done()

    'GET edit': (test) ->
        find = Image.findById
        Image.findById = sinon.spy (id, cb) -> cb null, new Image

        test.get '/images/42/edit', ->
            test.ok Image.findById.calledWith('42')
            Image.findById = find
            test.success()
            test.render 'edit'
            test.done()

    'GET show': (test) ->
        find = Image.findById
        Image.findById = sinon.spy (id, cb) -> cb null, new Image

        test.get '/images/42', (req, res) ->
            test.ok Image.findById.calledWith('42')
            Image.findById = find
            test.success()
            test.render('show')
            test.done()

    'POST create': (test) ->
        image = new ValidAttributes
        oldSave = Image.prototype.save
        Image.prototype.save = (cb) -> cb null

        test.post '/images', image, () ->
            Image.prototype.save = oldSave
            test.redirect '/images'
            test.flash 'info'
            test.done()

    'POST create fail': (test) ->
        image = new ValidAttributes
        oldSave = Image.prototype.save
        Image.prototype.save = (cb) -> cb(new Error)

        test.post '/images', image, () ->
            Image.prototype.save = oldSave
            test.success()
            test.render('new')
            test.flash('error')
            test.done()

    'PUT update': (test) ->
        find = Image.findById
        Image.findById = sinon.spy (id, callback) ->
            test.equal id, 1
            callback null,
                id: 1
                save: (cb) -> cb(null)

        test.put '/images/1', new ValidAttributes, () ->
            Image.findById = find
            test.redirect '/images/1'
            test.flash 'info'
            test.done()

    'PUT update fail': (test) ->
        find = Image.findById
        Image.findById = sinon.spy (id, callback) ->
            test.equal id, 1
            callback null,
                id: 1
                save: (cb) -> cb new Error

        test.put '/images/1', new ValidAttributes, () ->
            Image.findById = find
            test.success()
            test.render 'edit'
            test.flash 'error'
            test.done()

    'DELETE destroy': (test) ->
        test.done()

    'DELETE destroy fail': (test) ->
        test.done()

}

