<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico para obtener datos de los records basicamente para usarse
 * en los graficos.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: RecordsGraphDAO_postgre.php 336 2014-12-03 06:52:18Z aranape $
 * @history ''
 *
 * $Date: 2014-12-03 01:52:18 -0500 (mié, 03 dic 2014) $
 * $Rev: 336 $
 */
class RecordsGraphDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

    /**
     * Constructor se puede indicar si las busquedas solo seran en registros activos.
     * @param boolean $activeSearchOnly
     */
    public function __construct($activeSearchOnly = TRUE) {
        parent::__construct(FALSE); // se permite siempre la busqueda incluyendo activos o no.
    }

    /**
     * @see \TSLBasicRecordDAO::getDeleteRecordQuery()
     */
    protected function getDeleteRecordQuery($id, $versionId) {
        return NULL;
    }

    /**
     * @see \TSLBasicRecordDAO::getAddRecordQuery()
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
        return NULL;
    }

    /**
     * @see \TSLBasicRecordDAO::getFetchQuery()
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {

        $sql ='';
        if ($subOperation == 'fetchRecordsResumen') {
            $sql = 'select * from  sp_view_resumen_records_por_prueba_categorias(\'' .
                    $constraints->getFilterField('apppruebas_codigo') . '\',\'' .
                    $constraints->getFilterField('atletas_sexo') . '\',' . '\'' .
                    $constraints->getFilterField('records_tipo_codigo') . '\',' . '\'' .
                    $constraints->getFilterField('fecha_desde') . '\',\'' .
                    $constraints->getFilterField('fecha_hasta') . '\',\'' .
                    $constraints->getFilterField('categorias_codigo') . '\',' .
                    $constraints->getFilterField('incluye_manuales') . ',' .
                    $constraints->getFilterField('incluye_altura') . ',null)';
        }
        return $sql;
    }

    /**
     * @see \TSLBasicRecordDAO::getRecordQuery()
     */
    protected function getRecordQuery($id) {
        return NULL;
    }

    /**
     * @see \TSLBasicRecordDAO::getRecordQueryByCode()
     */
    protected function getRecordQueryByCode($code) {
        return NULL;
    }

    /**
     * Aqui el id es el codigo
     * @see \TSLBasicRecordDAO::getUpdateRecordQuery()
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) {
        return NULL;
    }

}

?>