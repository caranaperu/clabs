<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
 * This class define the main class for all db exceptions, support to put some data
 * on the exception , for example a current value of a record.
 * Esa clase define la excepcion base para errores en base de datos.
 *
 * @author Carlos Arana Reategui
 * @version 1.00 , 15 JUL 2009
 * @history Modificado 27 MAY 2011 , para TECHSOFT
 *
 */
class TSLDbException extends TSLGenericException {
    private $_data;
    
    /**
     * Constructor , soporte el tener alguna data
     * que pueda servir para mayor informacion.
     *
     * @param string $message
     * @param int $code
     * @param Mixed $data 
     */
    public function __construct($message = NULL, $code = 0,$data = NULL)
    {
        parent::__construct($message, $code);
        $this->_data = $data;
    }

    /**
     * Retorna la data contenida en la excepcion.
     * @return Mixed  
     */
    public function getData() {
        return $this->_data;
    }
}
/**/
