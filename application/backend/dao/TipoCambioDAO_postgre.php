<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico el mantenimiento de la definicion de los registros
 * del tipo de cambio.
 *
 * @author    Carlos Arana Reategui <aranape@gmail.com>
 * @version   0.1
 * @package   SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license   GPL
 *
 */
class TipoCambioDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre
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
        return 'DELETE FROM tb_tipo_cambio WHERE tipo_cambio_id = ' . $id . '  AND xmin =' . $versionId;
    }

    /**
     * @{inheritdoc}
     * @see \TSLBasicRecordDAO::getAddRecordQuery()
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL)
    {
        /* @var $record  TipoCambioModel */

        return 'insert into tb_tipo_cambio (moneda_codigo_origen,moneda_codigo_destino,tipo_cambio_fecha_desde,' .
        'tipo_cambio_fecha_hasta,tipo_cambio_tasa,activo,usuario) values(\'' .
        $record->get_moneda_codigo_origen() . '\',\'' .
        $record->get_moneda_codigo_destino() . '\',\'' .
        $record->get_tipo_cambio_fecha_desde() . '\',\'' .
        $record->get_tipo_cambio_fecha_hasta() . '\',' .
        $record->get_tipo_cambio_tasa() . ',\'' .
        $record->getActivo() . '\',\'' .
        $record->getUsuario() . '\')';

    }

    /**
     * @{inheritdoc}
     * @see \TSLBasicRecordDAO::getFetchQuery()
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL)
    {

        $sql = $this->_getFecthNormalized();

        if ($this->activeSearchOnly == TRUE) {
            // Solo activos
            $sql .= ' where pd.activo=TRUE ';
        }

        $where = $constraints->getFilterFieldsAsString();

        if (strlen($where) > 0) {
            // Mapeamos las virtuales a los campos reales
            $where = str_replace('"moneda_descripcion_o"', 'mo_o.moneda_descripcion', $where);
            $where = str_replace('"moneda_descripcion_d"', 'mo_d.moneda_descripcion', $where);
            
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
            $sql .= ' where tipo_cambio_id = ' . $code;
        } else {
            $sql =  'SELECT tipo_cambio_id,moneda_codigo_origen,moneda_codigo_destino,tipo_cambio_fecha_desde,'.
                'tipo_cambio_fecha_hasta,tipo_cambio_tasa,activo,xmin AS "versionId" ' .
                'FROM tb_tipo_cambio WHERE tipo_cambio_id = ' . $code;
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

        /* @var $record  TipoCambioModel */

        return 'update tb_tipo_cambio set tipo_cambio_id=' . $record->get_tipo_cambio_id() . ',' .
        'moneda_codigo_origen=\'' . $record->get_moneda_codigo_origen() . '\',' .
        'moneda_codigo_destino=\'' . $record->get_moneda_codigo_destino() . '\',' .
        'tipo_cambio_fecha_desde=\'' . $record->get_tipo_cambio_fecha_desde() . '\',' .
        'tipo_cambio_fecha_hasta=\'' . $record->get_tipo_cambio_fecha_hasta() . '\',' .
        'tipo_cambio_tasa=' . $record->get_tipo_cambio_tasa() . ',' .
        'activo=\'' . $record->getActivo() . '\',' .
        'usuario_mod=\'' . $record->get_Usuario_mod() . '\'' .
        ' where "tipo_cambio_id" = ' . $record->get_tipo_cambio_id() . '  and xmin =' . $record->getVersionId();

    }

    protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL)
    {
        return 'SELECT currval(\'tb_tipo_cambio_tipo_cambio_id_seq\')';
    }

    private function _getFecthNormalized() {
        $sql = 'SELECT tipo_cambio_id,pd.moneda_codigo_origen,mo_o.moneda_descripcion as moneda_descripcion_o,'.
            'pd.moneda_codigo_destino,mo_d.moneda_descripcion as moneda_descripcion_d,tipo_cambio_fecha_desde,' .
            'tipo_cambio_fecha_hasta,tipo_cambio_tasa,pd.activo,pd.xmin AS "versionId" ' .
            'FROM  tb_tipo_cambio pd '.
            'INNER JOIN tb_moneda mo_o on mo_o.moneda_codigo = pd.moneda_codigo_origen '.
            'INNER JOIN tb_moneda mo_d on mo_d.moneda_codigo = pd.moneda_codigo_destino ';
        return $sql;
    }

}