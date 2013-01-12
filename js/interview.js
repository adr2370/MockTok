TB.addEventListener("exception", exceptionHandler);
var session = TB.initSession(sessionId); // Replace with your own session ID. See https://dashboard.tokbox.com/projects
session.addEventListener("sessionConnected", sessionConnectedHandler);
session.addEventListener("streamCreated", streamCreatedHandler);
session.connect(apiKey, token); // Replace with your API key and token. See https://dashboard.tokbox.com/projects
function sessionConnectedHandler(event) {
	 subscribeToStreams(event.streams);
	var publisherContainer = document.getElementById('myPublisherDiv');
	     var publisherProperties = {width: 400, height:300, name:"Bob's stream"};
	     publisher = TB.initPublisher(apiKey, 'publisher', publisherProperties);
	     session.publish(publisher);
}
function sessionConnectHandler(event) {
    var divProps = {width: 400, height:300, name:"Alex's stream"};
    publisher = TB.initPublisher(apiKey, 'publisher', divProps);
                      // This assumes that there is a DOM element with the ID 'publisher'.
    session.publish(publisher);
}
function streamCreatedHandler(event) {
	subscribeToStreams(event.streams);
}
function subscribeToStreams(streams) {
	for (i = 0; i < streams.length; i++) {
		var stream = streams[i];
		if (stream.connection.connectionId != session.connection.connectionId) {
			session.subscribe(stream);
		}
	}
}
function exceptionHandler(event) {
	console.log(event.message);
}