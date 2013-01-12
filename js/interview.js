TB.addEventListener("exception", exceptionHandler);
var session = TB.initSession(sessionId); // Replace with your own session ID. See https://dashboard.tokbox.com/projects
session.addEventListener("sessionConnected", sessionConnectedHandler);
session.addEventListener("streamCreated", streamCreatedHandler);
session.connect(apiKey, token); // Replace with your API key and token. See https://dashboard.tokbox.com/projects
function sessionConnectedHandler(event) {
	 subscribeToStreams(event.streams);
	var div = document.createElement('div');
	     div.setAttribute('id', 'publisher');

	     var publisherContainer = document.getElementById('publisherContainer');
	         // This example assumes that a publisherContainer div exists
	     publisherContainer.appendChild(div);

	     var publisherProperties = {width: 400, height:300, name:"Bob's stream"};
	     publisher = TB.initPublisher(API_KEY, 'publisher', publisherProperties);
	     session.publish(publisher);
}
function streamCreatedHandler(event) {
    for (var i = 0; i < event.streams.length; i++) {
        var stream = event.streams[i];
		if (stream.connection.connectionId != session.connection.connectionId) {
			displayStream(stream);
		}
    }
}
function subscribeToStreams(streams) {
	for (i = 0; i < streams.length; i++) {
		var stream = streams[i];
		if (stream.connection.connectionId != session.connection.connectionId) {
			displayStream(stream);
		}
	}
}
function displayStream(stream) {
    var div = document.createElement('div');
    div.setAttribute('id', 'stream' + stream.streamId);
    var streamsContainer = document.getElementById('streamsContainer');
    streamsContainer.appendChild(div);
    subscriber = session.subscribe(stream, 'stream' + stream.streamId);
}
function exceptionHandler(event) {
	console.log(event.message);
}