<h1>DropDrive</h1>
=========

Sync your files between Dropbox and GoogleDrive<br/><br/>

<h2> Feature </h2>
Sync file from Dropbox to GoogleDrive - <br/>
Choose a file from dropbox and with one click upload it to the google drive.<br/>
Sync file from GoogleDrive to Dropbox - <br/>
Choose a file from GoogleDrive and with one click upload it to the dropbox.<br/>

<h2> Installation </h2>
Prerequest : Tomcat <br/>
Download the app, setup the maven webapp in your local. <br/>
If you are using the eclipse to run the maven project, create a new maven build with the goal as command "tocat:run". <br/>

<h2> Technical Notes <h2/>
Actually there is no need to set up a maven dependency, cause all you need to here is javascript. <br/>
For Dropbox: <br/>
Mainly use the Dropbox drop-ins ui component to create chooser and picker. <br/>
https://www.dropbox.com/developers/dropins <br/>
For GoogleDrive: <br/>
Use Save-to-drive button to upload file to google drive https://developers.google.com/drive/web/savetodrive#explicit_render <br/>
Use picker to choose the file from google drive and use the exportLink to upload to dropbox https://developers.google.com/picker/docs/ <br/>




