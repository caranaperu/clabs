<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

/*
|--------------------------------------------------------------------------
| File and Directory Modes
|--------------------------------------------------------------------------
|
| These prefs are used when checking and setting modes when working
| with the file system.  The defaults are fine on servers with proper
| security, but you may wish (or even need) to change the values in
| certain environments (Apache running a separate process for each
| user, PHP under CGI with Apache suEXEC, etc.).  Octal values should
| always be used to set the mode correctly.
|
*/
define('FILE_READ_MODE', 0644);
define('FILE_WRITE_MODE', 0666);
define('DIR_READ_MODE', 0755);
define('DIR_WRITE_MODE', 0777);

/*
|--------------------------------------------------------------------------
| File Stream Modes
|--------------------------------------------------------------------------
|
| These modes are used when working with fopen()/popen()
|
*/

define('FOPEN_READ',							'rb');
define('FOPEN_READ_WRITE',						'r+b');
define('FOPEN_WRITE_CREATE_DESTRUCTIVE',		'wb'); // truncates existing file data, use with care
define('FOPEN_READ_WRITE_CREATE_DESTRUCTIVE',	'w+b'); // truncates existing file data, use with care
define('FOPEN_WRITE_CREATE',					'ab');
define('FOPEN_READ_WRITE_CREATE',				'a+b');
define('FOPEN_WRITE_CREATE_STRICT',				'xb');
define('FOPEN_READ_WRITE_CREATE_STRICT',		'x+b');


define('DB_OP_OK',0);
define('DB_ERR_ALLOK',-100000);
define('DB_ERR_SERVERNOTFOUND',-100001);
define('DB_ERR_RECORDNOTFOUND',-100002);
define('DB_ERR_RECORDNOTDELETED',-100003);
define('DB_ERR_RECORDEXIST',-100004);
define('DB_ERR_FOREIGNKEY',-100005);
define('DB_ERR_CANTEXECUTE',-100006);
define('DB_ERR_RECORD_MODIFIED',-100007);
define('DB_ERR_RECORDINACTIVE',-100008);
define('DB_ERR_DUPLICATEKEY',-100009);

/* End of file constants.php */
/* Location: ./application/config/constants.php */