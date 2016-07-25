<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO es especifico para el mantenimiento de los detalles de los resultados de
 * de una prueba. basicamente es para las pruebas que componen una prueba combinada çno debe usarse para las pruebas normales.
 * A diferencia del manejo directo de resultados este maneja dualmente las pruebas (puede cambiar los datos)
 * y los resultados en si ya que DAO es para ser usado cuando se ingresan datos a traves del atleta y no a traves
 * de la competencia misma.
 *
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: AtletasResultadosGraphDAO_postgre.php 267 2014-06-27 18:06:46Z aranape $
 * @history ''
 *
 * $Date: 2014-06-27 13:06:46 -0500 (vie, 27 jun 2014) $
 * $Rev: 267 $
 */
class AtletasResultadosGraphDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

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
        $sql = '';
        // Construyo el arreglo pgsql de atletas
        $prefix = '';
        $atletasArray = '\'{';
        for ($i = 1; $i <= 5; $i++) {
            $atleta_num = ('atletas_codigo_0' . $i);
            if ($constraints->getFilterField($atleta_num)) {
                $atletasArray .= ($prefix . $constraints->getFilterField($atleta_num) . '');
            }
            $prefix = ',';
        }
        $atletasArray .='}\'';

        if ($subOperation == 'fetchResultadosPorPrueba') {

            $sql = 'select * from  sp_view_resumen_resultados_por_prueba_atletas(\'' .
                    $constraints->getFilterField('apppruebas_codigo') . '\'' .
                    ',' . $atletasArray . ',' . '\'' .
                    $constraints->getFilterField('atletas_sexo') . '\',' . '\'' .
                    $constraints->getFilterField('fecha_desde') . '\',\'' .
                    $constraints->getFilterField('fecha_hasta') . '\',\'' .
                    $constraints->getFilterField('categorias_desde') . '\',\'' .
                    $constraints->getFilterField('categorias_hasta') . '\',' .
                    $constraints->getFilterField('incluye_manuales') . ',' .
                    $constraints->getFilterField('incluye_observadas') . ',null)';
        } else if ($subOperation == 'fetchResultadosPorPruebaTopN') {
            $sql = 'select * from  sp_view_resumen_topn_resultados_por_prueba_atletas(\'' .
                    $constraints->getFilterField('apppruebas_codigo') . '\'' .
                    ',' . $atletasArray . ',' . '\'' .
                    $constraints->getFilterField('atletas_sexo') . '\',' . '\'' .
                    $constraints->getFilterField('fecha_desde') . '\',\'' .
                    $constraints->getFilterField('fecha_hasta') . '\',\'' .
                    $constraints->getFilterField('categorias_desde') . '\',\'' .
                    $constraints->getFilterField('categorias_hasta') . '\',' .
                    $constraints->getFilterField('incluye_manuales') . ',' .
                    $constraints->getFilterField('incluye_observadas') . ',' .
                    $constraints->getFilterField('n_records') . ')';
        }


        //  $sql = str_replace('"competencias_pruebas_id"', 'ar.competencias_pruebas_id', $sql);
        //  echo $sql;
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