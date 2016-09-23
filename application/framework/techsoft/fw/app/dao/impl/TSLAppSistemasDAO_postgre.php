<?php

namespace app\common\dao\impl;

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico para el manejo de la lista de sistemas que
 * componen un producto , todo sistema que implementa perfiles y usuarios
 * hara uso de este DAO , este caso  especifico es la implementacion para POSTGRES SQL
 * y debera ser adaptada para otras bases de datos , lo unico especifico aqui es el uso del
 * campo xmin.
 *
 * La tabla debera ser la siguiente o su equivalente en otras bases.
 *
 * - Table: tb_sys_sistemas
 *-- DROP TABLE tb_sys_sistemas;
 * CREATE TABLE tb_sys_sistemas
 *(
 *   sys_systemcode character varying(10) NOT NULL,
 *   sistema_descripcion character varying(100) NOT NULL,
 *   activo boolean NOT NULL DEFAULT true,
 *   usuario character varying(15) NOT NULL,
 *   fecha_creacion timestamp without time zone NOT NULL,
 *   usuario_mod character varying(15),
 *   fecha_modificacion timestamp without time zone,
 *   CONSTRAINT pk_sistemas PRIMARY KEY (sys_systemcode )
 * )
 * WITH (
 *   OIDS=FALSE
 * );
 * ALTER TABLE tb_sys_sistemas
 *   OWNER TO muniren;
 * -- Trigger: tr_sys_sistemas on tb_sys_sistemas
 * -- DROP TRIGGER tr_sys_sistemas ON tb_sys_sistemas;
 * CREATE TRIGGER tr_sys_sistemas
 *  BEFORE INSERT OR UPDATE
 *   ON tb_sys_sistemas
 *  FOR EACH ROW
 *   EXECUTE PROCEDURE sptrg_update_log_fields();
 *
 */
class TSLAppSistemasDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

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
        return NULL;
    }

    /**
     * @see \TSLBasicRecordDAO::getAddRecordQuery()
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
        return NULL;
    }

    /**
     * Esta es solo la lista de sistemas no requiere constaraints especiales ni order especifico
     * fuera de los indicados.
     * @see \TSLBasicRecordDAO::getFetchQuery()
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {
        // Si la busqueda permite buscar solo activos e inactivos
        $sql = 'select sys_systemcode,sistema_descripcion,activo,xmin as "versionId" from tb_sys_sistemas';



        if ($this->activeSearchOnly == TRUE) {
            // Solo activos
            $sql .= ' where activo=TRUE ';
        }

        $sql .= ' order by sistema_descripcion';
        return $sql;
    }

    /**
     * @see \TSLBasicRecordDAO::getRecordQuery()
     */
    protected function getRecordQuery($id,\TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {
        return NULL;
    }

    /**
     * @see \TSLBasicRecordDAO::getRecordQueryByCode()
     */
    protected function getRecordQueryByCode($code,\TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {
        return NULL;
    }

    /**
     * La metodologia para el update es un hack por problemas en el psotgresql cuando un insert
     * es llevado a una function procedure , recomendamos leer el stored procedure.
     *
     * @see \TSLBasicRecordDAO::getUpdateRecordQuery()
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) {
        return NULL;
    }

}

?>