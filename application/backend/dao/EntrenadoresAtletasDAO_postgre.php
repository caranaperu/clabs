<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de los items de las ligas
 * que las relacionan con sus clubes asociados.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: EntrenadoresAtletasDAO_postgre.php 208 2014-06-23 22:48:07Z aranape $
 * @history ''
 *
 * $Date: 2014-06-23 17:48:07 -0500 (lun, 23 jun 2014) $
 * $Rev: 208 $
 */
class EntrenadoresAtletasDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

    /**
     * Constructor se puede indicar si las busquedas solo seran en registros activos.
     * @param boolean $activeSearchOnly
     */
    public function __construct($activeSearchOnly = TRUE) {
        parent::__construct(FALSE); // se permite siempre la busqueda incluyendo activos o no.
    }

    /**
     * @see \TSLBasicRecordDAO::getDeleteRecordQuery()
     */
    protected function getDeleteRecordQuery($id, $versionId) {
        return 'delete from tb_entrenadores_atletas where entrenadoresatletas_id = \'' . $id . '\'  and xmin =' . $versionId;
    }

    /**
     * @see \TSLBasicRecordDAO::getAddRecordQuery()
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
        /* @var $record  EntrenadoresAtletasModel  */
        $sql = 'select sp_entrenadoresatletas_save_record(NULL::integer,' .
                '\'' . $record->get_entrenadores_codigo() . '\'::character varying,' .
                '\'' . $record->get_atletas_codigo() . '\'::character varying,' .
                '\'' . $record->get_entrenadoresatletas_desde() . '\'::date,' .
                ($record->get_entrenadoresatletas_hasta() == '' ? 'null' : ('\'' . $record->get_entrenadoresatletas_hasta() . '\'')) . '::date,' .
                '\'' . ($record->getActivo() != TRUE ? '0' : '1') . '\'::boolean,' .
                '\'' . $record->getUsuario() . '\'::character varying,NULL::integer,0::BIT);';
        return $sql;
    }

    /**
     * @see \TSLBasicRecordDAO::getFetchQuery()
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {

        if ($subOperation == 'fetchJoined') {
            $sql = 'select entrenadoresatletas_id,entrenadores_codigo,eatl.atletas_codigo,atletas_nombre_completo,entrenadoresatletas_desde,entrenadoresatletas_hasta,eatl.activo,eatl.xmin as "versionId" from  tb_entrenadores_atletas eatl ' .
                    'inner join tb_atletas atl on eatl.atletas_codigo = atl.atletas_codigo ';
        } else {
            $sql = 'select entrenadoresatletas_id,entrenadores_codigo,atletas_codigo,entrenadoresatletas_desde,entrenadoresatletas_hasta,activo,xmin as "versionId" from  tb_entrenadores_atletas eatl';
        }

        if ($this->activeSearchOnly == TRUE) {
            // Solo activos
            $sql .= ' where "eatl.activo"=TRUE ';
        }

        // Que pasa si el campo a buscar existe en ambas partes del join?
        $where = $constraints->getFilterFieldsAsString();
        if ($this->activeSearchOnly == TRUE) {
            if (strlen($where) > 0) {
                $sql .= ' and ' . $where;
            }
        } else {
            $sql .= ' where ' . $where;
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
        return 'select entrenadoresatletas_id,entrenadores_codigo,atletas_codigo,entrenadoresatletas_desde,entrenadoresatletas_hasta,activo,' .
                'xmin as "versionId" from tb_entrenadores_atletas where "entrenadoresatletas_id" =  ' . $code;
    }

    /**
     * Aqui el id es el codigo
     * @see \TSLBasicRecordDAO::getUpdateRecordQuery()
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) {
        /* @var $record  EntrenadoresAtletasModel  */
        $sql = 'select * from (select sp_entrenadoresatletas_save_record(' .
                $record->get_entrenadoresatletas_id() . '::integer,' .
                '\'' . $record->get_entrenadores_codigo() . '\'::character varying,' .
                '\'' . $record->get_atletas_codigo() . '\'::character varying,' .
                '\'' . $record->get_entrenadoresatletas_desde() . '\'::date,' .
                '\'' . $record->get_entrenadoresatletas_hasta() . '\'::date,' .
                '\'' . ($record->getActivo() != TRUE ? '0' : '1') . '\'::boolean,' .
                '\'' . $record->get_Usuario_mod() . '\'::varchar,' .
                $record->getVersionId() . '::integer,1::BIT) as insupd) as ans where insupd is not null;';
        return $sql;
    }

    protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL) {
        return 'SELECT currval(\'tb_entrenadores_atletas_entrenadoresatletas_id_seq\')';
    }

}

?>