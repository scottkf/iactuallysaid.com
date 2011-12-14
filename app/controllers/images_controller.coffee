load 'application'
layout 'application'

before ->
    Image.findById params.id, (err, image) =>
        if err or not image
            redirect path_to.images
        else
            @image = image
            next()
, only: ['show', 'edit', 'update', 'destroy', 'loveit', 'hateit']

before ->
  Image.find().sort('score', 'descending').limit(5).run (err, images) =>
    if not err and images
      req.images = images
    next();

# GET /images/new
action 'new', ->
    @image = new Image
    @title = 'New image'
    render()

# POST /images
action 'create', ->

    @image = new Image
    ['caption', 'user', 'title'].forEach (field) =>
      @image[field] = body[field] if body[field]?

    if req.user
      user_id = req.user._id
    else
      user_id = req.session.id
    @image["score"] = 0
    @image["user_id"] = user_id
    @image["date"] = new Date()
    @image["url"] = 'http://iactuallysaid.com.s3.amazonaws.com/default.png'

    tmpFile = req.form.files.file;

    switch request.params.type
      when "tip"
        @image['url'] = ''
        if (!body['caption'])
          error = 'Please enter a tip'
      else
        if (!tmpFile?)
          error = 'Please choose a file'


    if !body['title']
      error = 'Please choose a title'
    if !body['user']
      error = "Please enter your name"


    if error?
      flash 'error', error
      return render 'new'
      
    # check for spam
    akismet_key = require(__dirname + '/config/akismet')
    akismet = require('akismet').client({ blog: 'http://shitsirisays.info', apiKey: akismet_key.key })

    akismet.verifyKey (err, verified) ->
      if (verified) 
        console.log('API key successfully verified.')
      else 
        console.log('Unable to verify API key.')

    akismet.checkSpam 
        user_ip: req.connection.remoteAddress,
        permalink: 'http://shitsirisays.info',
        comment_author: @image["user"],
        comment_content: @image["caption"] || '',
      , (err, spam) =>
        if(spam)
          flash 'error', 'Entry <b>NOT</b> submitted, thanks! If you feel this is in error, please'
          redirect path_to.root
          console.log('Spam caught.')
        else

          if tmpFile?
            fs = require 'fs'
            knox = require 'knox'
            amazon_key = require(__dirname + '/config/amazon')
            console.log amazon_key
            client = knox.createClient
                key: amazon_key.public
                secret: amazon_key.private
                bucket: amazon_key.bucket


            path = require 'path'
            random_id = @image._id
            extension = path.extname(tmpFile.path)
            # console.log(tmpFile)
            if !extension.match(/png|jpg|jpeg|gif/i)
                flash 'error', 'Improper file format, choose one of PNG/JPG/JPEG/GIF'
                return render 'new'
            else if tmpFile.size == 0
              flash 'error', 'File too small'
              return render 'new'
            else if tmpFile.size > 500000
              flash 'error', 'File too large, try a smaller size'
              return render 'new'
            else
              filename = path.basename(tmpFile.name, extension).replace(/\s/g, '') || random_id
              fs.readFile(tmpFile.path, (err, buf) ->
                req = client.put(filename + '-' + random_id + extension, {'Content-Length': buf.length, 'Content-Type': tmpFile.type})
                req.on('response', (res) ->
                  if (200 == res.statusCode)
                    # console.log(req.url)
                    if req.url
                      Image.findById(random_id, (err, doc) ->
                        if not err and doc
                          doc.url = req.url
                          doc.save (err) =>
                            true
                        else
                      )
                req.end(buf))
              )


          @image.save (errors) ->
              if errors
                  flash 'error', 'Sorry, there was an error with submission, try again in a few minutes!'
                  render 'new',
                      title: 'New image'
              else
                  flash 'info', 'Entry submitted, thanks!'
                  redirect path_to.images

# POST 
action 'loveit', ->
  if req.user
    user_id = req.user._id
  else
    user_id = req.session.id
  @image.voted(user_id, (err, votes) =>
    if not err and votes.length > 0
      # already voted
      send {response:204,id:@image.id} 
    else
      @image.upvotes.push({user_id: user_id})
      @image.score = @image.score + 1
      @image.save (err) =>
          if err
            status= 500
          else
            status = 200
          send {response:status,id:@image.id}
  )  

action 'hateit', ->
  if req.user
    user_id = req.user._id
  else
    user_id = req.session.id
  @image.voted(user_id, (err, votes) =>
    if not err and votes.length > 0
      # already voted
      send {response:204, id:@image.id} 
    else
      @image.downvotes.push({user_id: user_id})
      @image.score = @image.score - 1
      @image.save (err) =>
          if err
            status= 500
          else
            status=200
          send {response:status, id:@image.id}
  )  
          
          
action 'byuser', ->
  page = req.params.page || 1
  limit = 6
  offset = (page-1)*limit
  total = 0
  sort = null
  switch req.params.type
    when "top-rated" then sort = "score"
    when "most-recent" then sort = "date"
    else sort = "date"
    
  Image.find({'user_id':req.params.user_id}).count((err, total)=>
    total_pages = Math.ceil(total/limit)
    Image.find({'user_id':req.params.user_id}).sort(sort, 'descending').skip(offset).limit(limit).run (err, images) =>
        render 'index'
            images: images
            title: 'Images index'
            page: page
            total_pages: total_pages
  )


action 'rss', ->
  RSS = require 'rss'
  markdown = require('discount')
  
  feed = new RSS({
          title: 'Shit Siri Says'
          description: 'Interesting comments made by sir'
          feed_url: 'http://shitsirisays.info/rss'
          site_url: 'http://shitsirisays.info'
          image_url: 'http://'
          author: 'Elissa'
  })

  Image.find().sort('date', 'descending').limit(15).run (err, images) =>
    for image in images
      feed.item({
          title:  image.title
          description: (image.url ? "<img style='width: 250px; height: 376px;' src='"+image.url+"'/><Br />" : '') + markdown.parse(image.caption) + "<Br />"
          url: path_to.image(image)
          guid: image.id
          # author: 'Guest Author'
          date: image.date
      })
    xml = feed.xml()
    send xml


# GET /images
action 'index', ->
  page = req.params.page || 1
  limit = 6
  offset = (page-1)*limit
  total = 0
  sort = null
  markdown = require('discount')
  switch req.params.type
    when "top-rated" then sort = "score"
    when "most-recent" then sort = "date"
    else sort = "date"
    
  Image.find().count((err, total)=>
    total_pages = Math.ceil(total/limit)
    Image.find().sort(sort, 'descending').skip(offset).limit(limit).run (err, images) =>
        render
            images: images
            title: 'Images index'
            page: page
            total_pages: total_pages
            markdown: markdown
  )

# GET /images/:id
action 'show', ->
    @title = 'Show image'
    markdown = require('discount')
    render
      markdown: markdown

# GET /images/:id/edit
action 'edit', ->
  if req.user
    @title = 'Edit image details'
    render()
  else
    redirect '/'

# PUT /images/:id
action 'update', ->
  if req.user
    ['title', 'caption', 'url'].forEach (field) =>
        @image[field] = body[field] if body[field]?

    @image.save (err) =>
        if not err
            flash 'info', 'Image updated'
            redirect path_to.image(@image)
        else
            flash 'error', 'Image can not be updated'
            render 'edit',
                title: 'Edit image details'
  else
    redirect '/'

# DELETE /images/:id
# action 'destroy', ->
#     @image.remove (error) ->
#         if error
#             flash 'error', 'Can not destroy image'
#         else
#             flash 'info', 'Image successfully removed'
#         send "'" + path_to.images + "'"
