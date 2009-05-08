<?php

$text = $_GET['newTask'];

if(isset($text))
	file_put_contents("ToDo.txt","<li> $text </li> \n", FILE_APPEND | LOCK_EX);

?>
