<?php

namespace app\common\dao\impl;

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico para el manejo de los items de detalle de perfiles al sistema,
 * todo sistema que implementa perfiles hara uso de este DAO , este caso
 * especifico es la implementacion para POSTGRES SQL y debera ser adaptada
 * para otras bases de datos , lo unico especifico aqui es el uso del
 * campo xmin.
 *
 * La tabla debera ser la siguiente o su equivalente en otras bases.
 *
 *      -- Table: tb_sys_perfil_detalle
 *
 *      -- DROP TABLE tb_sys_perfil_detalle;
 *
 *  CREATE TABLE tb_sys_perfil
 *  (
 *    perfil_id integer NOT NULL DEFAULT nextval('tb_sys_perfil_id_seq'::regclass),
 *    sys_systemcode character varying(10) NOT NULL,
 *    perfil_codigo character varying(15) NOT NULL,
 *    perfil_descripcion character varying(120),
 *    activo boolean NOT NULL DEFAULT true,
 *    usuario character varying(15) NOT NULL,
 *    fecha_creacion timestamp without time zone NOT NULL,
 *    usuario_mod character varying(15),
 *    fecha_modificacion timestamp without time zone,
 *    CONSTRAINT pk_sys_perfil PRIMARY KEY (perfil_id ),
 *    CONSTRAINT fk_perfil_sistema FOREIGN KEY (sys_systemcode)
 *        REFERENCES tb_sys_sistemas (sys_systemcode) MATCH SIMPLE
 *        ON UPDATE NO ACTION ON DELETE NO ACTION,
 *    CONSTRAINT unq_perfil_syscode_codigo UNIQUE (sys_systemcode , perfil_codigo )
 *  )
 *  WITH (
 *    OIDS=FALSE
 *  );
 *  ALTER TABLE tb_sys_perfil
 *    OWNER TO muniren;
 *
 *  -- Index: fki_perfil_sistema
 *
 *  -- DROP INDEX fki_perfil_sistema;
 *
 * CREATE INDEX fki_perfil_sistema
 *    ON tb_sys_perfil
 *    USING btree
 *    (sys_systemcode COLLATE pg_catalog."default" );
 *
 *
 *  -- Trigger: tr_sys_perfil on tb_sys_perfil
 *
 *  -- DROP TRIGGER tr_sys_perfil ON tb_sys_perfil;
 *
 *  CREATE TRIGGER tr_sys_perfil
 *    BEFORE INSERT OR UPDATE
 *    ON tb_sys_perfil
 *    FOR EACH ROW
 *    EXECUTE PROCEDURE sptrg_update_log_fields();
 *
 *
 * @author  $Author: aranape $
 * @version $Id: TSLAppPerfilDAO_postgre.php 192 2014-06-23 19:49:27Z aranape $
 * @history ''
 *
 * $Date: 2014-06-23 14:49:27 -0500 (lun, 23 jun 2014) $
 * $Rev: 192 $
 */
class TSLAppPerfilDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

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
    //    return 'delete from tb_sys_perfil where "perfil_id" =' . $id . '  and xmin =' . $versionId;
        return 'select * from ( select sp_perfil_delete_record(' . $id . ',null,' . $versionId . ')  as updins) as ans where updins is not null';
    }

    /**
     * @see \TSLBasicRecordDAO::getAddRecordQuery()
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
        /* @var $record \app\common\model\TLSAppPerfilModel  */

        $copyFromPerfil = $constraints->getParameter('prm_copyFromPerfil');

        $sql = 'select sp_sysperfil_add_record(' .
                '\'' . $record->get_sys_systemcode() . '\'::character varying,' .
                '\'' . $record->get_perfil_codigo() . '\'::character varying,' .
                '\'' . $record->get_perfil_descripcion() . '\'::character varying,' .
                ($copyFromPerfil == NULL ? 'NULL' : $copyFromPerfil) . '::integer,' .
                '\'' . $record->getActivo() . '\'::boolean,' .
                '\'' . $record->getUsuario() . '\'::character varying);';
        return $sql;
    }

    /**
     * @see \TSLBasicRecordDAO::getFetchQuery()
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {
        // Si la busqueda permite buscar solo activos e inactivos
        $sql = 'select perfil_id,sys_systemcode,perfil_codigo,perfil_descripcion,activo,xmin as "versionId" from tb_sys_perfil';



        if ($this->activeSearchOnly == TRUE) {
            // Solo activos
            $sql .= ' where activo=TRUE ';
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

        return $sql;
    }

    /**
     * @see \TSLBasicRecordDAO::getRecordQuery()
     */
    protected function getRecordQuery($id) {
        return 'select perfil_id,sys_systemcode,perfil_codigo,perfil_descripcion,activo,xmin as "versionId" from tb_sys_perfil where perfil_id =' . $id;
    }

    /**
     * @see \TSLBasicRecordDAO::getRecordQueryByCode()
     */
    protected function getRecordQueryByCode($code) {
        return $this->getRecordQuery($code);
    }

    /**
     * La metodologia para el update es un hack por problemas en el psotgresql cuando un insert
     * es llevado a una function procedure , recomendamos leer el stored procedure.
     *
     * @see \TSLBasicRecordDAO::getUpdateRecordQuery()
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) {
        /* @var $record \app\common\model\TLSAppPerfilModel */
        $sql = 'update tb_sys_perfil set ' .
                'perfil_codigo=\'' . $record->get_perfil_codigo() . '\',' .
                'perfil_descripcion=\'' . $record->get_perfil_descripcion() . '\',' .
                'activo=\'' . $record->getActivo() . '\'' .
                ',"usuario_mod"=\'' . $record->get_Usuario_mod() . '\'' .
                ' where "perfil_id" = \'' . $record->get_perfil_id() . '\'  and xmin =' . $record->getVersionId();

        return $sql;
    }

    protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL) {
        return 'SELECT currval(\'tb_sys_perfil_id_seq\')';
    }

}

?>