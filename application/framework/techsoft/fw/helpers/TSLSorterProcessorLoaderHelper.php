<?php

/**
 * TSL framework helper que carga un especifico procesador
 * de los campos de sort enviados a un query segun los tipos soportados
 * como json,xml,csv.
 * 
 * IMPORTANTE: por ahora solo existe filtro implemetado para json.
 *
 * @author		Carlos Arana Reategui.
 * @license		GPL
 * @since		Version 1.0
 */
class TSLSorterProcessorLoaderHelper {

    private static $supported_filters = array('json', 'xml', 'csv');

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
     * @param $sorter_basename , El nombre base del sorter , por ejemplo "pfilter" que es el defualt
     * para el nombre base de un filtro.
     *
     * @param $sorter_id , el identificador del tipo de sorter tales como  : 'json',
     * 'csv','xml'. De no indicarse se tratara de cargar la generica para json, 
     *
     * @return TSLIFilterProcessor una referencia al Procesador de Filtros o una 
     * excepcion de programacion si el untipo de filtro no esta soportado soportada
     *
     */
    public static function loadSorterProcessor($sorter_basename = null, $sorter_id = null) {
        //$defaultDBDriver = TSLUtilsHelper::getDefaultDatabaseDriver();

        $isUserFilter = true;

        // Si no hay tipo de filtro definido usamos JSON por default
        if (!isset($sorter_id) || is_null($sorter_id)) {
            $sorter_id = 'json';
        }

        // Si no hay nombre base de procesador de filtro usamos los predefinidos
        // de lo contrario se respetara el del usuario.
        if (!isset($sorter_basename) || is_null($sorter_basename)) {
            $sorter_basename = 'TSLSorterProcessor';
            $isUserFilter = false;
        }


        // Si se ha indicado tipo de filtro vemos que este entre los permitidos.
        if (isset($sorter_id) and in_array($sorter_id, self::$supported_filters) == FALSE) {
            $backtrace = debug_backtrace();
            throw new TSLProgrammingException($sorter_id . ' tipo de filtro no soportado , Source= ' . $backtrace[0]['file'] . '-(' . $backtrace[0]['line'] . ')');
        } else {
            // Si es un procesador de usuario lo incluimos , debemos decir
            // que los sorters de usuario deberan estar en el APPPATH dentro del directorio 
            // request/sorters y el nombre del archivo y clase deberan estar compuestos por el nombre
            // base seguido del tipo de Filtro  con la primera letra capitalizada.
            // Ejemplo : MiFiltroJson, MiSuperFiltroCsv , etc.
            if ($isUserFilter) {
                require_once(APPPATH . 'request/sorters/' . $sorter_basename . ucfirst($sorter_id) . EXT);
            }
            // Creamos la instancia del filtro.
            $sorter_basename .= ucfirst($sorter_id);
            return new $sorter_basename;
        }
    }

}

?>