<?php

/**
 * TSL framework helper que carga un especifico procesador
 * de los constraints enviados a un query segun los tipos soportados
 * como json,xml,csv.
 *
 * IMPORTANTE: por ahora solo existe filtro implemetado para json.
 *
 * @author		Carlos Arana Reategui.
 * @license		GPL
 * @since		Version 1.0
 */
class TSLConstraintProcessorLoaderHelper {

    private static $supported_formats = array('json', 'xml', 'csv');

    /**
     * Carga un procesador de filtros para el tipo de formato indicado, de no indicarse ningna
     * usara la implementacion en JSON.
     *
     * De especificarse el tipo de filtro de existir tratara de cargar la especifica.
     *
     * Los tipos de procesadores de filtro permitidos son:
     * 'json', 'xml','csv'
     *
     * Importante : Se asume que si se usan los filtros default , en el include paht default
     * deben estar la referencia a los mismos. (Por ahora estan en config.php).
     *
     * @param $processor_name , El nombre base del filtro , por ejemplo "pfilter" que es el defualt
     * para el nombre base de un filtro.
     *
     * @param $format_type , el identificador del tipo de filtro tales como  : 'json',
     * 'csv','xml'. De no indicarse se tratara de cargar la generica para json,
     *
     * @param string  $library_id Indica si usa un filtor especifico de libreria soportada
     * , de definirse este parametro este filtor debera existir en la libreria default.
     * Si se ha creado un caso especifico no soportado bastara indicar el primer parametro.
     *
     * @return \TSLIParametersProcessor una referencia al Procesador de Constraints o una
     * excepcion de programacion si el tipo de formato no esta soportado soportada
     *
     */
    public static function loadConstraintProcessor($processor_name = NULL, $format_type = NULL, $library_id = NULL) {

        $isUserProcessor = true;

        // Si no hay tipo de filtro definido usamos JSON por default
        if (!isset($format_type) || is_null($format_type)) {
            $format_type = 'json';
        }

        // Si no hay nombre base de procesador de filtro usamos los predefinidos
        // de lo contrario se respetara el del usuario.
        if (!isset($processor_name) || is_null($processor_name)) {
            $processor_name = 'TSLConstraintProcessor';
            $isUserProcessor = false;
        }

        if ($library_id == NULL) {
            $library_id = '';
        }

        // Si se ha indicado tipo de filtro vemos que este entre los permitidos.
        if (isset($format_type) and in_array($format_type, self::$supported_formats) == FALSE) {
            $backtrace = debug_backtrace();
            throw new TSLProgrammingException($format_type . ' tipo de filtro no soportado , Source= ' . $backtrace[0]['file'] . '-(' . $backtrace[0]['line'] . ')');
        } else {
            // Si es un procesador de usuario lo incluimos , debemos decir
            // que los filtros de usuario deberan estar en el APPPATH dentro del directorio
            // request/processors y el nombre del archivo y clase deberan estar compuestos por el nombre
            // base seguido del tipo de Filtro  con la primera letra capitalizada.
            // Ejemplo : MiFiltroJson, MiSuperFiltroCsv , etc.
            if ($isUserProcessor) {
                require_once(APPPATH . 'request/processor/' . $processor_name . ucfirst($format_type) . EXT);
                $processor_name .= ucfirst($format_type);
            } else {
                $processor_name .= ucfirst(strtolower($library_id)).ucfirst($format_type);
            }
            return new $processor_name;
        }
    }

}

?>