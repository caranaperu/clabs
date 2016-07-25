<?php

/**
 * TSL framework helper que carga un especifico DAO
 * para una determinada base de datos.
 *
 * @author		Carlos Arana Reategui.
 * @license		GPL
 * @since		Version 1.0
 */
class TSLDAOLoaderHelper {

    private static $supported_dbs = array('postgre', 'mysql', 'mssql', 'oci8', 'sqllite', 'odbc');

    /**
     * Carga un DAO para la base de datos indicada , de no indicarse ningna buscara un
     * DAO para la base de datos default en uso , previamente tratara de ver s hay
     * un DAO generico .
     *
     * Osea de no indicarse el tipo de base de datos , tratara primero con la generica
     * (osea sin base de datos especificada) , luego tratara con la default de no encontrarla
     * indicara error.
     *
     * De especificarse el tipo de base de datos solo tratara de cargar la especifica.
     *
     * Las bases de datos permitidas son:
     * 'pgsql', 'mysql','mssql','oci8','sqllite' or 'odbc'.
     *
     * IMPORTANTE :
     * Las siguientes condiciones previas deben cumplirse :
     * 1) La constante APPPATH debe estar definida
     * 2) El arreglo global G_DAOPATHS con la lista de directorios absolutos a los DAO
     * del sistema debe estar definida , esta lista sera la base de busqueda para encontrar
     * el archivo que contiene la clase basada en el parametro dao_basename
     *
     * 3) LEER !!! , el parametro dao base name debera tener indicado el namespace en el caso
     * que su namespace  no sea el default
     *
     * @param dao_basename , El nombre base del DAO , por ejemplo "Login" e incluira el namespace de
     * tenerlo.
     *
     * @param db_id , el identificador de la base de datos,los valores permitidos son : 'postgre',
     * 'mysql','mssql','oci8','sqllite' or 'odbc'. De no indicarse se tratara de cargar
     * la generica , luego la default.
     *
     * @return una referencia al DAO o una excepcion de programacion si se ha solicitado
     * un tipo de base de datos no soportada o alguna precondicion no se cumple.
     *
     *
     *
     */
    public static function loadDAO($dao_basename, $db_id = null) {
        global $G_DAOPATHS;
        $found = false;
        $dao_class = $dao_basename;

        /******************************************************************************
         * VALIDACIONES REQUISITOS PREVIOS
         */

        // Si no es una base de datos soportada enviamos excepcion.
        if (isset($db_id) and in_array($db_id, self::$supported_dbs) == FALSE) {
            $backtrace = debug_backtrace();
            throw new TSLProgrammingException($db_id . ' its not a supported Database , Source= ' . $backtrace[0]['file'] . '-(' . $backtrace[0]['line'] . ')');
        }

        // La variable G_DAOPATHS con los paths validos para los DAOs debe existir en las globalses
        if (!isset($G_DAOPATHS) || !is_array($G_DAOPATHS)) {
            $backtrace = debug_backtrace();
            throw new TSLProgrammingException('No se han definido los paths para los DAO o no se ha definido como array, Source= ' . $backtrace[0]['file'] . '-(' . $backtrace[0]['line'] . ')');
        }

        // La constante APPPATH tambien debe estar definida
        if (!defined ('APPPATH')) {
            $backtrace = debug_backtrace();
            throw new TSLProgrammingException('Debe definirse la constante APPPATH, Source= ' . $backtrace[0]['file'] . '-(' . $backtrace[0]['line'] . ')');
        }

        /***********************************************************************
         *  Proceso
         */
        $dao_basename_stripped = substr(($t = strrchr($dao_basename, '\\')) !== false ? $t : '', 1);
        if (!$dao_basename_stripped) {
            $dao_basename_stripped = $dao_basename;
        }

        $defaultDBDriver = TSLUtilsHelper::getDefaultDatabaseDriver();
        $dao = '';

        // Si esta seteada el tipo de base de datos buscamos exclusimanente un DAO basado
        // en dicha base de datos
        if (isset($db_id)) {
            $dao = $dao_basename_stripped . '_' . $db_id;
            $dao_class .= '_' . $db_id;
        } else {
            // Si no se ha definido una tratamos con el default driver si esta definido

            if (isset($defaultDBDriver)) {
                $dao = $dao_basename_stripped . '_' . $defaultDBDriver;
                $dao_class .= '_' . $defaultDBDriver;
            }
        }

        $daoFileName = '';

        // Si existe una db definida ya sea por parametro o default
        // buscamos si el dao existe para esa condicion.
        if ($dao !== '') {
            foreach ($G_DAOPATHS as $value) {
                if ($value != '') {
                    $daoFileName = APPPATH . $value . '/' . $dao . EXT;
                } else {
                    $daoFileName = APPPATH . $dao . EXT;
                }
                if (file_exists($daoFileName)) {
                    $found = TRUE;
                    break;
                }
            }
        }


        // Buscamos el default de no haberse encontrado ninguno en el paso anterior
        if ($found === FALSE) {
            $dao = $dao_basename_stripped;

            foreach ($G_DAOPATHS as $value) {
                if ($value != '') {
                    $daoFileName = APPPATH . $value . '/' . $dao . EXT;
                } else {
                    $daoFileName = APPPATH . $dao . EXT;
                }
                if (file_exists($daoFileName)) {
                    $found = TRUE;
                    break;
                }
            }
        }

        // Si se encontro efectuamos el include
        if ($found) {
            $ret = include_once ($daoFileName);
            if ($ret !== 1) {
                $found = false;
            }
        }

        if ($found == false) {
            $backtrace = debug_backtrace();
            throw new TSLProgrammingException('DAO : ' . $dao_basename . ' No se encuentra en una ruta esperada , Source= ' . $backtrace[0]['file'] . '-(' . $backtrace[0]['line'] . ')');
        } else {
            // instancamos la clase
            return new $dao_class;
        }
    }

}

?>