<?php

public class Note 
{

	/**
	 * The constructor. A brand new note.
	 */
	function __construct()
	{
		$this->setX(100);
		$this->setY(100);
		$this->setColor("#CC6699");
		$this->setText("This is a new note.");
	}

	function toHTML()
	{

	}

	function update($text, $color, $x, $y)
	{

	}

	/**
	 * Sets the x position of the note.
	 *
	 * @param $in An integer of distance from left edge of window.
	 */
	function setX($in)
	{

	}

	/**
	 * Sets the y position of the note.
	 *
	 * @param $in An integer of distance from top edge of window.
	 */
	function setY($in)
	{

	}

	/**
	 * Sets the content of the note.
	 *
	 * @param $in The text you wish to store in the note.
	 */
	function setText($in)
	{

	}

	/**
	 * Sets the color of the note
	 *
	 * @param $in the hex value of the color you wish to set the note to.
	 */
	function setColor($in)
	{

	}

	/**
	 * Gets the x position of the note.
	 */
	function getX()
	{
		return $this->x;
	}

	/**
	 * Gets the y position of the note.
	 */
	function getY()
	{
		return $this->y;
	}

	/**
	 * Gets the content of the note.
	 */
	function getText()
	{
		return $this->text;
	}

	/**
	 * Sets the color of the note
	 */
	function getColor()
	{
		return $this->color;
	}
}
?>
