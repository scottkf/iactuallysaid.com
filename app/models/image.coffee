Image.prototype.voted = (user_id, done) ->
  Image.find {'_id': this._id, $or:[{'upvotes.user_id': user_id}, {'downvotes.user_id': user_id}]}, (err, votes) =>
    done(err, votes)
