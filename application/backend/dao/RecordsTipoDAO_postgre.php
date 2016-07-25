<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de tipos de records
 * de las competencias atleticas.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: RecordsTipoDAO_postgre.php 286 2014-06-30 19:46:07Z aranape $
 * @history ''
 *
 * $Date: 2014-06-30 14:46:07 -0500 (lun, 30 jun 2014) $
 * $Rev: 286 $
 */
class RecordsTipoDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

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
        return 'delete from tb_records_tipo where records_tipo_codigo = \'' . $id . '\'  and xmin =' . $versionId;
    }

    /**
     * @see \TSLBasicRecordDAO::getAddRecordQuery()
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
        /* @var $record  RecordsTipoModel  */
        $sql = 'select sp_records_tipo_save_record(' .
                '\'' . $record->get_records_tipo_codigo() . '\'::character varying,' .
                '\'' . $record->get_records_tipo_descripcion() . '\'::character varying,' .
                '\'' . $record->get_records_tipo_abreviatura() . '\'::character varying,' .
                '\'' . $record->get_records_tipo_tipo() . '\'::character varying,' .
                '\'' . $record->get_records_tipo_clasificacion() . '\'::character varying,' .
                $record->get_records_tipo_peso() . '::integer,' .
                '\'' . $record->get_records_tipo_protected() . '\'::boolean,' .
                '\'' . $record->getActivo() . '\'::boolean,' .
                '\'' . $record->getUsuario() . '\'::character varying,' .
                'null::integer, 0::BIT);';
        return $sql;
    }

    /**
     * @see \TSLBasicRecordDAO::getFetchQuery()
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {
        // Si la busqueda permite buscar solo activos e inactivos
        $sql = 'select records_tipo_codigo,records_tipo_descripcion,records_tipo_abreviatura,records_tipo_tipo,records_tipo_clasificacion,'
                . 'records_tipo_peso,records_tipo_protected,activo,xmin as "versionId" from  tb_records_tipo ';

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
        return 'select records_tipo_codigo,records_tipo_descripcion,records_tipo_abreviatura,records_tipo_tipo,records_tipo_clasificacion,records_tipo_peso,records_tipo_protected,activo,' .
                'xmin as "versionId" from tb_records_tipo where "records_tipo_codigo" =  \'' . $code . '\'';
    }

    /**
     * Aqui el id es el codigo
     * @see \TSLBasicRecordDAO::getUpdateRecordQuery()
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) {
        /* @var $record  RecordsTipoModel  */
        $sql = 'select * from (select sp_records_tipo_save_record(' .
                '\'' . $record->get_records_tipo_codigo() . '\'::character varying,' .
                '\'' . $record->get_records_tipo_descripcion() . '\'::character varying,' .
                '\'' . $record->get_records_tipo_abreviatura() . '\'::character varying,' .
                '\'' . $record->get_records_tipo_tipo() . '\'::character varying,' .
                '\'' . $record->get_records_tipo_clasificacion() . '\'::character varying,' .
                $record->get_records_tipo_peso() . '::integer,' .
                '\'' . $record->get_records_tipo_protected() . '\'::boolean,' .
                '\'' . $record->getActivo() . '\'::boolean,' .
                '\'' . $record->get_Usuario_mod() . '\'::character varying,' .
                $record->getVersionId() . '::integer, 1::BIT)  as insupd) as ans where insupd is not null;';
        return $sql;
    }

}

?>