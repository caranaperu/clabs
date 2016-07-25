<?php

/**
 * Clase que define el error derivado de la validacion de un modelo
 * o de los campos de entrada. Estos errores se componen de de un nombre
 * de campo,de un codigo de error y el mensaje de error.
 *
 * @author Carlos Arana Reategui
 * @version 1.00 , 2 JUN 2011
 * 
 * @since 1.00 
 *
 */
class TSLFieldErrorMessage extends TSLBaseMessage {

    /**
     *
     * @var string el nombre del campo sea de entrada o modelo.
     */
    private $m_field;
    


    /**
     * Cosntructor de un mensaje de error de campo, el mismo que al 
     * menos debe tener especificado el codigo de error , el cual debe
     * ser unico a traves de todo el sistema y el campo que ocasiono
     * el error.
     * 
     * @param string $field el nombre del campo con error.
     * @param string $errorMessage, opcional y puede ser seteado luego 
     * con el metodo setErrorMessage(), de esta forma se permitira su 
     * internacionalizacion posteriormente.
     * 
     */
    public function __construct($field, $errorMessage=null) {
        parent::__construct( $errorMessage);               
        $this->m_field = $field;
    }

    
    /**
     * Retorna el nombre del campo que provoco el error.
     * 
     * @return String con el nombre del campo, fuente del error.
     */
    public function getField() {
        return $this->m_field;
    }
}

?>