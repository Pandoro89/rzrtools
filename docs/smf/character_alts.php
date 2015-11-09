<?php


// Get everything started up...
define('SMF', 1);
error_reporting(defined('E_STRICT') ? E_ALL | E_STRICT ^ E_NOTICE : E_ALL ^ E_NOTICE);
$time_start = microtime();

//be in the right directory
chdir('/var/www/forumv2/cron/');

//include required files
require('../Settings.php');
require('../secret.php');

// And important includes.
require_once($sourcedir . '/QueryString.php');
require_once($sourcedir . '/Subs.php');
require_once($sourcedir . '/Errors.php');
require_once($sourcedir . '/Load.php');
require_once($sourcedir . '/Security.php');
require_once($sourcedir . '/PersonalMessage.php');
require_once($sourcedir . '/Subs-Post.php');
require_once($sourcedir . '/Subs-Members.php');
require_once($sourcedir . '/Subs-Razor.php');
require_once($sourcedir . '/simple_html_dom.php');

// If $maintenance is set specifically to 2, then we're upgrading or something.
if (!empty($maintenance) && $maintenance == 2)
    db_fatal_error();

// Create a variable to store some SMF specific functions in.
$smcFunc = array();
$sov_changes = array();
$cur_sov = array();
$stats = array();

// Start the database connection and define some database functions to use.
loadDatabase();

// Load the settings from the settings table, and perform operations like optimizing.
reloadSettings();

// Clean the request variables, add slashes, etc.
cleanRequest();

// Register an error handler.
set_error_handler('error_handler');

// Globals
global $boarddir, $smcFunc, $modSettings;

/**
* SELECT  `smf_rzr_api_member`.memberName AS char_name,  `smf_rzr_api_member`.id_eve AS char_id,  `main`.id_eve AS main_id,  `main`.memberName AS main_name
* FROM  `smf_rzr_api_member` 
* LEFT OUTER JOIN  `smf_rzr_api_member` AS  `main` ON  `main`.id =  `smf_rzr_api_member`.alt_of
* WHERE  `smf_rzr_api_member`.alt_of !=0
**/

$chars_to_send=[];


$request = 'SELECT `char`.memberName AS char_name, `char`.id_eve AS char_id, `main`.id_eve AS main_id,  `main`.memberName AS main_name FROM  `{db_prefix}rzr_api_member` as `char` LEFT OUTER JOIN  `{db_prefix}rzr_api_member` AS  `main` ON  `main`.id =   `char`.alt_of WHERE   `char`.alt_of !=0';
$request = $smcFunc['db_query']('', $request, false, false);
if ($smcFunc['db_num_rows']($request) > 0) {
  while( $row = $smcFunc['db_fetch_assoc']($request) ){
    $chars_to_send[] = $row;
  }
}

$json_to_send = json_encode( array("characters"=>$chars_to_send) );

// print $json_to_send;
// print "\r\n";

$header = array();
$ch = curl_init();
//set options
curl_setopt($ch, CURLOPT_URL, 'http://46.101.77.93/api/v1/characters');
//curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_HTTPHEADER, $headers); 
curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json','Authorization: Token '. 'd117C96w8z853vF8664T8wj40Y1N67Qz9TP70xpq1y6484br3z3330Ei7nO51ShS')); 
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "POST");
curl_setopt($ch, CURLOPT_POSTFIELDS, $json_to_send); 

$data = curl_exec($ch); 

if ( curl_errno($ch) ) { 
  print "Error: " . curl_error($ch); 
} else { 
  // Show me the result 
  var_dump($data); 
  //curl_close($ch); 
} 
