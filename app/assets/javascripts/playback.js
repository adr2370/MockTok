/**
 * Wires up the tokbox and firebase for playback
 * session: string, tokbox session ID. Also used by firebase & archive
 * token: string, tokbox user token. Should be moderator for interviewer, publisher for interviewee
 * archive: string, the archive ID
 * interviewer: string, interviewer connection ID
 * interviewee: string, interviewee connection ID
 */
function playback(session, token, archive, interviewer, interviewee) {
    var apikey = "22493452"; // Tokbox API key constant
    var tokbox = TB.initSession(session);
    var fireBase = new Firebase('https://mocktok.firebaseio.com/');
    var fireChild = fireBase.child(session);
    var editor = CodeMirror.fromTextArea($("#pad")[0], {lineNumbers : true});
    
    var playEditor = function() {
        fireChild.once("value", function(snapshot) {
            var start;
            var changes = snapshot.val();
            for (var i in changes) {
                var text = changes[i];
                if (!start) {
                    start = i;
                }
                var delay = i - start;
                setTimeout(function(){
                    editor.setValue(text);
                }, delay);
            }
        });
    }

    // Load archive on connect
    tokbox.addEventListener("sessionConnected", function() {
        tokbox.loadArchive(archive);
    });

    // Begin playback upon loading archive
    tokbox.addEventListener("archiveLoaded", function(e) {
        e.archives[0].startPlayback();
        playEditor();
    });
    
    // Subscribe to interviewer & interviewee streams
    tokbox.addEventListener("streamCreated", function(e) {
        e.streams.forEach(function(stream) {
            if(stream.connection.connectionId != interviewer && stream.connection.connectionId != interviewee)
                return;
            tokbox.subscribe(stream, stream.connection.connectionId != interviewee ? "video_interviewee" : "video_interviewer", {width: 400, height: 300});
        });
    });

    // Perform the actual connection
    tokbox.connect(apikey, token);
}