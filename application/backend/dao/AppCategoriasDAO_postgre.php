<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de los valores de validacion para las categorias
 * de atletas , digase mayores , menores , etc , donde se indicara el peso relativo de una
 * con la otra , digamos pesara mas la que su record sea de mayor valor , por ejemplo mayores pesara mas que menores.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: AppCategoriasDAO_postgre.php 68 2014-03-09 10:19:20Z aranape $
 * @history ''
 *
 * $Date: 2014-03-09 05:19:20 -0500 (dom, 09 mar 2014) $
 * $Rev: 68 $
 */
class AppCategoriasDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

    /**
     * Constructor se puede indicar si las busquedas solo seran en registros activos.
     * @param boolean $activeSearchOnly
     */
    public function __construct($activeSearchOnly = TRUE) {
        parent::__construct($activeSearchOnly);
    }

    /**
     * @see \TSLBasicRecordDAO::getDeleteRecordQuery()
     */
    protected function getDeleteRecordQuery($id, $versionId) {
        return null;
    }

    /**
     * @see \TSLBasicRecordDAO::getAddRecordQuery()
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
        /* @var $record  AppCategoriasModel  */
        return null;
    }

    /**
     * @see \TSLBasicRecordDAO::getFetchQuery()
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {
        // Si la busqueda permite buscar solo activos e inactivos
        $sql = 'select appcat_codigo,appcat_peso,activo,xmin as "versionId" from  tb_app_categorias_values ';

        if ($this->activeSearchOnly == TRUE) {
            // Solo activos
            $sql .= ' where "activo"=TRUE ';
        }

        $where = $constraints->getFilterFieldsAsString();
        if (strlen($where) > 0) {
            $sql .= ' and ' . $where;
        }

        if (isset($constraints)) {
            $orderby = $constraints->getSortFieldsAsString();
            if ($orderby !== NULL) {
                $sql .= ' order by ' . $orderby;
            }
        }

        return $sql;
    }

    /**
     * @see \TSLBasicRecordDAO::getRecordQuery()
     */
    protected function getRecordQuery($id) {
        // en este caso el codigo es la llave primaria
        return $this->getRecordQueryByCode($id);
    }

    /**
     * @see \TSLBasicRecordDAO::getRecordQueryByCode()
     */
    protected function getRecordQueryByCode($code) {
        return 'select appcat_codigo,appcat_peso,activo,' .
                'xmin as "versionId" from tb_app_categorias_values where "appcat_codigo" =  \'' . $code . '\'';
    }

    /**
     * Aqui el id es el codigo
     * @see \TSLBasicRecordDAO::getUpdateRecordQuery()
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) {
        /* @var $record  AppCategoriasModel  */
        return NULL;
    }

}

?>