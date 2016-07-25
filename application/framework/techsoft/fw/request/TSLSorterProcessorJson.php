<?php

/**
 * Procesador default para los campos de sort de query basado en JSON.
 * 
 * @author		Carlos Arana Reategui.
 * @license		GPL
 * @since		Version 1.0
 */
class TSLSorterProcessorJson implements TSLIParametersProcessor {

    /**
     * Parseara el parametor el cual debera tener la forma siguiente :
     * [{"property":"nombre_campo1","value":"ASC | DESC"},
     *  {"property":"nombre_campo2","value":"ASC | DESC"}]
     * 
     * Donde cada elemento del arreglo representa el campo y su el tipo
     * de filto a aplicar.
     * 
     * @param type $sorterData un texto que representa un arreglo de elementos 
     * JSON de acuerdo a la documentacion.
     */
    public function process($sorterData) {
        $answer = array();
        // Si el parametro no es valido retornamos un arreglo en blanco
        if (!isset($sorterData) || is_null($sorterData)) {
            return $answer;
        }

        // Decodificamos
        $fltconvert = json_decode($sorterData, true);

        //var_dump(json_last_error());
        //
        // Si no ha habido errores continuamos
        if (json_last_error() == JSON_ERROR_NONE) { 
            // Si hay respuestas contimuamos
            if (isset($fltconvert) and is_array($fltconvert)) {
                if (count($fltconvert) > 0) {
                    // Estraemos los resultados y los pasamos a una forma simplificada
                    // de arreglo asociativo
                    foreach ($fltconvert as $sotrterpair) {
                        // Convertimos a un arregloo asociativo de campo y valor
                        $answer[$sotrterpair['property']] = $sotrterpair['direction'];
                        unset($sotrterpair);
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
