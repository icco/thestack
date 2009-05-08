<?php

// Connect to database

// build two arrays, one for today, one for yesterday
// Function: give it a date, gives you an array

// print it out like it's 1992

include "backend.php";

?>

<html>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<link rel="stylesheet" href="demo.css" type="text/css" />
	<script type="text/javascript" src="mootools-core.js"></script>
	<script type="text/javascript" src="mootools-more.js"></script>
	<script type="text/javascript" src="demo.js"></script>
<title>the Stack!</title>
</head>
<body>
<h1>theStack!</h1>
<p>OMG. Content goes here.</p>

	<form id="addTask">
		<input type="text" id="newTask" />
		<input type="submit" value="Add Task" />
	</form>

	<div id="listArea">
		<ol id="todo"></ol>
	</div>

	<div id="data"/>
</body>
</html>
