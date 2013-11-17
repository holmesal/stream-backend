// Generated by CoffeeScript 1.6.3
(function() {
  var PostSchema, StreamSchema, UserSchema, mongoose;

  mongoose = require('mongoose');

  UserSchema = mongoose.Schema({
    username: String,
    streams: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Stream'
      }
    ],
    avatar: String
  });

  StreamSchema = mongoose.Schema({
    slug: String,
    title: String,
    owner: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    posts: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Post'
      }
    ],
    watchers: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
      }
    ]
  });

  PostSchema = mongoose.Schema({
    content: String,
    stream: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Stream'
    },
    comments: [
      {
        content: String,
        author: {
          type: mongoose.Schema.Types.ObjectId,
          ref: 'User'
        }
      }
    ],
    timestamp: {
      type: Date,
      "default": Date.now
    }
  });

  module.exports = {
    User: mongoose.model('User', UserSchema),
    Stream: mongoose.model('Stream', StreamSchema),
    Post: mongoose.model('Post', PostSchema)
  };

}).call(this);