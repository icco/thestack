<?php

$text = $_GET['newTask'];

file_put_contents("ToDo.txt", $text . "\n", FILE_APPEND | LOCK_EX);

?>
