#!/usr/bin/env php
<?php

	$orig_bitarray = array(0,0,0,0,0,0,0,0);
	echo "TransformTable" . PHP_EOL;
	
	for ($i = 0; $i <= 255; $i++)
	{
		$bitarray = $orig_bitarray;
		$bin_i = strrev(implode('', array_replace($bitarray, str_split(strrev(decbin($i))))));
		$doubled = '';
	
		foreach (str_split($bin_i) as $val)
		{
			$doubled .= (string)$val . (string)$val;
		}
	
		echo ' FDB %'.$doubled . PHP_EOL;
	}

