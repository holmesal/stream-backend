
express = require 'express'
app = express()


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
fakedb = 
	id: 1234
	name: 'The stream meta-stream'
	slug: 'meta-stream'
	posts: [
		{
			content: 'I want someplace to microblog while I work, so I can record things without going off on tangents, and come back to them later. 9:10PM on Nov 16'
			timestamp: Date.now()
		}
		{
			content: 'I also want a record of all of the problems I faced and the decisions I made.'
			timestamp: Date.now()
		}
	]

app.configure ->
	app.use allowCrossDomain
	app.use express.bodyParser()


app.get '/', (req, res) ->
	res.end 'Up and running cap\'n!'

app.get '/stream/:stream', (req, res) ->
	console.log 'got a request for a stream!'
	res.json fakedb


app.post '/stream/:stream/post', (req, res) =>
	console.log 'got a post request to post a post yo'

	console.log req.body

	fakedb.posts.unshift req.body.data

	# process.env.db.posts.unshift req.body.post

	res.end()

app.listen 80