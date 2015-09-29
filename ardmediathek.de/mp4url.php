<?php

function http_parse_headers_foo( $headers )
{
    $res=array();
    foreach($headers as $header)
    {
        $i = strpos($header,': ');
        if ($i!==false)
        {
            $key=substr($header,0,$i);
            $value=substr($header,$i+2,strlen($header)-$i-2);
            $res[$key]=$value;
        }
    }
    return $res;
}

function getHTTP($url,$timeout=30)
{
  try
  {
    $options = array('http'=>array('method'=>'GET','timeout' => $timeout, 'user_agent' => 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:23.0) Gecko/20100101 Firefox/23.0')); // Force network timeout
    $context = stream_context_create($options);
    $data=file_get_contents($url,false,$context,-1, 1000000); // We download at most 1 Mb from source.
    if (!$data) { return array('HTTP Error',array(),''); }
    $httpStatus=$http_response_header[0]; // e.g. "HTTP/1.1 200 OK"
    $responseHeaders=http_parse_headers_foo($http_response_header);
    return array($httpStatus,$responseHeaders,$data);
  }
  catch (Exception $e)  // getHTTP *can* fail silently (we don't care if the title cannot be fetched)
  {
    return array($e->getMessage(),'','');
  }
}

if (isset($_GET['htmlurl'])) {
  $url = preg_replace('/.*documentId=(\d+).*/','http://www.ardmediathek.de/play/media/\\1', $_GET['htmlurl']);
  list($httpstatus,$headers,$data) = getHTTP($url);
  if(isset($data)) {
    $json = json_decode($data, true);
    foreach($json['_mediaArray'] as $media) {
      foreach($media['_mediaStreamArray'] as $mediaStream) {
        if( 3 == $mediaStream['_quality']) {
          header('Location: '.$mediaStream['_stream']);
          exit;
        }
      }
    }
  }
}
header('Content-Type: '.'text/plain; charset=utf-8');
?>                   ___            _ 
                  /   |          | |
 _ __ ___  _ __  / /| |_   _ _ __| |
| '_ ` _ \| '_ \/ /_| | | | | '__| |
| | | | | | |_) \___  | |_| | |  | |
|_| |_| |_| .__/    |_/\__,_|_|  |_|
          | |                       
          |_|                       
                                    
Find the mp4 file URL for a www.ardmediathek.de video clip.

Call me like this:

$ curl --head --location "http://linkeddata.mro.name/open/tv/mediathek/ardmediathek.de/mp4url.php?quality=3&htmlurl=http%3A%2F%2Fwww.ardmediathek.de%2Ftv%2FDie-Sendung-mit-der-Maus%2FDie-Sendung-mit-der-Maus-vom-27-09-2015-%2FDas-Erste%2FVideo%3FdocumentId%3D30786788%26bcastId%3D1458"

and I'll
- pull out the documentId=<docId> part, 
- GET http://www.ardmediathek.de/play/media/<docId>,
- decode the JSON,
- look for the first $json['_mediaArray']['_mediaStreamArray'] with '_quality' == 3,
- redirect to it's '_stream' URL.

è violá!
