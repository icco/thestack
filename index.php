<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<?php
/*
 *
 * Connect to database
 *
 * Function: give it a date, gives you an array
 *
 * print it out like it's 1992
 *
 */

include "backend.php";
include "markdown.php";

?>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<script type="text/javascript" src="mootools-core.js"></script>
	<script type="text/javascript" src="mootools-more.js"></script>
	<script type="text/javascript" src="stack.js"></script>
	<link rel="stylesheet" href="stack.css" type="text/css" />
<title>the Stack!</title>
</head>
<body>
<div id="cont">
	<h1>theStack!</h1>
	<p>OMG. Content goes here.</p>

	<form id="addTask" method="get" action="backend.php">
		<input name="newTask" type="text" id="newTask" size="40" />
		<input type="submit" value="Add Task" />
	</form>

	<div id="listArea">
		<ol id="todo"></ol>
	</div>

	<div id="data"/>
	</div>
</body>
</html>

