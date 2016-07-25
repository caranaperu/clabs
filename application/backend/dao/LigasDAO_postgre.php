<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de las ligas de la federacion
 * usuaria.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: LigasDAO_postgre.php 44 2014-02-18 16:33:05Z aranape $
 * @history ''
 *
 * $Date: 2014-02-18 11:33:05 -0500 (mar, 18 feb 2014) $
 * $Rev: 44 $
 */
class LigasDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

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
        // return 'delete from tb_ligas where ligas_codigo = \'' . $id . '\'  and xmin =' . $versionId;
        return 'select * from ( select sp_liga_delete_record(\'' . $id . '\',null,' . $versionId . ')  as updins) as ans where updins is not null';
    }

    /**
     * @see \TSLBasicRecordDAO::getAddRecordQuery()
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
        /* @var $record  LigasModel  */

        return 'insert into tb_ligas (ligas_codigo,ligas_descripcion,ligas_persona_contacto,ligas_telefono_oficina,ligas_telefono_celular,ligas_email,ligas_direccion,ligas_web_url,activo,usuario) values(\'' .
                $record->get_ligas_codigo() . '\',\'' .
                $record->get_ligas_descripcion() . '\',\'' .
                $record->get_ligas_persona_contacto() . '\',\'' .
                $record->get_ligas_telefono_oficina() . '\',\'' .
                $record->get_ligas_telefono_celular() . '\',\'' .
                $record->get_ligas_email() . '\',\'' .
                $record->get_ligas_direccion() . '\',\'' .
                $record->get_ligas_web_url() . '\',\'' .
                $record->getActivo() . '\',\'' .
                $record->getUsuario() . '\')';
    }

    /**
     * @see \TSLBasicRecordDAO::getFetchQuery()
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {
        // Si la busqueda permite buscar solo activos e inactivos
        $sql = 'select ligas_codigo,ligas_descripcion,ligas_persona_contacto,ligas_telefono_oficina,ligas_telefono_celular,ligas_email,ligas_direccion,ligas_web_url,activo,xmin as "versionId" from  tb_ligas ';

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
        return 'select ligas_codigo,ligas_descripcion,ligas_persona_contacto,ligas_telefono_oficina,ligas_telefono_celular,ligas_email,ligas_direccion,ligas_web_url,activo,' .
                'xmin as "versionId" from tb_ligas where "ligas_codigo" =  \'' . $code . '\'';
    }

    /**
     * Aqui el id es el codigo
     * @see \TSLBasicRecordDAO::getUpdateRecordQuery()
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) {
        /* @var $record  LigasModel  */
        return 'update tb_ligas set ligas_codigo=\'' . $record->get_ligas_codigo() . '\',' .
                'ligas_descripcion=\'' . $record->get_ligas_descripcion() . '\',' .
                'ligas_persona_contacto=\'' . $record->get_ligas_persona_contacto() . '\',' .
                'ligas_telefono_oficina=\'' . $record->get_ligas_telefono_oficina() . '\',' .
                'ligas_telefono_celular=\'' . $record->get_ligas_telefono_celular() . '\',' .
                'ligas_email=\'' . $record->get_ligas_email() . '\',' .
                'ligas_direccion=\'' . $record->get_ligas_direccion() . '\',' .
                'ligas_web_url=\'' . $record->get_ligas_web_url() . '\',' .
                'activo=\'' . $record->getActivo() . '\',' .
                'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
                ' where "ligas_codigo" = \'' . $record->get_ligas_codigo() . '\'  and xmin =' . $record->getVersionId();
    }

}

?>