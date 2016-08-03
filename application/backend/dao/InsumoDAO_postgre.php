<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de los insumos.
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.2
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
        return 'delete from tb_insumo where insumo_id = ' . $id . '  and xmin =' . $versionId;
    }

    /**
     * @see TSLBasicRecordDAO::getAddRecordQuery()
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
        /* @var $record  InsumoModel  */
        return 'insert into tb_insumo (insumo_tipo,insumo_codigo,insumo_descripcion,tinsumo_codigo,tcostos_codigo,unidad_medida_codigo_ingreso,'.
                'unidad_medida_codigo_costo,insumo_merma,insumo_costo,moneda_codigo_costo,activo,usuario) values(\'' .
        $record->get_insumo_tipo() . '\',\'' .
        $record->get_insumo_codigo() . '\',\'' .
        $record->get_insumo_descripcion() . '\',\'' .
        $record->get_tinsumo_codigo() . '\',\'' .
        $record->get_tcostos_codigo() . '\',\'' .
        $record->get_unidad_medida_codigo_ingreso() . '\',\'' .
        $record->get_unidad_medida_codigo_costo() . '\',' .
        $record->get_insumo_merma() . ',' .
        $record->get_insumo_costo() . ',\'' .
        $record->get_moneda_codigo_costo() . '\',\'' .
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
            // Mapeamos las virtuales a los campos reales
            $where = str_replace('"unidad_medida_descripcion_ingreso"', 'umi.unidad_medida_descripcion', $where);
            $where = str_replace('"unidad_medida_descripcion_costo"', 'umc.unidad_medida_descripcion', $where);

            $sql .= ' and ' . $where;
        }

        // Dado que productos e insumos estan en la misma tabla segun el fetch
        // se limita el query.
        if ($subOperation == 'fetchInsumos') {
            $sql .= ' and  ins.insumo_tipo = \'IN\'';
        } else if ($subOperation == 'fetchProductos') {
            $sql .= ' and  ins.insumo_tipo = \'PR\'';
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
        //echo $sql;
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
        if ($subOperation == 'readAfterSaveJoined' || $subOperation == 'readAfterUpdateJoined') {
            $sql = $this->_getFecthNormalized();
            $sql .= ' where insumo_id =  \'' . $code . '\'';
        } else {
            $sql =  'select insumo_id,insumo_tipo,insumo_codigo,insumo_descripcion,tinsumo_codigo,tcostos_codigo,'.
                'unidad_medida_codigo_ingreso,unidad_medida_codigo_costo,insumo_merma,insumo_costo,moneda_codigo_costo,activo,' .
                'xmin as "versionId" from tb_insumo where insumo_id =  \'' . $code . '\'';
        }
        return $sql;
    }

    /**
     * Aqui el id es el codigo
     * @see TSLBasicRecordDAO::getUpdateRecordQuery()
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) {
        /* @var $record  InsumoModel  */

        return 'update tb_insumo set insumo_tipo=\''.$record->get_insumo_tipo().'\','.
        'insumo_codigo=\'' . $record->get_insumo_codigo() . '\','.
        'insumo_descripcion=\'' . $record->get_insumo_descripcion() . '\',' .
        'tinsumo_codigo=\'' . $record->get_tinsumo_codigo() . '\',' .
        'tcostos_codigo=\'' . $record->get_tcostos_codigo() . '\',' .
        'unidad_medida_codigo_ingreso=\'' . $record->get_unidad_medida_codigo_ingreso() . '\',' .
        'unidad_medida_codigo_costo=\'' . $record->get_unidad_medida_codigo_costo() . '\',' .
        'insumo_merma=' . $record->get_insumo_merma() . ',' .
        'insumo_costo=' . $record->get_insumo_costo() . ',' .
        'moneda_codigo_costo=\'' . $record->get_moneda_codigo_costo() . '\',' .
        'activo=\'' . $record->getActivo() . '\',' .
        'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
        ' where "insumo_id" = ' . $record->get_insumo_id() . '  and xmin =' . $record->getVersionId();

    }

    private function _getFecthNormalized() {
        $sql = 'select insumo_id,insumo_tipo,insumo_codigo,insumo_descripcion,ins.tinsumo_codigo,ti.tinsumo_descripcion,ins.unidad_medida_codigo_ingreso,ins.unidad_medida_codigo_costo,'.
                'umi.unidad_medida_descripcion as unidad_medida_descripcion_ingreso,umc.unidad_medida_descripcion as unidad_medida_descripcion_costo,ins.tcostos_codigo,tcostos_descripcion ,'.
                'insumo_merma,insumo_costo,moneda_codigo_costo,mn.moneda_descripcion,ins.activo,ins.xmin as "versionId" '.
            'from  tb_insumo ins '.
            'inner join tb_unidad_medida umi on umi.unidad_medida_codigo = ins.unidad_medida_codigo_ingreso '.
            'inner join tb_unidad_medida umc on umc.unidad_medida_codigo = ins.unidad_medida_codigo_costo '.
            'inner join tb_tcostos tc on tc.tcostos_codigo = ins.tcostos_codigo '.
            'inner join tb_tinsumo ti on ti.tinsumo_codigo = ins.tinsumo_codigo '.
            'inner join tb_moneda mn on mn.moneda_codigo = ins.moneda_codigo_costo ';
        return $sql;
    }

    protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL)
    {
        return 'SELECT currval(\'tb_insumo_insumo_id_seq\')';
    }
}

?>