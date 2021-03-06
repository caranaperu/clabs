<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de los tipos de empresas.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: TipoEmpresaDAO_postgre.php 136 2014-04-07 00:31:52Z aranape $
 * @history ''
 *
 * $Date: 2014-04-06 19:31:52 -0500 (dom, 06 abr 2014) $
 * $Rev: 136 $
 */
class TipoEmpresaDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

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
        return 'delete from tb_tipo_empresa where tipo_empresa_codigo = \'' . $id . '\'  and xmin =' . $versionId;
    }

    /**
     * @see \TSLBasicRecordDAO::getAddRecordQuery()
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
        /* @var $record  MonedaModel  */
        return 'insert into tb_tipo_empresa (tipo_empresa_codigo,tipo_empresa_descripcion,'
        . 'activo,usuario) values(\'' .
                $record->get_tipo_empresa_codigo() . '\',\'' .
                $record->get_tipo_empresa_descripcion() . '\',\'' .
                $record->getActivo() . '\',\'' .
                $record->getUsuario() . '\')';
    }

    /**
     * @see \TSLBasicRecordDAO::getFetchQuery()
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {
        // Si la busqueda permite buscar solo activos e inactivos
        $sql = 'select tipo_empresa_codigo,tipo_empresa_descripcion,activo,xmin as "versionId" from  tb_tipo_empresa ';

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
    protected function getRecordQuery($id,\TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {
        // en este caso el codigo es la llave primaria
        return $this->getRecordQueryByCode($id,$constraints, $subOperation);
    }

    /**
     * @see \TSLBasicRecordDAO::getRecordQueryByCode()
     */
    protected function getRecordQueryByCode($code,\TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {
        return 'select tipo_empresa_codigo,tipo_empresa_descripcion,activo,' .
                'xmin as "versionId" from tb_tipo_empresa where "tipo_empresa_codigo" =  \'' . $code . '\'';
    }

    /**
     * Aqui el id es el codigo
     * @see \TSLBasicRecordDAO::getUpdateRecordQuery()
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) {
        /* @var $record  MonedaModel  */
        return 'update tb_tipo_empresa set tipo_empresa_codigo=\'' . $record->get_tipo_empresa_codigo() . '\','.
                'tipo_empresa_descripcion=\'' . $record->get_tipo_empresa_descripcion() . '\',' .
                'activo=\'' . $record->getActivo() . '\',' .
                'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
                ' where "tipo_empresa_codigo" = \'' . $record->get_tipo_empresa_codigo() . '\'  and xmin =' . $record->getVersionId();
    }

}

?>