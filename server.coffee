
express = require 'express'
app = express()
mongoose = require 'mongoose'
Models = require './models'

# Connect to mongolab
mongoose.connect "mongodb://nodeserver:Carl123!@ds047198.mongolab.com:47198/carl"
db = mongoose.connection
db.on 'error', console.error.bind(console, 'connection error')
db.once 'open', ->
	console.log 'connected successfully to mongodb'
	# Start listening
	app.listen 80


allowCrossDomain = (req, res, next) ->
	# Allow headers
	res.header 'Access-Control-Allow-Origin', '*'
	res.header 'Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS'
	res.header 'Access-Control-Allow-Headers', 'Content-Type, Authorization, Content-Length, X-Requested-With'

	# Intercept options
	if req.method is 'OPTIONS'
		res.send 200
	else
		next()

# Spoof the database. Store shit on process. ugly as shit.
# process.env['fakedb'] = {}
# fakedb = 
# 	id: 1234
# 	name: 'The stream meta-stream'
# 	slug: 'meta-stream'
# 	posts: [
# 		{
# 			content: 'I want someplace to microblog while I work, so I can record things without going off on tangents, and come back to them later. 9:10PM on Nov 16'
# 			timestamp: Date.now()
# 		}
# 		{
# 			content: 'I also want a record of all of the problems I faced and the decisions I made.'
# 			timestamp: Date.now()
# 		}
# 	]

app.configure ->
	app.use allowCrossDomain
	app.use express.bodyParser()


app.get '/', (req, res) ->
	res.end 'Up and running cap\'n!'



# User	

app.get '/user/:userIdOrName', (req, res) ->
	# isId = true if mongoose.Types.ObjectId(req.body.userIdOrName)
	q = Models.User.findOne()
	if req.params.userIdOrName.match /^[0-9a-fA-F]{24}$/
		# Get by id
		q.where('_id').equals req.params.userIdOrName
	else
		# Get by username
		q.where('username').equals req.params.userIdOrName

	q.populate
		path: 'streams'
		select: 'title slug'

	q.exec (err, user) ->
		if err
			console.error err
			res.json 500, {error:err}
		else
			res.json user

app.post '/user', (req, res) ->
	# TODO - make sure this user doesn't already exist
	user = new Models.User 
		username: req.body.username
	user.save (err, user) ->
		if err
			console.error err
			res.json 500, {error:err}
		else
			res.json user

app.put '/user/:userid', (req, res) ->
	Models.User.findByIdAndUpdate req.params.userid, # DANGER - no validation using findByIdAndUpdate
		$set: req.body
	, (err, user) ->
		if err
			console.error err
			res.json 500, {error:err}
		else
			res.json user




# Stream



app.get '/stream/:streamIdOrSlug', (req, res) ->
	q = Models.Stream.findOne()
	if req.params.streamIdOrSlug.match /^[0-9a-fA-F]{24}$/
		# Get by id
		q.where('_id').equals req.params.streamIdOrSlug
	else
		# Get by username
		q.where('slug').equals req.params.streamIdOrSlug

	q.populate
		path: 'posts owner'
		options:
			sort: '-timestamp'

	q.exec (err, stream) ->
		if err
			console.error err
			res.json 500, {error:err}
		else
			res.json stream

app.post '/stream', (req, res) ->
	console.log 'creating a new stream'
	owner = '52891ffb22883365e2000002' #TODO - this should be "self" - the logged in user
	stream = new Models.Stream 
		slug: req.body.slug
		title: req.body.title
		owner: owner
	stream.save (err, stream) ->
		if err
			console.error err
			res.json 500, {error: err}
		else
			# Attach to this user
			Models.User.findOne
				'_id': owner
			, (err, user) ->
				user.streams.push stream
				user.save (err, user) ->
					if err
						console.error err
						res.json 500, {error: err}
					else
						stream.populate 'owner', (err, stream) ->
							res.json stream

app.put '/stream/:streamid', (req, res) ->
	Models.Stream.findByIdAndUpdate req.params.streamid, # DANGER - this doesn't perform any validation
		$set: req.body
	, (err, stream) ->
		if err
			console.error err
			res.json 500, {error: err}
		else
			res.json stream




# Post



app.post '/stream/:streamid/post', (req, res) ->
	Models.Stream.findOne
		'_id': req.params.streamid
	, (err, stream) ->
		post = new Models.Post req.body.post
		post.stream = stream._id
		post.save (err, post) ->
			if err
				console.error err
				res.json 500, {error: err}
			else
				stream.posts.push post._id
				stream.save (err, stream) ->
					if err
						console.error err
						res.json 500, {error: err}
					else
						res.json {data:post}

app.put '/post/:postid', (req, res) ->
	Models.Post.findByIdAndUpdate req.params.postid,
		$set: req.body
	, (err, post) ->
		if err
			console.error err
			res.json 500, {error: err}
		else
			res.json post
