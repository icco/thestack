<?php

// Connect to database

// build two arrays, one for today, one for yesterday
// Function: give it a date, gives you an array

// print it out like it's 1992

include "backend.php";

?>

<html>
<head>
<title>the Stack!</title>
</head>
<body>
<h1>theStack!</h1>
<p>OMG. Content goes here.</p>
<form action="index.php" method="post">
<textarea name="text"></textarea>
<br /><input type="submit" value="Submit" />
</form>
<p>
<?php
print $_POST['text'];
?>
</p><p>
<?php
$temp = new Post();
print $temp;
?>
</p>
</body>
</head>

