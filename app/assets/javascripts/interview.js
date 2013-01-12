/**
 * Wires up the tokbox, firebase and countdown functionality
 * interviewer: boolean, whether this is an interviewer or not
 * username: string, the user's name
 * session: string, tokbox session ID. Also used by firebase & archive
 * token: string, tokbox user token. Should be moderator for interviewer, publisher for interviewee
 * length: integer, length of meeting in minutes
 */
function interview(interviewer, username, session, token, length) {
    var apikey = "22493452"; // Tokbox API key constant

    // Establish Firebase & CodeMirror connections for the editor
    var fireBase = new Firebase('https://mocktok.firebaseio.com/');
    var fireChild = fireBase.child(session);
    var editor = CodeMirror.fromTextArea($("#pad")[0], {lineNumbers : true});
    var latest = 0;
    var lastText = editor.getValue();
    var initialized;
    
    // Update server on change
    editor.on("change", function(instance, changeObj) {
        if (lastText == instance.getValue()) return;
        if (!initialized) {
            initialized = true;
            return;
        }
        lastText = instance.getValue();
        latest = (new Date).getTime();
        fireChild.child(latest).setWithPriority(instance.getValue(), latest);
    });

    // Update client on server modification
    fireChild.on("child_added", function(childSnapshot, prevChildName) {
        var priority = childSnapshot.getPriority();
        var text = childSnapshot.val();
        if (latest < priority) {
            latest = priority;
            lastText = text;
            editor.setValue(text);
        }
    });
    
    // Create the tokbox session
    var tokbox = TB.initSession(session);
    var archive = null;
    var peer = null;

    // Shut it all down on disconnect
    var disconnect = function() {
        if(interviewer) {
            tokbox.stopRecording(archive);
            tokbox.closeArchive(archive);
        }
        tokbox.unpublish();
        tokbox.disconnect();
        // Do we need to stop the editor?
        setTimeout(function() {
            window.location = "/review/"+session; // Redirect to session review
        }, 500);
    }

    var tokboxSubscribe = function(stream) {
        // Don't re-subscribe, nor subscribe to ourselves
        if(tokbox.connection && stream.connection.connectionId == tokbox.connection.connectionId)
            return;
        // Store peer connection ID for recording
        peer = stream.connection.connectionId;
        // Point it to the right div
        tokbox.subscribe(stream, interviewer ? "video_interviewee" : "video_interviewer", {width: 400, height: 300});
        // Begin the countdown
        $("#time").countdown({
            until: "+" + length + "m",
            layout: interviewer ? "{mn}{sep}{snn}" : "{mn} min",
            onExpiry: disconnect
        });
        // If archive's ready, begin recording
        if(archive)
            tokboxRecord();
    }

    var tokboxRecord = function() {
        tokbox.startRecording(archive);
        // Publish the data to the server for later playback
        $.post("/archive",{session: tokbox_id, archive: archive.archiveID, interviewer: tokbox.connection.connectionId, interviewee: peer});
    }

    tokbox.addEventListener("sessionConnected", function(e) {
        // Publish our stream
        var publisher = TB.initPublisher(apikey, interviewer ? "video_interviewer" : "video_interviewee", {width: 400, height: 300});
        tokbox.publish(publisher);
        // Subscribe to existing streams
        e.streams.forEach(tokboxSubscribe);
        if(interviewer) {
            // Save the archive, and record if there's already a peer
            tokbox.addEventListener("archiveCreated", function(e) {
                archive = e.archives[0];
                if(peer)
                    tokboxRecord();
            });
            // Create a session archive so that interviewer is in charge
            tokbox.createArchive(tokbox_apikey, "perSession", session);
        }
    });
    
    // Subscribe to streams as they come in
    tokbox.addEventListener("streamCreated", function(e) {
        e.streams.forEach(tokboxSubscribe);
    });
    
    // Actually connect to tokbox
    tokbox.connect(apikey, token);
}