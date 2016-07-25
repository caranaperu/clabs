<?php

/**
 * Procesador default para filtros de query basado en JSON.
 * 
 * @author		Carlos Arana Reategui.
 * @license		GPL
 * @since		Version 1.0
 */
class TSLFilterProcessorJson implements TSLIParametersProcessor {

    /**
     * Parseara el parametor el cual debera tener la forma siguiente :
     * [{"property":"nombre_campo1","value":"valor_campo_1"},
     *  {"property":"nombre_campo2","value":"valor_campo_2"}]
     * 
     * Donde cada elemento del arreglo representa el campo y su valor a 
     * aplicar al fitro.
     * 
     * @param type $filterData un texto que representa un arreglo de elementos 
     * JSON de acuerdo a la documentacion.
     */
    public function process($filterData) {
        $answer = array();
        // Si el parametro no es valido retornamos un arreglo en blanco
        if (!isset($filterData) || is_null($filterData)) {
            return $answer;
        }

        // Decodificamos
        $fltconvert = json_decode($filterData, true);

        //var_dump(json_last_error());
        //
        // Si no ha habido errores continuamos
        if (json_last_error() == JSON_ERROR_NONE) { 
            // Si hay respuestas contimuamos
            if (isset($fltconvert) and is_array($fltconvert)) {
                if (count($fltconvert) > 0) {
                    // Estraemos los resultados y los pasamos a una forma simplificada
                    // de arreglo asociativo
                    foreach ($fltconvert as $filterpair) {
                        // Convertimos a un arregloo asociativo de campo y valor
                        $answer[$filterpair['property']] = $filterpair['value'];
                        unset($filterpair);
                    }
                }
                unset($fltconvert);
            }
        }
       // var_dump($answer);
        return $answer;
    }

}

?>
