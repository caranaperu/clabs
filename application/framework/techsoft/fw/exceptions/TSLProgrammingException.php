<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Define las excepciones derivadas de errores de programacion o
 * php , normalmente el php emite estos como errores simples
 * y aparecen en la pantalla , la idea es que la aplicacion capture
 * esta informacion y la convierta en una excepcion para que siga
 * la ruta normal que el framework espera y pueda enviar al cliente
 * dicho error como parte del mensaje de salida.
 *
 * @author Carlos Arana Reategui
 * @version 1.00 , 28 MAY 2011
 * @history Modificado 27 MAY 2011 , para TECHSOFT
 *
 */
class TSLProgrammingException extends TSLGenericException {

    /**
     * Constructor , soporte el tener alguna data
     * que pueda 
     */
    public function __construct($message = NULL, $code = 0) {
        parent::__construct($message, $code);
    }

}
?>