<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de la definicion de las items que componen
 * un producto.
 *
 * @author    Carlos Arana Reategui <aranape@gmail.com>
 * @version   0.1
 * @package   SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license   GPL
 *
 */
class ProductoDetalleDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre
{

    /**
     * Constructor se puede indicar si las busquedas solo seran en registros activos.
     *
     * @param boolean $activeSearchOnly
     */
    public function __construct($activeSearchOnly = TRUE)
    {
        parent::__construct($activeSearchOnly);
    }

    /**
     * @{inheritdoc}
     * @see \TSLBasicRecordDAO::getDeleteRecordQuery()
     */
    protected function getDeleteRecordQuery($id, $versionId)
    {
        return 'DELETE FROM tb_producto_detalle WHERE producto_detalle_id = ' . $id . '  AND xmin =' . $versionId;
    }

    /**
     * @{inheritdoc}
     * @see \TSLBasicRecordDAO::getAddRecordQuery()
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL)
    {
        /* @var $record  ProductoDetalleModel */

        return 'insert into tb_producto_detalle (insumo_id_origen,insumo_id,unidad_medida_codigo,producto_detalle_cantidad,'
        . 'producto_detalle_merma,activo,usuario) values(' .
        $record->get_insumo_id_origen() . ',' .
        $record->get_insumo_id() . ',\'' .
        $record->get_unidad_medida_codigo() . '\',' .
        $record->get_producto_detalle_cantidad() . ',' .
        $record->get_producto_detalle_merma() . ',\'' .
        $record->getActivo() . '\',\'' .
        $record->getUsuario() . '\')';

    }

    /**
     * @{inheritdoc}
     * @see \TSLBasicRecordDAO::getFetchQuery()
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL)
    {

        if ($subOperation == 'fetchJoined') {
            $sql = $this->_getFecthNormalized();
        } else {
            $sql = 'SELECT producto_detalle_id,insumo_id_origen,insumo_id,unidad_medida_codigo,producto_detalle_cantidad,'.
                   'producto_detalle_merma,activo,xmin AS "versionId" ' .
                   'FROM  tb_producto_detalle pd ';
        }

        if ($this->activeSearchOnly == TRUE) {
            // Solo activos
            $sql .= ' where pd.activo=TRUE ';
        }

        $where = $constraints->getFilterFieldsAsString();

        if (strlen($where) > 0) {
            // Mapeamos las virtuales a los campos reales
         //   $where = str_replace('"unidad_medida_descripcion_o"', 'um1.unidad_medida_descripcion', $where);
         //   $where = str_replace('"unidad_medida_descripcion_d"', 'um2.unidad_medida_descripcion', $where);

            if ($this->activeSearchOnly == TRUE) {
                $sql .= ' and ' . $where;
            } else {
                $sql .= ' where ' . $where;
            }
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
     * @{inheritdoc}
     * @see \TSLBasicRecordDAO::getRecordQuery()
     */
    protected function getRecordQuery($id, $subOperation = NULL)
    {
        // en este caso el codigo es la llave primaria
        return $this->getRecordQueryByCode($id, $subOperation);
    }

    /**
     * @{inheritdoc}
     * @see \TSLBasicRecordDAO::getRecordQueryByCode()
     */
    protected function getRecordQueryByCode($code, $subOperation = NULL)
    {
        if ($subOperation == 'readAfterSaveJoined' || $subOperation == 'readAfterUpdateJoined') {
            $sql = $this->_getFecthNormalized();
            $sql .= ' WHERE producto_detalle_id = ' . $code;
        } else {
            $sql =  'SELECT producto_detalle_id,insumo_id_origen,insumo_id,unidad_medida_codigo,producto_detalle_cantidad,'.
                    'producto_detalle_merma,activo,xmin AS "versionId" ' .
                    'FROM tb_producto_detalle WHERE producto_detalle_id = ' . $code;
        }
        return $sql;
    }

    /**
     *
     * @{inheritdoc}
     * @see \TSLBasicRecordDAO::getUpdateRecordQuery()
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record)
    {

        /* @var $record  ProductoDetalleModel */

        return 'update tb_producto_detalle set insumo_id=' . $record->get_insumo_id() . ',' .
        'insumo_id_origen=' . $record->get_insumo_id_origen() . ',' .
        'unidad_medida_codigo=\'' . $record->get_unidad_medida_codigo() . '\',' .
        'producto_detalle_cantidad=' . $record->get_producto_detalle_cantidad() . ',' .
        'producto_detalle_merma=' . $record->get_producto_detalle_merma() . ',' .
        'activo=\'' . $record->getActivo() . '\',' .
        'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
        ' where "producto_detalle_id" = ' . $record->get_producto_detalle_id() . '  and xmin =' . $record->getVersionId();

    }

    private function _getFecthNormalized() {
        $sql = 'SELECT producto_detalle_id,insumo_id_origen,pd.insumo_id,insumo_descripcion,pd.unidad_medida_codigo,unidad_medida_descripcion,'.
            'producto_detalle_cantidad,(select fn_get_producto_detalle_costo(producto_detalle_id, now()::date)) as producto_detalle_costo,producto_detalle_merma,moneda_simbolo,pd.activo,pd.xmin AS "versionId" ' .
            'FROM  tb_producto_detalle pd ' .
            'INNER JOIN tb_unidad_medida um1 on um1.unidad_medida_codigo = pd.unidad_medida_codigo ' .
            'INNER JOIN tb_insumo ins on ins.insumo_id = pd.insumo_id '.
            'INNER JOIN tb_moneda mon on mon.moneda_codigo = ins.moneda_codigo_costo ';
        return $sql;
    }

    protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL)
    {
        return 'SELECT currval(\'tb_producto_detalle_producto_detalle_id_seq\')';
    }
}