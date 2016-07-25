<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');



    /**
     * This class defines the default library class exception, ensure
     * an error with the class.
     * Esta clase define la clase que manejara las excepciones, garantozando que
     * siempre se de un texto de error al menos
     *
     *
     * @author Carlos Arana Reategui
     * @version 1.00 , 15 JUL 2009
     * @history : Modificado 27-05-2010 para TECHSOFT
     * @package techsoft.fw
     *
     */
    class TSLGenericException extends Exception {

        public function __construct($message = null, $code = 0) {
            if (!$message && (!$code or $code == 0)) {
                throw new $this(get_class($this).'-> Error de Constructor indique $message o $code' );
            }
            parent::__construct($message, $code);
        }



}
/* End of file TSLGenericExecption.php */