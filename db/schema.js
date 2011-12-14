var mongoose = require('mongoose'),
    Schema = mongoose.Schema,
    ObjectId = Schema.ObjectId

  ;

/**
 * Vote
 */
var VoteSchema = new Schema;
VoteSchema.add({
    user_id : String,
});
mongoose.model("Vote", VoteSchema);
module.exports["Vote"] = mongoose.model("Vote");module.exports["Vote"].modelName = "Vote"




/**
 * Image
 */
var ImageSchema = new Schema;
ImageSchema.add({
    title   : String,
    caption : String,
    url     : String,
    user    : String,
    user_id : String,
    date    : Date,
    upvotes : [VoteSchema],
    downvotes : [VoteSchema],
    score : Number
});
mongoose.model("Image", ImageSchema);
module.exports["Image"] = mongoose.model("Image");module.exports["Image"].modelName = "Image"