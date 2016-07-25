<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de las unidades de medida.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: UnidadMedidaDAO_postgre.php 136 2014-04-07 00:31:52Z aranape $
 * @history ''
 *
 * $Date: 2014-04-06 19:31:52 -0500 (dom, 06 abr 2014) $
 * $Rev: 136 $
 */
class UnidadMedidaDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

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
        return 'delete from tb_unidad_medida where unidad_medida_codigo = \'' . $id . '\'  and xmin =' . $versionId;
    }

    /**
     * @see \TSLBasicRecordDAO::getAddRecordQuery()
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
        /* @var $record  UnidadMedidaModel  */
        return 'insert into tb_unidad_medida (unidad_medida_codigo,unidad_medida_descripcion,unidad_medida_siglas,'
        . 'unidad_medida_tipo,activo,usuario) values(\'' .
                $record->get_unidad_medida_codigo() . '\',\'' .
                $record->get_unidad_medida_descripcion() . '\',\'' .
                $record->get_unidad_medida_siglas() . '\',\'' .
                $record->get_unidad_medida_tipo() . '\',\'' .
                $record->getActivo() . '\',\'' .
                $record->getUsuario() . '\')';
    }

    /**
     * @see \TSLBasicRecordDAO::getFetchQuery()
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {
        // Si la busqueda permite buscar solo activos e inactivos
        $sql = 'select unidad_medida_codigo,unidad_medida_siglas,unidad_medida_descripcion,unidad_medida_tipo,unidad_medida_protected,activo,xmin as "versionId" from  tb_unidad_medida ';

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
    protected function getRecordQuery($id, $subOperation = NULL) {
        // en este caso el codigo es la llave primaria
        return $this->getRecordQueryByCode($id, $subOperation );
    }

    /**
     * @see \TSLBasicRecordDAO::getRecordQueryByCode()
     */
    protected function getRecordQueryByCode($code, $subOperation = NULL) {
        return 'select unidad_medida_codigo,unidad_medida_siglas,unidad_medida_descripcion,unidad_medida_tipo,unidad_medida_protected,activo,' .
                'xmin as "versionId" from tb_unidad_medida where "unidad_medida_codigo" =  \'' . $code . '\'';
    }

    /**
     * Aqui el id es el codigo
     * @see \TSLBasicRecordDAO::getUpdateRecordQuery()
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) {
        /* @var $record  UnidadMedidaModel  */
        return 'update tb_unidad_medida set unidad_medida_codigo=\'' . $record->get_unidad_medida_codigo() . '\','.
                'unidad_medida_descripcion=\'' . $record->get_unidad_medida_descripcion() . '\',' .
                'unidad_medida_siglas=\'' . $record->get_unidad_medida_siglas() . '\',' .
                'unidad_medida_tipo=\'' . $record->get_unidad_medida_tipo(). '\',' .
                'activo=\'' . $record->getActivo() . '\',' .
                'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
                ' where "unidad_medida_codigo" = \'' . $record->get_unidad_medida_codigo() . '\'  and xmin =' . $record->getVersionId();
    }

}

?>