<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<title>Drop in test</title>
	<script type="text/javascript" src="https://www.dropbox.com/static/api/2/dropins.js" id="dropboxjs" data-app-key="j48q2fi1kpo1w3u"></script>
	<script type="text/javascript" src="https://apis.google.com/js/api.js"></script>
	<script src="https://apis.google.com/js/client.js"></script> 
	<script type="text/javascript" src="https://apis.google.com/js/platform.js"></script>
	<script type="text/javascript" src="http://cdnjs.cloudflare.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
	<link rel="stylesheet" type="text/css" href="http://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/2.1.1/css/bootstrap.min.css">
	<link rel="stylesheet" type="text/css" href="css/index.css">
</head>
<body>
	<!-- Drop box stuff -->
	<script type="text/javascript">
		function createChooseButton() {
			var options = {
				success : function(files) {
					// Clear the original save to drive button first
					var dtgGbutton = document.getElementById("dtgGbutton");
					dtgGbutton.innerHTML = "";
					// Then create the new save to drive button
					var file = files[0];
					this.createGoogleSaveButton(file);
				},
				cancel : function() {

				},
				linkType : "direct",
				multiselect : false,
				createGoogleSaveButton : function(file) {
					// Render the save to drive button explicitly
					gapi.savetodrive.render('dtgGbutton', {
			   	          src: file.link,
			   	          filename: file.name,
			   	          sitename: 'Dropbox To Google Drive'
			   	    });
				}
				// extensions : ['.pdf','.doc','.docx']
			}
			var button = Dropbox.createChooseButton(options);
			document.getElementById("dtgDbutton").appendChild(button);
		}
		
		function saveFile(googleObj) {
			debugger;
			var fileLink = googleObj.exportLink;
			var fileType = fileLink.substring(fileLink.lastIndexOf("=")+1);
			var fileName = googleObj.title;
			var options = {
				files: [
			        // You can specify up to 100 files.
			        {'url': fileLink, 'filename': fileName + '.' + fileType},
			        // {'url': '...', 'filename': '...'},
			        // ...
			    ],

			    // Success is called once all files have been successfully added to the user's
			    // Dropbox, although they may not have synced to the user's devices yet.
			    success: function () {
			    	alert("All done");
			    },

			    // Progress is called periodically to update the application on the progress
			    // of the user's downloads. The value passed to this callback is a float
			    // between 0 and 1. The progress callback is guaranteed to be called at least
			    // once with the value 1.
			    progress: function (progress) {},

			    // Cancel is called if the user presses the Cancel button or closes the Saver.
			    cancel: function () {},

			    // Error is called in the event of an unexpected response from the server
			    // hosting the files, such as not being able to find a file. This callback is
			    // also called if there is an error on Dropbox or if the user is over quota.
			    error: function (errorMessage) {}
			}
			
			Dropbox.save(options);
		}
	</script>

	<!-- Google drive stuff -->
	<script type="text/javascript">
		/*
		 * ------- Google drive initialization stuff --------- 
		 */ 
		var formatMap = {
			"application/vnd.google-apps.document" : "doc",
			"application/vnd.google-apps.spreadsheet" : "xls",
			"application/vnd.google-apps.presentation" : "ppt"
		}
		
	    // The API developer key obtained from the Google Developers Console.
	    var developerKey = 'DEVELOP_KEY';
	
	    // The Client ID obtained from the Google Developers Console.
	    var clientId = 'CLIENT_ID';
	
	    // Scope to use to access user's photos.
	    // Add other view scope here, find from here https://developers.google.com/picker/docs/
	    var scope = ['https://www.googleapis.com/auth/drive.readonly'];
	
	    var pickerApiLoaded = false;
	    var oauthToken;
	
	    // Use the API Loader script to load google.picker and gapi.auth.
	    function onApiLoad() {
	       	gapi.load('auth', {'callback': onAuthApiLoad});
	       	gapi.load('picker', {'callback': onPickerApiLoad});
	       	handleClientLoad();
	    }
	
	    function onAuthApiLoad() {
	    	debugger;
	       	window.gapi.auth.authorize(
	        {
	            'client_id': clientId,
	            'scope': scope,
	            'immediate': false
	        },
	        handleAuthResult);
	    }
	
	    function onPickerApiLoad() {
	        pickerApiLoaded = true;
	       	createPicker();
	    }
	
	    function handleAuthResult(authResult) {
	    	debugger;
	       	if (authResult && !authResult.error) {
	         	 oauthToken = authResult.access_token;
	             createPicker(); 
	       	}
	    }
	
	    // Initialization of the gapi client, including authorization and load drive part
	    function handleClientLoad() {
	   	    gapi.client.setApiKey('DEVELOP_KEY');
	   	    gapi.client.load('drive', 'v2');
	   		
	   	    // Try to silently authenticate
	   	    gapi.auth.authorize({
	   		    client_id: 'CLIENT_ID',
	   		    scope: 'https://www.googleapis.com/auth/drive.readonly',
	   		    immediate: true
	   	    });
	    }
	    
	 	/*
	 	 * ----- Google drive initialization stuff end --------
		 */
		 
		/*
		 * ----- Sync file to DropBox --------
		 */ 
		 
		// Create and render a Picker object for picking user Photos.
	    // Add other view in the build pattern if you want to select more 
	    function createPicker() {
	    	if (pickerApiLoaded && oauthToken) {
	      		var picker = new google.picker.PickerBuilder().
	          		addView(google.picker.ViewId.DOCS).
	          		setOAuthToken(oauthToken).
	          		setDeveloperKey(developerKey).
	          		setCallback(pickerCallback).
	          		build();
	      		picker.setVisible(true);
	    	}
	  	}
	
	    // Handle when you select something
	    function pickerCallback(data) {
	    	var url = 'nothing';
	    	if (data[google.picker.Response.ACTION] == google.picker.Action.PICKED) {
	      		var doc = data[google.picker.Response.DOCUMENTS][0];
	      		filePick(doc);
	    	}
	  	}
	  
	    // For native google documents, we need to call the other api to retrieve the content of the file
	    // And use the exportLink to upload to dropbox
	    function filePick(doc) {
		    var id = doc[google.picker.Document.ID];
		    var request = gapi.client.drive.files.get({
			    fileId: id
		    });
		    request.execute(processFile);
	    }
	  
	    // Creat the googleDoc object needs to pass to dropbox to save
	    function processFile(file) { debugger;
		    // TODO: All google native document is same, add branch later for other files
		    //       Currently only doc works fine, need to find the proper externalLink for ppt and xls
		    var mimeType = formatMap[file.mimeType];
		    if (mimeType == "doc") {
		    	exportLink = file.exportLinks['application/vnd.openxmlformats-officedocument.wordprocessingml.document'];
		    } else if (mimeType == "ppt") {
		    	exportLink = file.exportLinks["application/vnd.openxmlformats-officedocument.presentationml.presentation"];
		    } else if (mimeType == "xls") {
		    	exportLink = file.exportLinks['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'];
		    }
		    var title = file.title;
		    var googleDoc = {
		    	"exportLink" : exportLink,
		    	"mimeType" : mimeType,
		    	"title" : title
		    }
		    // Pass the googleDoc object to drop box saveFile function
		    saveFile(googleDoc);
	    }
	    
	    /*
		 * ----- Sync file to DropBox end --------
		 */ 
	</script>
	
	<!-- Page -->
	<img id="logo" alt="logo" src="resource/google-drive-vs-dropbox.jpg"></img>
	<h1 id="logoName"> DropDrive </h1>
	<div id="link">
		<a href="https://github.com/shiqing881215/DropDrive">GitHub</a> |
		<a href="https://youtube.com/...">YouTube</a>
	</div>
	
	<img id="dropboxLogo" alt="dropboxLogo" src="resource/dropbox.png">
	<div id="dbutton">
		<button onclick="onApiLoad()" class="btn-primary btn">Sync file to DropBox</button>
	</div>
	
	<img id="googleDriveLogo" alt="googleDriveLogo" src="resource/googleDrive.png">
	<div id="gbutton">
		<button onclick="createChooseButton()" class="btn-primary btn">Sync file to Google Drive</button>
		<div id="dtgDbutton"></div>
		<br/>
		<div id="dtgGbutton"></div>
	</div>
</body>
</html>
