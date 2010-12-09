<?php

	require_once ('jpgraph/jpgraph.php');
	require_once ('jpgraph/jpgraph_line.php');
	
	$PATH_ORIG = "../phash/bilder";
	$PATH_MOD = "../phash/bilder_mod";

	
	$d = dir($PATH_ORIG);
	$bilder = array();
	while (false !== ($entry = $d->read())) {
		if ($entry == "." || $entry == ".." || !file_exists($PATH_MOD . "/" . $entry))
			continue;
		$bilder[] = $entry;
	}
	$d->close();
	
	$results = array();
	for($i=0;$i <= sizeof($bilder); $i++)
	{
		if ($bilder[$i] == null)
			break;
		$image1 = ph_dct_imagehash($PATH_ORIG . "/" . $bilder[$i]);
		
		$image2 = ph_dct_imagehash($PATH_MOD . "/" . $bilder[$i]);
		
		$results[] = ph_image_dist($image1, $image2);
	}
	
	$graph = new Graph(350,200,"auto");
	$graph->SetScale("textlin");
	$lineplot=new LinePlot($results);
	$graph->Add($lineplot);
	$lineplot->SetColor("orange");
	//$lineplot->SetFillColor("darkorange@0.6");
	$lineplot->SetWeight(2);
	$lineplot->value->Show();
	$lineplot->value->SetFont(FF_FONT0 ,FS_NORMAL); 
	$lineplot->value->SetColor("orange");
	$graph->Stroke();
?>