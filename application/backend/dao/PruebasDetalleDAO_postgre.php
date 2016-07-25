<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de las pruebas que conforman una principal , esto sera
 * usado solo para las pruebas combinadas.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: PruebasDetalleDAO_postgre.php 208 2014-06-23 22:48:07Z aranape $
 * @history ''
 *
 * $Date: 2014-06-23 17:48:07 -0500 (lun, 23 jun 2014) $
 * $Rev: 208 $
 */
class PruebasDetalleDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

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
        return 'delete from tb_pruebas_detalle where pruebas_detalle_id = \'' . $id . '\'  and xmin =' . $versionId;
    }

    /**
     * @see \TSLBasicRecordDAO::getAddRecordQuery()
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
        /* @var $record  PruebasDetalleModel  */
        $sql = 'select sp_pruebasdetalle_save_record(NULL::integer,' .
                '\'' . $record->get_pruebas_codigo() . '\'::character varying,' .
                '\'' . $record->get_pruebas_detalle_prueba_codigo() . '\'::character varying,' .
                $record->get_pruebas_detalle_orden() . '::integer,' .
                '\'' . ($record->getActivo() != TRUE ? '0' : '1') . '\'::boolean,' .
                '\'' . $record->getUsuario() . '\'::character varying,NULL::integer,0::BIT);';
        return $sql;
    }

    /**
     * @see \TSLBasicRecordDAO::getFetchQuery()
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {
        // Si la busqueda permite buscar solo activos e inactivos
      //  $sql = 'select pruebas_detalle_id,pruebas_codigo,pruebas_detalle_prueba_codigo,pruebas_detalle_orden,activo,xmin as "versionId" from  tb_pruebas_detalle pd';

        if ($subOperation == 'fetchJoined') {
            $sql = 'select pruebas_detalle_id,pd.pruebas_codigo,pruebas_detalle_prueba_codigo,pr.pruebas_descripcion,pruebas_detalle_orden,pd.activo,pd.xmin as "versionId" from  tb_pruebas_detalle pd '.
                'inner join tb_pruebas pr on pr.pruebas_codigo = pd.pruebas_detalle_prueba_codigo ';
        } else {
            $sql = 'select pruebas_detalle_id,pruebas_codigo,pruebas_detalle_prueba_codigo,pruebas_detalle_orden,activo,xmin as "versionId" from  tb_pruebas_detalle pd';
        }

        if ($this->activeSearchOnly == TRUE) {
            // Solo activos
            $sql .= ' where pd.activo=TRUE ';
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

        // Dado que la relacion padres a hijos es en la misma tabla se requiere precisar a cual lado del
        // join pertenece la llave principal.
        $sql = str_replace('"pruebas_codigo"', 'pd.pruebas_codigo', $sql);

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
        return 'select pruebas_detalle_id,pruebas_codigo,pruebas_detalle_prueba_codigo,pruebas_detalle_orden,activo,' .
                'xmin as "versionId" from tb_pruebas_detalle where pruebas_detalle_id =  ' . $code ;
    }

    /**
     * Aqui el id es el codigo
     * @see \TSLBasicRecordDAO::getUpdateRecordQuery()
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) {
        /* @var $record  PruebasDetalleModel  */
        $sql = 'select * from (select sp_pruebasdetalle_save_record(' .
                $record->get_pruebas_detalle_id() . '::integer,' .
                '\'' . $record->get_pruebas_codigo() . '\'::character varying,' .
                '\'' . $record->get_pruebas_detalle_prueba_codigo() . '\'::character varying,' .
                $record->get_pruebas_detalle_orden() . '::integer,' .
                '\'' . ($record->getActivo() != TRUE ? '0' : '1') . '\'::boolean,' .
                '\'' . $record->get_Usuario_mod() . '\'::varchar,' .
                $record->getVersionId() . '::integer,1::BIT) as insupd) as ans where insupd is not null;';
        return $sql;
    }

    protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL) {
        return 'SELECT currval(\'tb_pruebas_detalle_pruebas_detalle_id_seq\')';
    }

}

?>