<?php

/**
 * TSL framework helper que carga un especifico procesador
 * de los filtros enviados a un query segun los tipos soportados
 * como json,xml,csv.
 *
 * IMPORTANTE: por ahora solo existe filtro implemetado para json.
 *
 * @author		Carlos Arana Reategui.
 * @license		GPL
 * @since		Version 1.0
 */
class TSLFilterProcessorLoaderHelper {

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
     * @param filter_basename , El nombre base del filtro , por ejemplo "pfilter" que es el defualt
     * para el nombre base de un filtro.
     *
     * @param filter_id , el identificador del tipo de filtro tales como  : 'json',
     * 'csv','xml'. De no indicarse se tratara de cargar la generica para json,
     *
     * @param string  $library_id Indica si usa un filtor especifico de libreria soportada
     * , de definirse este parametro este filtor debera existir en la libreria default.
     * Si se ha creado un caso especifico no soportado bastara indicar el primer parametro.
     *
     * @return TSLIFilterProcessor una referencia al Procesador de Filtros o una
     * excepcion de programacion si el untipo de filtro no esta soportado soportada
     *
     */
    public static function loadFilterProcessor($filter_basename = NULL, $filter_id = NULL, $library_id = NULL) {
        //$defaultDBDriver = TSLUtilsHelper::getDefaultDatabaseDriver();

        $isUserFilter = true;

        // Si no hay tipo de filtro definido usamos JSON por default
        if (!isset($filter_id) || is_null($filter_id)) {
            $filter_id = 'json';
        }

        // Si no hay nombre base de procesador de filtro usamos los predefinidos
        // de lo contrario se respetara el del usuario.
        if (!isset($filter_basename) || is_null($filter_basename)) {
            $filter_basename = 'TSLFilterProcessor';
            $isUserFilter = false;
        }

        if ($library_id == NULL) {
            $library_id = '';
        }

        // Si se ha indicado tipo de filtro vemos que este entre los permitidos.
        if (isset($filter_id) and in_array($filter_id, self::$supported_filters) == FALSE) {
            $backtrace = debug_backtrace();
            throw new TSLProgrammingException($filter_id . ' tipo de filtro no soportado , Source= ' . $backtrace[0]['file'] . '-(' . $backtrace[0]['line'] . ')');
        } else {
            // Si es un procesador de usuario lo incluimos , debemos decir
            // que los filtros de usuario deberan estar en el APPPATH dentro del directorio
            // request/sorters y el nombre del archivo y clase deberan estar compuestos por el nombre
            // base seguido del tipo de Filtro  con la primera letra capitalizada.
            // Ejemplo : MiFiltroJson, MiSuperFiltroCsv , etc.
            if ($isUserFilter) {
                require_once(APPPATH . 'request/filters/' . $filter_basename . ucfirst($filter_id) . EXT);
                $filter_basename .= ucfirst($filter_id);
            } else {
                $filter_basename .= ucfirst(strtolower($library_id)).ucfirst($filter_id);
            }
            return new $filter_basename;
        }
    }

}

?>