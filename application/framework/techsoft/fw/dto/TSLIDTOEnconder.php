<?php

/**
 * Interfase que define los metodos requeridos para generar el 
 * encode de un Data Transfer Object.
 * 
 * @author Carlos Arana Reategui
 * @version 1.00 , 27 MAY 2011
 * 
 * @since 1.00
 */
interface TSLIDTOEnconder {

    /**
     * Metodo a implementar para generar la salida del DTO,
     * podria ser salida a XML,JSON,etc
     * 
     * @param TSLIDataTransferObj con el Data Transfer Object a procesar
     * @return un Objeto con el formato de salida , un String con el JSON por 
     * ejemplo.
     */
    public function encode(TSLIDataTransferObj $DTO);
}

?>