/**
 * Wires up the tokbox and firebase for playback
 * session: string, tokbox session ID. Also used by firebase & archive
 * token: string, tokbox user token. Should be moderator for interviewer, publisher for interviewee
 * archive: string, the archive ID
 * interviewer: string, interviewer user ID
 * interviewee: string, interviewee user ID
 */
function playback(session, token, archive, interviewer, interviewee) {
    var apikey = "22493452"; // Tokbox API key constant
    var tokbox = TB.initSession(session);
TB.setLogLevel( TB.DEBUG );
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
            //if(stream.connection.data != interviewer && stream.connection.data != interviewee)
                //return;
            // Point it to the right div
            //var isInterviewer = stream.connection.data == interviewer;
            var id = "video_" + stream.streamId
            var container = $("<div>").attr("id", id);
                $("#video").append(container);
            tokbox.subscribe(stream, id, {width: $(window).height()*2/3-1, height: $(window).height()/2-1});
            $("#video object:first-child").attr('style','outline: none;position: absolute;left: 0px;top: 0px;');
            $("#video object:last-child").attr('style','outline: none;position: absolute;left: 0px;top: '+$(window).height()/2+'px;');
            $(".CodeMirror").attr('style',"position: absolute;right: 0px;top: 0px;height: "+($(window).height()-1)+"px;width: "+($(window).width()-$(window).height()*2/3)+"px");
        });
    });

    // Perform the actual connection
    tokbox.connect(apikey, token);
}
