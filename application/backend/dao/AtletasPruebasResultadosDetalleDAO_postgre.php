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
 * @version $Id: AtletasPruebasResultadosDetalleDAO_postgre.php 201 2014-06-23 22:39:43Z aranape $
 * @history ''
 *
 * $Date: 2014-06-23 17:39:43 -0500 (lun, 23 jun 2014) $
 * $Rev: 201 $
 */
class AtletasPruebasResultadosDetalleDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

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
        return 'delete from tb_atletas_resultados where atletas_resultados_id = \'' . $id . '\'  and xmin =' . $versionId;
    }

    /**
     * @see \TSLBasicRecordDAO::getAddRecordQuery()
     */
    protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
        /* @var $record  AtletasPruebasResultadosDetalleModel  */

        $sql = 'select sp_atletas_pruebas_resultados_detalle_save_record(' .
                'null::integer,' .
                $record->get_competencias_pruebas_id() . '::integer,' .
                '\'' . $record->get_atletas_codigo() . '\'::character varying,' .
                '\'' . $record->get_competencias_pruebas_fecha() . '\'::date,' .
                ($record->get_competencias_pruebas_viento() == null ? 'null' : $record->get_competencias_pruebas_viento()) . '::numeric,' .
                '\'' . $record->get_competencias_pruebas_anemometro() . '\'::boolean,' .
                '\'' . $record->get_competencias_pruebas_material_reglamentario() . '\'::boolean,' .
                '\'' . $record->get_competencias_pruebas_manual() . '\'::boolean,' .
                '\'' . $record->get_competencias_pruebas_observaciones() . '\'::character varying,' .
                '\'' . $record->get_atletas_resultados_resultado() . '\'::character varying,' .
                $record->get_atletas_resultados_puntos() . '::integer,' .
                ($record->get_atletas_resultados_puesto() == null ? 'null' : $record->get_atletas_resultados_puesto()) . '::integer,' . 'false::boolean,' .
                '\'' . $record->getActivo() . '\'::boolean,' .
                '\'' . $record->getUsuario() . '\'::character varying,' .
                'null::integer)';

        return $sql;
    }

    /**
     * @see \TSLBasicRecordDAO::getFetchQuery()
     */
    protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {

        if ($subOperation == 'fetchJoined') {

            $sql = 'select eatl.competencias_pruebas_id,eatl.competencias_pruebas_origen_id,eatl.competencias_codigo,atletas_resultados_id,eatl.pruebas_codigo,competencias_pruebas_fecha,' .
                    '(case when apppruebas_viento_individual = TRUE THEN ar.atletas_resultados_viento ELSE competencias_pruebas_viento END) as competencias_pruebas_viento,' .
                    'competencias_pruebas_manual,competencias_pruebas_tipo_serie,competencias_pruebas_nro_serie,' .
                    'competencias_pruebas_anemometro, competencias_pruebas_material_reglamentario, competencias_pruebas_origen_combinada, competencias_pruebas_observaciones, ' .
                    'coalesce(atletas_codigo,\'' . $constraints->getFilterField('atletas_codigo') . '\') as atletas_codigo,atletas_resultados_resultado,atletas_resultados_puntos,atletas_resultados_puesto,pr.pruebas_descripcion,apppruebas_marca_menor,' .
                    'apppruebas_marca_menor,apppruebas_verifica_viento,unidad_medida_regex_e,unidad_medida_tipo,unidad_medida_regex_m,' .
                    'eatl.activo,ar.xmin as "versionId" ' .
                    'from  tb_competencias_pruebas eatl ' .
                    'left join tb_atletas_resultados ar on ar.competencias_pruebas_id = eatl.competencias_pruebas_id ' .
                    'inner join tb_pruebas pr on pr.pruebas_codigo =eatl.pruebas_codigo ' .
                    'inner join tb_app_pruebas_values pv on pv.apppruebas_codigo = pr.pruebas_generica_codigo ' .
                    'inner join tb_pruebas_clasificacion cl on cl.pruebas_clasificacion_codigo = pv.pruebas_clasificacion_codigo ' .
                    'inner join tb_unidad_medida um on um.unidad_medida_codigo = cl.unidad_medida_codigo ';
            // 'where competencias_pruebas_origen_id  is not null and atletas_codigo=\'46658908\'';
        } else if ($subOperation == 'fetchDetalleForPrueba') {
            $sql = 'select * from sp_view_prueba_resultados_detalle(' . $constraints->getFilterField('atletas_resultados_id') . ') ';
            $constraints->removeFilterField('atletas_resultados_id');
        } else {
            $sql = 'select competencias_pruebas_id,atletas_resultados_id,atletas_codigo,competencias_codigo,'
                    . '(case when apppruebas_viento_individual = TRUE THEN eatl.atletas_resultados_viento ELSE competencias_pruebas_viento END) as competencias_pruebas_viento,'
                    . 'competencias_pruebas_manual,'
                    . 'pruebas_codigo,competencias_pruebas_origen_combinada,competencias_pruebas_fecha,'
                    . 'competencias_pruebas_tipo_serie,competencias_pruebas_nro_serie,'
                    . 'competencias_pruebas_anemometro,competencias_pruebas_material_reglamentario,'
                    . 'competencias_pruebas_observaciones,atletas_resultados_resultado,atletas_resultados_puntos,atletas_resultados_puesto,'
                    . 'activo,xmin as "versionId" from  tb_atletas_resultados eatl '
                    . 'inner join tb_competencias_pruebas cp on cp.competencias_pruebas_id = eatl.competencias_pruebas_id '
                    . 'inner join tb_pruebas pr on pr.pruebas_codigo =eatl.pruebas_codigo '
                    . 'inner join tb_app_pruebas_values pv on pv.apppruebas_codigo = pr.pruebas_generica_codigo ';
        }

        if ($this->activeSearchOnly == TRUE) {
            // Solo activos
            $sql .= ' where eatl.activo=TRUE ';
        }

        // Que pasa si el campo a buscar existe en ambas partes del join?
        $where = $constraints->getFilterFieldsAsString();
        if (strlen($where) > 0) {
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

        $sql = str_replace('"atletas_resultados_id"', 'eatl.atletas_resultados_id', $sql);
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
        return 'select atletas_resultados_id,atletas_codigo,eatl.competencias_pruebas_id,atletas_resultados_resultado,atletas_resultados_puesto,atletas_resultados_puntos,competencias_pruebas_origen_id,' .
                '(case when apppruebas_viento_individual = TRUE THEN eatl.atletas_resultados_viento ELSE competencias_pruebas_viento END) as competencias_pruebas_viento,' .
                'eatl.activo,eatl.xmin as "versionId" from  tb_atletas_resultados eatl ' .
                'inner join tb_competencias_pruebas cp on cp.competencias_pruebas_id = eatl.competencias_pruebas_id ' .
                'inner join tb_pruebas pr on pr.pruebas_codigo =cp.pruebas_codigo ' .
                'inner join tb_app_pruebas_values pv on pv.apppruebas_codigo = pr.pruebas_generica_codigo ' .
                'where atletas_resultados_id =  ' . $code;
    }

    /**
     * Aqui el id es el codigo
     * @see \TSLBasicRecordDAO::getUpdateRecordQuery()
     */
    protected function getUpdateRecordQuery(\TSLDataModel &$record) {

        /* @var $record  AtletasPruebasResultadosDetalleModel  */

        $sql = 'select * from (select sp_atletas_pruebas_resultados_detalle_save_record(' .
                $record->get_atletas_resultados_id() . '::integer,' .
                $record->get_competencias_pruebas_id() . '::integer,' .
                '\'' . $record->get_atletas_codigo() . '\'::character varying,' .
                '\'' . $record->get_competencias_pruebas_fecha() . '\'::date,' .
                ($record->get_competencias_pruebas_viento() == null ? 'null' : $record->get_competencias_pruebas_viento()) . '::numeric,' .
                '\'' . $record->get_competencias_pruebas_anemometro() . '\'::boolean,' .
                '\'' . $record->get_competencias_pruebas_material_reglamentario() . '\'::boolean,' .
                '\'' . $record->get_competencias_pruebas_manual() . '\'::boolean,' .
                '\'' . $record->get_competencias_pruebas_observaciones() . '\'::character varying,' .
                '\'' . $record->get_atletas_resultados_resultado() . '\'::character varying,' .
                $record->get_atletas_resultados_puntos() . '::integer,' .
                ($record->get_atletas_resultados_puesto() == null ? 'null' : $record->get_atletas_resultados_puesto()) . '::integer,' .
                'false::boolean,' .
                '\'' . $record->getActivo() . '\'::boolean,' .
                '\'' . $record->get_Usuario_mod() . '\'::character varying,' .
                $record->getVersionId() . '::integer)  as insupd) as ans where insupd is not null;';
        return $sql;
    }

    protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL) {
        // Por la estructura del sp , aqui si durante un update la ultima operacion
        // es el insert , en caso se modificara cuidad aqui ya qeu habria que cambiar el metodo.
        return 'SELECT currval(pg_get_serial_sequence(\'tb_atletas_resultados\', \'atletas_resultados_id\'));';
    }

}

?>