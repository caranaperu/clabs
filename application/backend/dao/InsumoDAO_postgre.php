<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de los insumos.
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package CLABS
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class InsumoDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

    /**
     * Constructor se puede indicar si las busquedas solo seran en registros activos.
     * @param boolean $activeSearchOnly
     */
    public function __construct($activeSearchOnly = TRUE) {
        parent::__construct($activeSearchOnly);
    }

    /**
     * @{inheritdoc}
     * @see TSLBasicRecordDAO::getDeleteRecordQuery()
     */
    protected function getDeleteRecordQuery($id, $versionId) {
        return 'delete from tb_insumo where insumo_codigo = \'' . $id . '\'  and xmin =' . $versionId;
    }

    /**
     * @see TSLBasicRecordDAO::getAddRecordQuery()
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
        /* @var $record  InsumoModel  */
        return 'insert into tb_insumo (insumo_codigo,insumo_descripcion,tinsumo_codigo,tcostos_codigo,unidad_medida_codigo,insumo_merma,'
        . 'activo,usuario) values(\'' .
        $record->get_insumo_codigo() . '\',\'' .
        $record->get_insumo_descripcion() . '\',\'' .
        $record->get_tinsumo_codigo() . '\',\'' .
        $record->get_tcostos_codigo() . '\',\'' .
        $record->get_unidad_medida_codigo() . '\',\'' .
        $record->get_insumo_merma() . '\',\'' .
        $record->getActivo() . '\',\'' .
        $record->getUsuario() . '\')';

        return $sql;
    }

    /**
     * @{inheritdoc}
     * @see TSLBasicRecordDAO::getFetchQuery()
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {
        // Si la busqueda permite buscar solo activos e inactivos
        $sql = $this->_getFecthNormalized();

        if ($this->activeSearchOnly == TRUE) {
            // Solo activos
            $sql .= ' where ins."activo"=TRUE ';
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
     * @see TSLBasicRecordDAO::getRecordQuery()
     */
    protected function getRecordQuery($id, $subOperation = NULL) {
        // en este caso el codigo es la llave primaria
        return $this->getRecordQueryByCode($id, $subOperation);
    }

    /**
     * @see TSLBasicRecordDAO::getRecordQueryByCode()
     */
    protected function getRecordQueryByCode($code, $subOperation = NULL) {
        if ($subOperation == 'readAfterSaveJoined') {
            $sql = $this->_getFecthNormalized();
            $sql .= ' where insumo_codigo =  \'' . $code . '\'';
        } else {
            $sql =  'select insumo_codigo,insumo_descripcion,tinsumo_codigo,tcostos_codigo,unidad_medida_codigo,insumo_merma,activo,' .
                'xmin as "versionId" from tb_insumo where insumo_codigo =  \'' . $code . '\'';
        }
        return $sql;
    }

    /**
     * Aqui el id es el codigo
     * @see TSLBasicRecordDAO::getUpdateRecordQuery()
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) {
        /* @var $record  InsumoModel  */

        return 'update tb_insumo set insumo_codigo=\'' . $record->get_insumo_codigo() . '\','.
        'insumo_descripcion=\'' . $record->get_insumo_descripcion() . '\',' .
        'tinsumo_codigo=\'' . $record->get_tinsumo_codigo() . '\',' .
        'tcostos_codigo=\'' . $record->get_tcostos_codigo() . '\',' .
        'unidad_medida_codigo=\'' . $record->get_unidad_medida_codigo() . '\',' .
        'insumo_merma=\'' . $record->get_insumo_merma() . '\',' .
        'activo=\'' . $record->getActivo() . '\',' .
        'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
        ' where "insumo_codigo" = \'' . $record->get_insumo_codigo() . '\'  and xmin =' . $record->getVersionId();

    }

    private function _getFecthNormalized() {
        $sql = 'select insumo_codigo,insumo_descripcion,ins.tinsumo_codigo,ti.tinsumo_descripcion as _tinsumo_descripcion,ins.unidad_medida_codigo,'.
                'um.unidad_medida_descripcion as _unidad_medida_descripcion,ins.tcostos_codigo,tcostos_descripcion as _tcostos_descripcion,'.
                'insumo_merma,ins.activo,ins.xmin as "versionId" '.
            'from  tb_insumo ins '.
            'inner join tb_unidad_medida um on um.unidad_medida_codigo = ins.unidad_medida_codigo '.
            'inner join tb_tcostos tc on tc.tcostos_codigo = ins.tcostos_codigo '.
            'inner join tb_tinsumo ti on ti.tinsumo_codigo = ins.tinsumo_codigo ';
        return $sql;
    }

}

?>