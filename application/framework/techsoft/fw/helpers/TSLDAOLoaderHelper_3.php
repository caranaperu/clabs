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
     * @param dao_basename , El nombre base del DAO , por ejemplo "Login"
     *
     * @param db_id , el identificador de la base de datos,los valores permitidos son : 'postgre',
     * 'mysql','mssql','oci8','sqllite' or 'odbc'. De no indicarse se tratara de cargar
     * la generica , luego la default.
     *
     * @return una referencia al DAO o una excepcion de programacion si se ha solicitado
     * un tipo de base de datos no soportada
     *
     *
     *
     */
    public static function loadDAO($dao_basename, $db_id = null) {
        // Los daos seran buscados en el APPPATH o en el equivalente a APPPATH_shared
        $applpath = substr(APPPATH, 0, strpos(APPPATH, '_')) . '/';
        $apppath_touse = $applpath;

        $applpath_alt = substr($applpath, 0, -1) . '_shared/';
        // Libreria base como ultimo recurrso
        $libdaopath = 'application/framework/techsoft/fw/app/dao/impl/';
        $applpath_exist = false;
        $applpath_alt_exist = false;
        // el calss base por si se usa un namespace
        $daoclass = '';


        $defaultDBDriver = TSLUtilsHelper::getDefaultDatabaseDriver();

        // Si el identificador de base de datos no esta definido y si se ha definido el default
        // db driver :
        // 1: Buscamops si existe un dao para la base de datos default.
        // 2: de lo contrario buscaremos el generico
        if (isset($db_id) == FALSE and isset($defaultDBDriver)) {

            if (file_exists($applpath . 'dao/' . $dao_basename . EXT)) {
                $applpath_exist = true;
            } else if (file_exists($applpath_alt . 'dao/' . $dao_basename . EXT)) {
                $applpath_alt_exist = true;
                $apppath_touse = $applpath_alt;
                $daoclass = 'shared\\dao\\';
            } else if (file_exists($libdaopath  . $dao_basename . EXT)) {
                $daoclass = 'app\\common\\dao\\impl\\';
                $applpath_alt_exist = true;
            }

            // Vemos si existe un DAO generico
            // de no existir cambio el id de la db a tartar de cargar al default
            // definido.
            if (!$applpath_exist && !$applpath_alt_exist) {
                $db_id = $defaultDBDriver;

                // Verificamos si existe en el directorio shared de la aplicacion
                // sino se asume en la misma aplicacion
                if (file_exists($applpath_alt . 'dao/' . $dao_basename . '_' . $db_id . EXT)) {
                    $apppath_touse = $applpath_alt. 'dao/';
                    $daoclass = 'shared\\dao\\';
                } else if (file_exists($libdaopath . $dao_basename . '_' . $db_id . EXT)) {
                    $apppath_touse = $libdaopath;
                    $daoclass = 'app\\common\\dao\\impl\\';
                }
            } else {
                unset($db_id);
            }
        }

        // Si se ha indicado tipo de base de datos vemos si esta permitida.
        if (isset($db_id) and in_array($db_id, self::$supported_dbs) == FALSE) {
            $backtrace = debug_backtrace();
            throw new TSLProgrammingException($db_id . ' its not a supported Database , Source= ' . $backtrace[0]['file'] . '-(' . $backtrace[0]['line'] . ')');
        } else if ($daoclass === '') {
            $backtrace = debug_backtrace();
            throw new TSLProgrammingException('DAO : ' . $dao_basename . ' No se encuentra en una ruta esperada , Source= ' . $backtrace[0]['file'] . '-(' . $backtrace[0]['line'] . ')');
        } else {
            $daoclass .= $dao_basename;
            // Trato de cargar uno especifico o un generico.
            if (isset($db_id)) {
                $daoclass .= '_' . $db_id;
                require_once($apppath_touse . $dao_basename . '_' . $db_id . EXT);
                return new $daoclass;
            } else {
                require_once($apppath_touse .  $dao_basename . EXT);
                return new $daoclass;
            }
        }
    }

}

?>