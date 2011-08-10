#!/usr/bin/env php
<?php
if ($argc < 3)
{
  echo "Nono.. filenames, please!" . PHP_EOL;
  exit;
}
$xbm = fopen($argv[1], "r");
$bin = fopen($argv[2], "wb");

// get to the actual data
$line = fgets($xbm);
$line = fgets($xbm);
$line = fgets($xbm);
// here is the binary data
$bindata = array();

while ($line = fgets($xbm)){
print PHP_EOL . 'xbm: ' . $line;
if (! $line) exit;
$data = explode(',', $line);

foreach ($data as $val)
{
 $val = trim($val);
 if ($val)
 {
  $val = substr($val, 0, 4);
   echo $val . ',';
  $bindata[] = bit_reverse(hexdec($val));
  }
}
}

print count($bindata);

//$bindata = array_reverse($bindata);


foreach ($bindata as $val)
{
  fwrite($bin, chr($val));
}
fclose($xbm);
fclose($bin);

function bit_reverse($val)
{
  $newval = 0;
  if ($val & 1) $newval += 128;
  if ($val & 2) $newval += 64;
  if ($val & 4) $newval += 32;
  if ($val & 8) $newval += 16;
  if ($val & 16) $newval += 8;
  if ($val & 32) $newval += 4;
  if ($val & 64) $newval += 2;
  if ($val & 128) $newval += 1;
  print "Got $val, returned $newval" . PHP_EOL;
  return $newval;
}
