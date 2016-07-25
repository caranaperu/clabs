<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de los entrenadores.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: EntrenadoresDAO_postgre.php 16 2014-02-14 20:18:32Z aranape $
 * @history ''
 *
 * $Date: 2014-02-14 15:18:32 -0500 (vie, 14 feb 2014) $
 * $Rev: 16 $
 */
class EntrenadoresDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

    /**
     * Constructor se puede indicar si las busquedas solo seran en registros activos.
     * @param boolean $activeSearchOnly
     */
    public function __construct($activeSearchOnly = TRUE) {
        parent::__construct($activeSearchOnly);
    }

    /**
     * {@inheritdoc}
     * @see \TSLBasicRecordDAO::getDeleteRecordQuery()
     */
    protected function getDeleteRecordQuery($id, $versionId) {
        return 'delete from tb_entrenadores where entrenadores_codigo = \'' . $id . '\'  and xmin =' . $versionId;
    }

    /**
     * @see \TSLBasicRecordDAO::getAddRecordQuery()
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
        /* @var $record  EntrenadoresModel  */
        /*  return 'insert into tb_entrenadores (entrenadores_codigo,entrenadores_ap_paterno,entrenadores_ap_materno,entrenadores_ap_nombres,entrenadores_nivel_codigo,activo,usuario) values(\'' .
          $record->get_entrenadores_codigo() . '\',\'' .
          $record->get_entrenadores_ap_paterno() . '\',\'' .
          $record->get_entrenadores_ap_materno() . '\',\'' .
          $record->get_entrenadores_nombres() . '\',\'' .
          $record->get_entrenadores_nivel_codigo() . '\',\'' .
          $record->getActivo() . '\',\'' .
          $record->getUsuario() . '\')'; */

        $sql = 'select sp_entrenadores_save_record(' .
                '\'' . $record->get_entrenadores_codigo() . '\'::character varying,' .
                '\'' . $record->get_entrenadores_ap_paterno() . '\'::character varying,' .
                '\'' . $record->get_entrenadores_ap_materno() . '\'::character varying,' .
                '\'' . $record->get_entrenadores_nombres() . '\'::character varying,' .
                '\'' . $record->get_entrenadores_nivel_codigo() . '\'::character varying,' .
                '\'' . $record->getActivo() . '\'::boolean,' .
                '\'' . $record->getUsuario() . '\'::character varying,' .
                'null::integer, 0::BIT)';
        return $sql;
    }

    /**
     * @see \TSLBasicRecordDAO::getFetchQuery()
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {
        // Si la busqueda permite buscar solo activos e inactivos
        $sql = 'select entrenadores_codigo,entrenadores_ap_paterno,entrenadores_ap_materno,entrenadores_nombres,entrenadores_nombre_completo,entrenadores_nivel_codigo,activo,xmin as "versionId" from  tb_entrenadores ';

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
        return 'select entrenadores_codigo,entrenadores_ap_paterno,entrenadores_ap_materno,entrenadores_nombres,entrenadores_nombre_completo,entrenadores_nivel_codigo,activo,' .
                'xmin as "versionId" from tb_entrenadores where entrenadores_codigo =  \'' . $code . '\'';
    }

    /**
     * Aqui el id es el codigo
     * @see \TSLBasicRecordDAO::getUpdateRecordQuery()
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) {
        /* @var $record  EntrenadoresModel  */
        /* return 'update tb_entrenadores set entrenadores_codigo=\'' . $record->get_entrenadores_codigo() . '\',' .
          'entrenadores_ap_paterno=\'' . $record->get_entrenadores_ap_paterno() . '\',' .
          'entrenadores_ap_materno=\'' . $record->get_entrenadores_ap_materno() . '\',' .
          'entrenadores_nombres=\'' . $record->get_entrenadores_nombres() . '\',' .
          'entrenadores_nivel_codigo=\'' . $record->get_entrenadores_nivel_codigo() . '\',' .
          'activo=\'' . $record->getActivo() . '\',' .
          'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
          ' where "entrenadores_codigo" = \'' . $record->get_entrenadores_codigo() . '\'  and xmin =' . $record->getVersionId(); */

        $sql = 'select * from (select sp_entrenadores_save_record(' .
                '\'' . $record->get_entrenadores_codigo() . '\'::character varying,' .
                '\'' . $record->get_entrenadores_ap_paterno() . '\'::character varying,' .
                '\'' . $record->get_entrenadores_ap_materno() . '\'::character varying,' .
                '\'' . $record->get_entrenadores_nombres() . '\'::character varying,' .
                '\'' . $record->get_entrenadores_nivel_codigo() . '\'::character varying,' .
                '\'' . $record->getActivo() . '\'::boolean,' .
                '\'' . $record->get_Usuario_mod() . '\'::character varying,' .
                $record->getVersionId() . '::integer, 1::BIT) as insupd) as ans where insupd is not null;';
        return $sql;
    }

}

?>