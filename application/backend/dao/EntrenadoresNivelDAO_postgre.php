<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de los paises al sistema.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: EntrenadoresNivelDAO_postgre.php 66 2014-03-09 10:16:37Z aranape $
 * @history ''
 *
 * $Date: 2014-03-09 05:16:37 -0500 (dom, 09 mar 2014) $
 * $Rev: 66 $
 */
class EntrenadoresNivelDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

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
        return 'delete from tb_entrenadores_nivel where entrenadores_nivel_codigo = \'' . $id . '\'  and xmin =' . $versionId;
    }

    /**
     * @see TSLBasicRecordDAO::getAddRecordQuery()
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
        /* @var $record  EntrenadoresNivelModel  */
        return 'insert into tb_entrenadores_nivel (entrenadores_nivel_codigo,entrenadores_nivel_descripcion,activo,usuario) values(\'' .
                $record->get_entrenadores_nivel_codigo() . '\',\'' .
                $record->get_entrenadores_nivel_descripcion() . '\',\'' .
                $record->getActivo() . '\',\'' .
                $record->getUsuario() . '\')';
    }

    /**
     * @see TSLBasicRecordDAO::getFetchQuery()
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {
        // Si la busqueda permite buscar solo activos e inactivos
        $sql = 'select entrenadores_nivel_codigo,entrenadores_nivel_descripcion,entrenadores_nivel_protected,activo,xmin as "versionId" from  tb_entrenadores_nivel ';

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
        return 'select entrenadores_nivel_codigo,entrenadores_nivel_descripcion,entrenadores_nivel_protected,activo,' .
                'xmin as "versionId" from tb_entrenadores_nivel where "entrenadores_nivel_codigo" =  \'' . $code . '\'';
    }

    /**
     * Aqui el id es el codigo
     * @see TSLBasicRecordDAO::getUpdateRecordQuery()
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) {
        /* @var $record  EntrenadoresNivelModel  */
        return 'update tb_entrenadores_nivel set entrenadores_nivel_codigo=\'' . $record->get_entrenadores_nivel_codigo() . '\',' .
                'entrenadores_nivel_descripcion=\'' . $record->get_entrenadores_nivel_descripcion() . '\',' .
                'activo=\'' . $record->getActivo()  . '\',' .
                'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
                ' where "entrenadores_nivel_codigo" = \'' . $record->get_entrenadores_nivel_codigo() . '\'  and xmin =' . $record->getVersionId();
    }

}

?>