<?php

if(isset($_POST))
{
	$db = new StackConnection();
	$db->newPost($_POST['content']);
}


?>
