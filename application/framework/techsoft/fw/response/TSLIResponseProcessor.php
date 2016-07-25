<?php

/**
 * Define los metodos a implementar para un procesador de salida
 * de los datos a enviar al cliente.
 *
 * @author		Carlos Arana Reategui.
 * @license		GPL
 * @since		Version 1.0
 */
interface TSLIResponseProcessor {

    /**
     * Funcion a implementar para procesar los datos de salida
     * de acuerdo a los diversos formatos.
     *
     * @param TSLIDataTransferObj &$DTO objeto data transfer object procesado
     * conteniendo las respuestas.
     *
     * @return Object con los resultados
     */
    public function &process(TSLIDataTransferObj &$DTO);
}

?>