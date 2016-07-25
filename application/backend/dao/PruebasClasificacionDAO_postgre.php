<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de las ciudades del sistema.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: PruebasClasificacionDAO_postgre.php 203 2014-06-23 22:43:24Z aranape $
 * @history ''
 *
 * $Date: 2014-06-23 17:43:24 -0500 (lun, 23 jun 2014) $
 * $Rev: 203 $
 */
class PruebasClasificacionDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

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
        return 'delete from tb_pruebas_clasificacion where pruebas_clasificacion_codigo = \'' . $id . '\'  and xmin =' . $versionId;
    }

    /**
     * @see \TSLBasicRecordDAO::getAddRecordQuery()
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
        /* @var $record  PruebasClasificacionModel  */
        return 'insert into tb_pruebas_clasificacion (pruebas_clasificacion_codigo,pruebas_clasificacion_descripcion,pruebas_tipo_codigo,unidad_medida_codigo,activo,usuario) values(\'' .
                $record->get_pruebas_clasificacion_codigo() . '\',\'' .
                $record->get_pruebas_clasificacion_descripcion() . '\',\'' .
                $record->get_pruebas_tipo_codigo() . '\',\'' .
                $record->get_unidad_medida_codigo() . '\',\'' .
                $record->getActivo() . '\',\'' .
                $record->getUsuario() . '\')';
    }

    /**
     * @see \TSLBasicRecordDAO::getFetchQuery()
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {
        // Si la busqueda permite buscar solo activos e inactivos

        if ($subOperation == 'fetchJoined') {
            $sql = 'select pruebas_clasificacion_codigo,pruebas_clasificacion_descripcion,pruebas_tipo_codigo,pc.unidad_medida_codigo,um.unidad_medida_regex_e,um.unidad_medida_regex_m,um.unidad_medida_tipo,'
                    . 'pc.activo,pc.xmin as "versionId" from  tb_pruebas_clasificacion pc '
                    . 'inner join tb_unidad_medida um on um.unidad_medida_codigo=pc.unidad_medida_codigo ';
        } else {
            $sql = 'select pruebas_clasificacion_codigo,pruebas_clasificacion_descripcion,pruebas_tipo_codigo,unidad_medida_codigo,activo,xmin as "versionId" from  tb_pruebas_clasificacion pc';
        }


        if ($this->activeSearchOnly == TRUE) {
            // Solo activos
            $sql .= ' where pc.activo=TRUE ';
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
        return 'select pruebas_clasificacion_codigo,pruebas_clasificacion_descripcion,pruebas_tipo_codigo,unidad_medida_codigo,activo,' .
                'xmin as "versionId" from tb_pruebas_clasificacion where pruebas_clasificacion_codigo =  \'' . $code . '\'';
    }

    /**
     * Aqui el id es el codigo
     * @see \TSLBasicRecordDAO::getUpdateRecordQuery()
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) {
        /* @var $record  PruebasClasificacionModel  */
        return 'update tb_pruebas_clasificacion set pruebas_clasificacion_codigo=\'' . $record->get_pruebas_clasificacion_codigo() . '\',' .
                'pruebas_clasificacion_descripcion=\'' . $record->get_pruebas_clasificacion_descripcion() . '\',' .
                'pruebas_tipo_codigo=\'' . $record->get_pruebas_tipo_codigo() . '\',' .
                'unidad_medida_codigo=\'' . $record->get_unidad_medida_codigo() . '\',' .
                'activo=\'' . $record->getActivo() . '\',' .
                'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
                ' where "pruebas_clasificacion_codigo" = \'' . $record->get_pruebas_clasificacion_codigo() . '\'  and xmin =' . $record->getVersionId();
    }

}

?>