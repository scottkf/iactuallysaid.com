require('../test_helper.js').controller 'posts', module.exports

sinon = require('sinon')

ValidAttributes = ->
    {
        title: '',
        content: ''
    }

module.exports['posts controller'] = {
    'GET new': (test) ->
        test.get '/posts/new', ->
            test.assign 'title', 'New post'
            test.assign 'post'
            test.success()
            test.render 'new'
            test.render 'form.' + app.set('view engine')
            test.done()

    'GET index': (test) ->
        test.get '/posts', ->
            test.success()
            test.render 'index'
            test.done()

    'GET edit': (test) ->
        find = Post.findById
        Post.findById = sinon.spy (id, cb) -> cb null, new Post

        test.get '/posts/42/edit', ->
            test.ok Post.findById.calledWith('42')
            Post.findById = find
            test.success()
            test.render 'edit'
            test.done()

    'GET show': (test) ->
        find = Post.findById
        Post.findById = sinon.spy (id, cb) -> cb null, new Post

        test.get '/posts/42', (req, res) ->
            test.ok Post.findById.calledWith('42')
            Post.findById = find
            test.success()
            test.render('show')
            test.done()

    'POST create': (test) ->
        post = new ValidAttributes
        oldSave = Post.prototype.save
        Post.prototype.save = (cb) -> cb null

        test.post '/posts', post, () ->
            Post.prototype.save = oldSave
            test.redirect '/posts'
            test.flash 'info'
            test.done()

    'POST create fail': (test) ->
        post = new ValidAttributes
        oldSave = Post.prototype.save
        Post.prototype.save = (cb) -> cb(new Error)

        test.post '/posts', post, () ->
            Post.prototype.save = oldSave
            test.success()
            test.render('new')
            test.flash('error')
            test.done()

    'PUT update': (test) ->
        find = Post.findById
        Post.findById = sinon.spy (id, callback) ->
            test.equal id, 1
            callback null,
                id: 1
                save: (cb) -> cb(null)

        test.put '/posts/1', new ValidAttributes, () ->
            Post.findById = find
            test.redirect '/posts/1'
            test.flash 'info'
            test.done()

    'PUT update fail': (test) ->
        find = Post.findById
        Post.findById = sinon.spy (id, callback) ->
            test.equal id, 1
            callback null,
                id: 1
                save: (cb) -> cb new Error

        test.put '/posts/1', new ValidAttributes, () ->
            Post.findById = find
            test.success()
            test.render 'edit'
            test.flash 'error'
            test.done()

    'DELETE destroy': (test) ->
        test.done()

    'DELETE destroy fail': (test) ->
        test.done()

}

