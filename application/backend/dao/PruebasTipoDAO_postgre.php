<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de los tipos de pruebas.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: PruebasTipoDAO_postgre.php 75 2014-03-09 10:25:12Z aranape $
 * @history ''
 *
 * $Date: 2014-03-09 05:25:12 -0500 (dom, 09 mar 2014) $
 * $Rev: 75 $
 */
class PruebasTipoDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

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
        return 'delete from tb_pruebas_tipo where pruebas_tipo_codigo = \'' . $id . '\'  and xmin =' . $versionId;
    }

    /**
     * @see \TSLBasicRecordDAO::getAddRecordQuery()
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
        /* @var $record  PruebasTipoModel  */
        return 'insert into tb_pruebas_tipo (pruebas_tipo_codigo,pruebas_tipo_descripcion,activo,usuario) values(\'' .
                $record->get_pruebas_tipo_codigo() . '\',\'' .
                $record->get_pruebas_tipo_descripcion() . '\',\'' .
                $record->getActivo() . '\',\'' .
                $record->getUsuario() . '\')';
    }

    /**
     * @see \TSLBasicRecordDAO::getFetchQuery()
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {
        // Si la busqueda permite buscar solo activos e inactivos
        $sql = 'select pruebas_tipo_codigo,pruebas_tipo_descripcion,activo,xmin as "versionId" from  tb_pruebas_tipo ';

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
        return 'select pruebas_tipo_codigo,pruebas_tipo_descripcion,activo,' .
                'xmin as "versionId" from tb_pruebas_tipo where "pruebas_tipo_codigo" =  \'' . $code . '\'';
    }

    /**
     * Aqui el id es el codigo
     * @see \TSLBasicRecordDAO::getUpdateRecordQuery()
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) {
        /* @var $record  PruebasTipoModel  */
        return 'update tb_pruebas_tipo set pruebas_tipo_codigo=\'' . $record->get_pruebas_tipo_codigo() . '\','.
                'pruebas_tipo_descripcion=\'' . $record->get_pruebas_tipo_descripcion() . '\',' .
                'activo=\'' . $record->getActivo() . '\',' .
                'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
                ' where "pruebas_tipo_codigo" = \'' . $record->get_pruebas_tipo_codigo() . '\'  and xmin =' . $record->getVersionId();
    }

}

?>