<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de las clubes a asociarse a las ligas,
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: ClubesDAO_postgre.php 97 2014-03-25 15:24:35Z aranape $
 * @history ''
 *
 * $Date: 2014-03-25 10:24:35 -0500 (mar, 25 mar 2014) $
 * $Rev: 97 $
 */
class ClubesDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

    /**
     * Constructor se puede indicar si las busquedas solo seran en registros activos.
     * @param boolean $activeSearchOnly
     */
    public function __construct($activeSearchOnly = TRUE) {
        parent::__construct($activeSearchOnly);
    }

    /**
     * @see \TSLBasicRecordDAO::getDeleteRecordQuery()
     * @todo DELETE ON CASCADE
     */
    protected function getDeleteRecordQuery($id, $versionId) {
        return 'delete from tb_clubes where clubes_codigo = \'' . $id . '\'  and xmin =' . $versionId;
    }

    /**
     * @see \TSLBasicRecordDAO::getAddRecordQuery()
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
        /* @var $record  ClubesModel  */
        return 'insert into tb_clubes (clubes_codigo,clubes_descripcion,clubes_persona_contacto,clubes_telefono_oficina,clubes_telefono_celular,clubes_email,clubes_direccion,clubes_web_url,activo,usuario) values(\'' .
                $record->get_clubes_codigo() . '\',\'' .
                $record->get_clubes_descripcion() . '\',\'' .
                $record->get_clubes_persona_contacto() . '\',\'' .
                $record->get_clubes_telefono_oficina() . '\',\'' .
                $record->get_clubes_telefono_celular() . '\',\'' .
                $record->get_clubes_email() . '\',\'' .
                $record->get_clubes_direccion() . '\',\'' .
                $record->get_clubes_web_url() . '\',\'' .
                $record->getActivo() . '\',\'' .
                $record->getUsuario() . '\')';
    }

    /**
     * @see \TSLBasicRecordDAO::getFetchQuery()
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {
        // Si la busqueda permite buscar solo activos e inactivos
        $sql = 'select clubes_codigo,clubes_descripcion,clubes_persona_contacto,clubes_telefono_oficina,clubes_telefono_celular,clubes_email,clubes_direccion,clubes_web_url,activo,xmin as "versionId" from  tb_clubes ';

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
        return 'select clubes_codigo,clubes_descripcion,clubes_persona_contacto,clubes_telefono_oficina,clubes_telefono_celular,clubes_email,clubes_direccion,clubes_web_url,activo,' .
                'xmin as "versionId" from tb_clubes where "clubes_codigo" =  \'' . $code . '\'';
    }

    /**
     * Aqui el id es el codigo
     * @see \TSLBasicRecordDAO::getUpdateRecordQuery()
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) {
        /* @var $record  ClubesModel  */
        return 'update tb_clubes set clubes_codigo=\'' . $record->get_clubes_codigo() . '\',' .
                'clubes_descripcion=\'' . $record->get_clubes_descripcion() . '\',' .
              'clubes_persona_contacto=\'' . $record->get_clubes_persona_contacto() . '\',' .
                'clubes_telefono_oficina=\'' . $record->get_clubes_telefono_oficina() . '\',' .
                'clubes_telefono_celular=\'' . $record->get_clubes_telefono_celular() . '\',' .
                'clubes_email=\'' . $record->get_clubes_email() . '\',' .
                'clubes_direccion=\'' . $record->get_clubes_direccion() . '\',' .
                'clubes_web_url=\'' . $record->get_clubes_web_url() . '\',' .
                'activo=\'' . $record->getActivo() . '\',' .
                'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
                ' where "clubes_codigo" = \'' . $record->get_clubes_codigo() . '\'  and xmin =' . $record->getVersionId();
    }

}

?>