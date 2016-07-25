<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de las ciudades del sistema.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: CiudadesDAO_postgre.php 207 2014-06-23 22:47:22Z aranape $
 * @history ''
 *
 * $Date: 2014-06-23 17:47:22 -0500 (lun, 23 jun 2014) $
 * $Rev: 207 $
 */
class CiudadesDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

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
        return 'delete from tb_ciudades where ciudades_codigo = \'' . $id . '\'  and xmin =' . $versionId;
    }

    /**
     * @see \TSLBasicRecordDAO::getAddRecordQuery()
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
        /* @var $record  CiudadesModel  */
        return 'insert into tb_ciudades (ciudades_codigo,ciudades_descripcion,paises_codigo,ciudades_altura,activo,usuario) values(\'' .
                $record->get_ciudades_codigo() . '\',\'' .
                $record->get_ciudades_descripcion() . '\',\'' .
                $record->get_paises_codigo() . '\',\'' .
                $record->get_ciudades_altura() . '\',\'' .
                $record->getActivo() . '\',\'' .
                $record->getUsuario() . '\')';
    }

    /**
     * @see \TSLBasicRecordDAO::getFetchQuery()
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {
        // Si la busqueda permite buscar solo activos e inactivos
        $sql = 'select ciudades_codigo,ciudades_descripcion,paises_codigo,ciudades_altura,activo,xmin as "versionId" from  tb_ciudades ';

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
        return 'select ciudades_codigo,ciudades_descripcion,paises_codigo,ciudades_altura,activo,' .
                'xmin as "versionId" from tb_ciudades where ciudades_codigo =  \'' . $code . '\'';
    }

    /**
     * Aqui el id es el codigo
     * @see \TSLBasicRecordDAO::getUpdateRecordQuery()
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) {
        /* @var $record  CiudadesModel  */
        return 'update tb_ciudades set ciudades_codigo=\'' . $record->get_ciudades_codigo() . '\',' .
                'ciudades_descripcion=\'' . $record->get_ciudades_descripcion() . '\',' .
                'paises_codigo=\'' . $record->get_paises_codigo() . '\',' .
                'ciudades_altura=\'' . $record->get_ciudades_altura() . '\',' .
                'activo=\'' . $record->getActivo() . '\',' .
                'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
                ' where "ciudades_codigo" = \'' . $record->get_ciudades_codigo() . '\'  and xmin =' . $record->getVersionId();
    }

}

?>