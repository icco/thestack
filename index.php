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

require "lib/includes.php";

?>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<script type="text/javascript" src="mootools-core.js"></script>
	<script type="text/javascript" src="mootools-more.js"></script>
<title>the Stack!</title>
</head>
<body>
<div id="cont">
	<h1>theStack!</h1>
	<form id="addItem" method="post" action="backend.php">
		<textarea name="content" cols="80" rows="3">The Task Goes Here</textarea><br />
		<input type="submit" value="Add to theStack" />
	</form>
</body>
</html>

