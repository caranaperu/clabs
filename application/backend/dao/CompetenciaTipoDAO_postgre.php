<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de los tipos de competencia.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: CompetenciaTipoDAO_postgre.php 70 2014-03-09 10:20:51Z aranape $
 * @history ''
 *
 * $Date: 2014-03-09 05:20:51 -0500 (dom, 09 mar 2014) $
 * $Rev: 70 $
 */
class CompetenciaTipoDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

    /**
     * Constructor se puede indicar si las busquedas solo seran en registros activos.
     * @param boolean $activeSearchOnly
     */
    public function __construct($activeSearchOnly = TRUE) {
        parent::__construct($activeSearchOnly);
    }

    /**
     * {@inheritdoc}
     * @see TSLBasicRecordDAO::getDeleteRecordQuery()
     */
    protected function getDeleteRecordQuery($id, $versionId) {
        return 'delete from tb_competencia_tipo where competencia_tipo_codigo = \'' . $id . '\'  and xmin =' . $versionId;
    }

    /**
     * @see TSLBasicRecordDAO::getAddRecordQuery()
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
        /* @var $record  CompetenciaTipoModel  */
        $sql = 'insert into tb_competencia_tipo (competencia_tipo_codigo,competencia_tipo_descripcion,activo,usuario) values(\'' .
                $record->get_competencia_tipo_codigo() . '\',\'' .
                $record->get_competencia_tipo_descripcion() . '\',\'' .
                $record->getActivo() . '\',\'' .
                $record->getUsuario() . '\')';
        return $sql;
    }

    /**
     * @see TSLBasicRecordDAO::getFetchQuery()
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {
        // Si la busqueda permite buscar solo activos e inactivos
        $sql = 'select competencia_tipo_codigo,competencia_tipo_descripcion,activo,xmin as "versionId" from  tb_competencia_tipo ';

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
     * @see TSLBasicRecordDAO::getRecordQuery()
     */
    protected function getRecordQuery($id) {
        // en este caso el codigo es la llave primaria
        return $this->getRecordQueryByCode($id);
    }

    /**
     * @see TSLBasicRecordDAO::getRecordQueryByCode()
     */
    protected function getRecordQueryByCode($code) {
        return 'select competencia_tipo_codigo,competencia_tipo_descripcion,activo,' .
                'xmin as "versionId" from tb_competencia_tipo where "competencia_tipo_codigo" =  \'' . $code . '\'';
    }

    /**
     * Aqui el id es el codigo
     * @see TSLBasicRecordDAO::getUpdateRecordQuery()
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) {
        /* @var $record  CompetenciaTipoModel  */
        $sql = 'update tb_competencia_tipo set competencia_tipo_codigo=\'' . $record->get_competencia_tipo_codigo() . '\',' .
                'competencia_tipo_descripcion=\'' . $record->get_competencia_tipo_descripcion() . '\',' .
                'activo=\'' . $record->getActivo() . '\',' .
                'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
                ' where "competencia_tipo_codigo" = \'' . $record->get_competencia_tipo_codigo() . '\'  and xmin =' . $record->getVersionId();

        return $sql;
    }

}

?>