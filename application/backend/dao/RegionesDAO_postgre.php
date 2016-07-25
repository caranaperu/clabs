<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de las regiones atleticas al sistema.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: RegionesDAO_postgre.php 275 2014-06-27 22:29:31Z aranape $
 * @history ''
 *
 * $Date: 2014-06-27 17:29:31 -0500 (vie, 27 jun 2014) $
 * $Rev: 275 $
 */
class RegionesDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

    /**
     * Constructor se puede indicar si las busquedas solo seran en registros activos.
     * @param boolean $activeSearchOnly
     */
    public function __construct($activeSearchOnly = TRUE) {
        parent::__construct($activeSearchOnly);
    }

    /**
     * @{inheritdoc}
     * @see TSLBasicRecordDAO::getDeleteRecordQuery()
     */
    protected function getDeleteRecordQuery($id, $versionId) {
        return 'delete from tb_regiones where regiones_codigo = \'' . $id . '\'  and xmin =' . $versionId;
    }

    /**
     * @see TSLBasicRecordDAO::getAddRecordQuery()
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
        /* @var $record  RegionesModel  */
        $sql = 'select sp_regiones_save_record(' .
                '\'' . $record->get_regiones_codigo() . '\'::character varying,' .
                '\'' . $record->get_regiones_descripcion() . '\'::character varying,' .
                '\'' . $record->getActivo() . '\'::boolean,' .
                '\'' . $record->getUsuario() . '\'::character varying,' .
                'null::integer, 0::BIT);';
        return $sql;
    }

    /**
     * @{inheritdoc}
     * @see TSLBasicRecordDAO::getFetchQuery()
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {
        // Si la busqueda permite buscar solo activos e inactivos
        $sql = 'select regiones_codigo,regiones_descripcion,activo,xmin as "versionId" from  tb_regiones ';

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

        // Chequeamos paginacion
        $startRow = $constraints->getStartRow();
        $endRow = $constraints->getEndRow();

        if ($endRow > $startRow) {
            $sql .= ' LIMIT ' . ($endRow - $startRow) . ' OFFSET ' . $startRow;
        }


        $sql = str_replace('like', 'ilike', $sql);
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
        return 'select regiones_codigo,regiones_descripcion,activo,' .
                'xmin as "versionId" from tb_regiones where regiones_codigo =  \'' . $code . '\'';
    }

    /**
     * Aqui el id es el codigo
     * @see TSLBasicRecordDAO::getUpdateRecordQuery()
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) {
        /* @var $record  RegionesModel  */
        $sql = 'select * from (select sp_regiones_save_record(' .
                '\'' . $record->get_regiones_codigo() . '\'::character varying,' .
                '\'' . $record->get_regiones_descripcion() . '\'::character varying,' .
                '\'' . $record->getActivo() . '\'::boolean,' .
                '\'' . $record->get_Usuario_mod() . '\'::character varying,' .
                $record->getVersionId() . '::integer, 1::BIT)  as insupd) as ans where insupd is not null;';
        return $sql;
    }

}

?>