<?php

/**
 * Interfase que define lo s minimos requerimientos a implementar que define 
 * el error derivado del proceso de una accion
 * invocada por el bussiness service , 
 *
 * @author Carlos Arana Reategui
 * @version 1.00 , 27 MAY 2011
 * 
 * @since 1.00
 *
 */
class TSLProcessErrorMessage extends TSLBaseMessage {

    /**
     * La exception en caso que exista una.
     * 
     * @var Exception m_exception
     */
    private $m_exception;

    /**
     * El codigo de Error
     * @var int m_errorCode
     */
    private $m_errorCode = 0;    

    /**
     * Cosntructor de un mensaje de error de proceso, el mismo que al 
     * menos debe tener especificado el codigo de error , el cual debe
     * ser unico a traves de todo el sistema.
     * 
     * @param int $errorCode el codigo de error , debe ser > 0
     * @param string $errorMessage, opcional y puede ser seteado luego 
     * con el metodo setErrorMessage(), de esta forma se permitira su 
     * internacionalizacion posteriormente.
     * 
     * @param Exception $exception en caso el error provenga de una excepcion
     * 
     */
    public function __construct($errorCode, $errorMessage=null, Exception $exception=null) {
        parent::__construct( $errorMessage);
        $this->m_errorCode = $errorCode;
        $this->m_exception = $exception;
    }

    
    /**
     * Retorna la excepcion que provoco el error de proceso.
     * 
     * @return Exception con la excepccion provocada pro el proceso.
     */
    public function getException() {
        return $this->m_exception;
    }
    
    /**
     * Retorna el codigo de error.
     * 
     * @return int el codigo de error 
     */
    public function getErrorCode() {
        return $this->m_errorCode;
    }    
    
}

?>