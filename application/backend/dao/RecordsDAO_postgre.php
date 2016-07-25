<?php

    if (!defined('BASEPATH'))
        exit('No direct script access allowed');

    /**
     * Este DAO es especifico el mantenimiento de los records de diversa indole, sean
     * mundiales,nacionales,etc.
     *
     * @author  $Author: aranape $
     * @since   06-FEB-2013
     * @version $Id: RecordsDAO_postgre.php 307 2014-07-16 02:17:13Z aranape $
     * @history ''
     *
     * $Date: 2014-07-15 21:17:13 -0500 (mar, 15 jul 2014) $
     * $Rev: 307 $
     */
    class RecordsDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

        /**
         * Constructor se puede indicar si las busquedas solo seran en registros activos.
         *
         * @param boolean $activeSearchOnly
         */
        public function __construct($activeSearchOnly = TRUE) {
            parent::__construct(FALSE); // se permite siempre la busqueda incluyendo activos o no.
        }

        /**
         * @see \TSLBasicRecordDAO::getDeleteRecordQuery()
         */
        protected function getDeleteRecordQuery($id, $versionId) {
            return 'SELECT * FROM ( SELECT sp_records_delete( ' . $id . '::INTEGER,NULL::CHARACTER VARYING,' . $versionId . '::INTEGER)  AS updins) AS ans WHERE updins IS NOT NULL';
        }

        /**
         * @see \TSLBasicRecordDAO::getAddRecordQuery()
         */
        protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
            /* @var $record  RecordsModel */

            $sql = 'select sp_records_save_record(NULL::integer,' .
                '\'' . $record->get_records_tipo_codigo() . '\'::character varying,' .
                $record->get_atletas_resultados_id() . '::integer,' .
                '\'' . $record->get_categorias_codigo() . '\'::character varying,' .
                ($record->get_records_id_origen() ? $record->get_records_id_origen() : 'NULL') . '::integer,' .
                '\'' . $record->get_records_protected() . '\'::boolean,' .
                '\'' . ($record->getActivo() != TRUE ? '0' : '1') . '\'::boolean,' .
                '\'' . $record->getUsuario() . '\'::character varying,NULL::integer,0::BIT);';

            return $sql;
        }

        /**
         * @see \TSLBasicRecordDAO::getFetchQuery()
         */
        protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {

            if ($subOperation == 'fetchJoined') {
                $sql = 'SELECT * FROM (
                    SELECT
                    records_id,
                    records_tipo_codigo,
                    rec.atletas_resultados_id,
                    rec.categorias_codigo,
                    apppruebas_codigo,
                    apppruebas_descripcion,
                     (CASE WHEN eatl.postas_id IS NOT NULL
                        THEN
                          (SELECT array_to_string(ARRAY(SELECT unnest(array_agg(atl.atletas_codigo))
                                                        ORDER BY 1), \',\')
                           FROM tb_postas_detalle pd
                             INNER JOIN tb_postas po ON po.postas_id = pd.postas_id
                             INNER JOIN tb_atletas atl ON atl.atletas_codigo = pd.atletas_codigo
                           WHERE pd.postas_id = eatl.postas_id
                           GROUP BY pd.postas_id)
                       ELSE
                         atl.atletas_codigo
                         END) AS atletas_codigo,
                  (CASE WHEN eatl.postas_id IS NOT NULL
                    THEN
                      (SELECT array_to_string(ARRAY(SELECT unnest(array_agg(atl.atletas_ap_paterno))
                                                                                        ORDER BY 1), \',\')
                       FROM tb_postas_detalle pd
                         INNER JOIN tb_postas po ON po.postas_id = pd.postas_id
                         INNER JOIN tb_atletas atl ON atl.atletas_codigo = pd.atletas_codigo
                       WHERE pd.postas_id = eatl.postas_id
                       GROUP BY pd.postas_id)
                   ELSE
                     atletas_nombre_completo
                   END ) AS atletas_nombre_completo,
                    atl.atletas_sexo,
                    fn_get_marca_normalizada_tonumber(fn_get_marca_normalizada_totext(atletas_resultados_resultado, um.unidad_medida_codigo, cp.competencias_pruebas_manual, pv.apppruebas_factor_manual), um.unidad_medida_codigo) AS numb_resultado,
                    atletas_resultados_resultado,
                    ciudades_altura,
                    coalesce((CASE WHEN apppruebas_viento_individual = TRUE THEN eatl.atletas_resultados_viento ELSE competencias_pruebas_viento END),0.00) AS competencias_pruebas_viento,
                    competencias_pruebas_fecha,
                    co.competencias_descripcion || \' / \' || ciudades_descripcion || \' / \'  || paises_descripcion AS lugar,
                    --co.competencias_descripcion,
                    --ciudades_descripcion,
                    --paises_descripcion,
                    eatl.postas_id,
                    rec.activo,
                    rec.xmin AS "versionId"
                    FROM tb_records rec
                INNER JOIN tb_atletas_resultados eatl ON eatl.atletas_resultados_id = rec.atletas_resultados_id
                INNER JOIN tb_competencias_pruebas cp ON cp.competencias_pruebas_id = eatl.competencias_pruebas_id
                INNER JOIN tb_atletas atl ON eatl.atletas_codigo = atl.atletas_codigo
                INNER JOIN tb_pruebas pr ON pr.pruebas_codigo = cp.pruebas_codigo
                INNER JOIN tb_app_pruebas_values pv ON pv.apppruebas_codigo = pr.pruebas_generica_codigo
                INNER JOIN tb_competencias co ON co.competencias_codigo = cp.competencias_codigo
                INNER JOIN tb_ciudades ciu ON ciu.ciudades_codigo = co.ciudades_codigo
                INNER JOIN tb_paises pa ON pa.paises_codigo = ciu.paises_codigo
                INNER JOIN tb_pruebas_clasificacion cl ON cl.pruebas_clasificacion_codigo = pv.pruebas_clasificacion_codigo
                INNER JOIN tb_unidad_medida um ON um.unidad_medida_codigo = cl.unidad_medida_codigo
                ) rec';
            } else {
                $sql = 'SELECT records_id,records_tipo_codigo,atletas_resultados_id,categorias_codigo,records_id_origen,records_protected,activo,xmin AS "versionId" FROM  tb_records rec';
            }


            if ($this->activeSearchOnly == TRUE) {
                // Solo activos
                $sql .= ' where "rec.activo"=TRUE ';
            }

            // Que pasa si el campo a buscar existe en ambas partes del join?
            $where = $constraints->getFilterFieldsAsString();
            //  echo $where;
            if ($this->activeSearchOnly == TRUE) {
                if (strlen($where) > 0) {
                    $sql .= ' and ' . $where;
                }
            } else {
                if (strlen($where) > 0) {
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
            return 'select records_id,records_tipo_codigo,atletas_resultados_id,categorias_codigo,records_id_origen,records_protected,activo,' .
            'xmin as "versionId" from tb_records where "records_id" =  ' . $code;
        }

        /**
         * Aqui el id es el codigo
         * @see \TSLBasicRecordDAO::getUpdateRecordQuery()
         */
        protected function getUpdateRecordQuery(\TSLDataModel &$record) {
            /* @var $record  RecordsModel */
            $sql = 'SELECT * FROM (SELECT sp_records_save_record(' .
                $record->get_records_id() . '::INTEGER,' .
                '\'' . $record->get_records_tipo_codigo() . '\'::CHARACTER VARYING,' .
                $record->get_atletas_resultados_id() . '::INTEGER,' .
                '\'' . $record->get_categorias_codigo() . '\'::CHARACTER VARYING,' .
                ($record->get_records_id_origen() ? $record->get_records_id_origen() : 'NULL') . '::INTEGER,' .
                '\'' . $record->get_records_protected() . '\'::BOOLEAN,' .
                '\'' . ($record->getActivo() != TRUE ? '0' : '1') . '\'::boolean,' .
                '\'' . $record->get_Usuario_mod() . '\'::varchar,' .
                $record->getVersionId() . '::INTEGER,1::BIT) AS insupd) AS ans WHERE insupd IS NOT NULL;';

            return $sql;
        }

        protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL) {
            //    return 'SELECT currval(\'tb_records_records_id_seq\')';

            // Dado que pueden grabarse multiples records basados en uno no usamos directamente  el sequence
            // ya que no neceariamente retornara el id correcto para el ingresado ya que devolveria el ultimo agregado que
            // no es necesariamente el principal.
            /* @var $record  RecordsModel */
            $sql = 'SELECT records_id FROM tb_records WHERE atletas_resultados_id= ' . $record->get_atletas_resultados_id() . ' AND  categorias_codigo = \'' . $record->get_categorias_codigo() .
                '\' AND records_tipo_codigo  = \'' . $record->get_records_tipo_codigo() . '\' ';

            return $sql;
        }

    }

?>