<?php

/**
 * Clase base para los diferentes tipos de error ya sea por proceso , por validacion de modelos ,
 * validacion de campos etc, estos al menos deben contar con un  mensaje de error.
 *
 *
 * @author Carlos Arana Reategui
 * @version 1.00 , 2 JUN 2011
 *
 * @since 1.00
 *
 */
class TSLBaseMessage {


    /**
     * El Mensaje de error
     * @var string $m_errorMessage
     */
    private $m_errorMessage;


    /**
     * Cosntructor de un mensaje de error de campo, el mismo que al
     * menos debe tener especificado el codigo de error , el cual debe
     * ser unico a traves de todo el sistema y el campo que ocasiono
     * el error.
     *
     * @param string $errorMessage, opcional y puede ser seteado luego
     * con el metodo setErrorMessage(), de esta forma se permitira su
     * internacionalizacion posteriormente.
     *
     */
    public function __construct($errorMessage=null) {
        $this->setErrorMessage($errorMessage);

    }

    /**
     *Setea el mensaje de error , este metodo puede ser usado
     * para la internacionalizacion del sistema , delegando su
     * valor para setearlo basado en el errorCode segun una tabla
     * de lenguaje.
     *
     * @param string $errorMessage , mensaje de error
     */
    public function setErrorMessage($errorMessage) {
        $this->m_errorMessage = str_replace(array("\"","\r","\n","\r\n"), ' ',$errorMessage);
    }



    /**
     * Retorna mensaje de error.
     *
     * @return string retorna el mensaje de error
     */
    public function getErrorMessage() {
        return $this->m_errorMessage;
    }

}

?>

