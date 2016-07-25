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
     * @version $Id: AtletasResultadosDAO_postgre.php 201 2014-06-23 22:39:43Z aranape $
     * @history ''
     *
     * $Date: 2014-06-23 17:39:43 -0500 (lun, 23 jun 2014) $
     * $Rev: 201 $
     */
    class AtletasResultadosDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

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
            /* @var $record  AtletasResultadosModel */
            $sql = 'SELECT * FROM (SELECT sp_atletas_resultados_delete_record(' .
                $id . '::INTEGER,' .
                'FALSE::BOOLEAN,' .
                'NULL::CHARACTER VARYING,' .
                $versionId . '::INTEGER)  AS updins) AS ans WHERE updins IS NOT NULL';

            return $sql;
        }

        /**
         * @see \TSLBasicRecordDAO::getAddRecordQuery()
         */
        protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
            /* @var $record  AtletasResultadosModel */

            $sql = 'select sp_atletas_resultados_save_record(' .
                'null::integer,' .
                '\'' . $record->get_atletas_codigo() . '\'::character varying,' .
                $record->get_competencias_pruebas_id() . '::integer,' .
                ($record->get_postas_id() == NULL ? 'null' : $record->get_postas_id()) . '::integer,' .
                '\'' . $record->get_atletas_resultados_resultado() . '\'::character varying,' .
                ($record->get_atletas_resultados_puntos() == NULL ? '0' : $record->get_atletas_resultados_puntos()) . '::integer,' .
                ($record->get_atletas_resultados_puesto() == NULL ? 'null' : $record->get_atletas_resultados_puesto()) . '::integer,' .
                ($record->get_atletas_resultados_viento() == NULL ? 'null' : $record->get_atletas_resultados_viento()) . '::numeric,' .
                'false::boolean,' .
                '\'' . $record->getActivo() . '\'::boolean,' .
                '\'' . $record->getUsuario() . '\'::character varying,' .
                'null::integer,0::bit)';

            return $sql;
        }

        /**
         * @see \TSLBasicRecordDAO::getFetchQuery()
         */
        protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {

            if ($subOperation == 'fetchJoined') {

                $sql = 'SELECT
                          atletas_resultados_id,
                          ar.competencias_pruebas_id,
                          ar.atletas_codigo,
                          atletas_nombre_completo,
                          atletas_resultados_resultado,
                          atletas_resultados_puntos,
                          atletas_resultados_puesto,
                          atletas_resultados_viento,
                          ar.postas_id,
                          (CASE WHEN ar.postas_id IS NOT NULL
                            THEN  
                              (SELECT max(postas_descripcion) || \' - \' || array_to_string(ARRAY(SELECT unnest(array_agg(atl.atletas_ap_paterno))
                                                            ORDER BY 1), \',\')
                               FROM tb_postas_detalle pd
                               INNER JOIN tb_postas po ON po.postas_id = pd.postas_id
                               INNER JOIN tb_atletas atl ON atl.atletas_codigo = pd.atletas_codigo
                               WHERE pd.postas_id = ar.postas_id
                               GROUP BY pd.postas_id)
                          ELSE
                            NULL
                          END ) AS postas_atletas,
                          ar.activo, 
                          ar.xmin AS "versionId"
                        FROM tb_atletas_resultados ar
                        INNER JOIN tb_atletas AT ON AT.atletas_codigo = ar.atletas_codigo ';
            } else {
                $sql = 'select atletas_resultados_id,atletas_codigo,competencias_pruebas_id,atletas_resultados_resultado,atletas_resultados_puesto,atletas_resultados_puntos'
                    . ',atletas_resultados_viento,atletas_resultados_protected,'
                    . 'activo,xmin as "versionId" from  tb_atletas_resultados';
            }

            if ($this->activeSearchOnly == TRUE) {
                // Solo activos
                $sql .= ' where ar.activo=TRUE ';
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

            $sql = str_replace('"competencias_pruebas_id"', 'ar.competencias_pruebas_id', $sql);

            //   echo $sql;
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
            return 'select atletas_resultados_id,atletas_codigo,competencias_pruebas_id,atletas_resultados_resultado,atletas_resultados_puesto,'
            . 'atletas_resultados_puntos,atletas_resultados_viento,postas_id,atletas_resultados_protected,'
            . 'activo,xmin as "versionId" from  tb_atletas_resultados  ' .
            'where atletas_resultados_id =  ' . $code;
        }

        /**
         * Aqui el id es el codigo
         * @see \TSLBasicRecordDAO::getUpdateRecordQuery()
         */
        protected function getUpdateRecordQuery(\TSLDataModel &$record) {
            /* @var $record  AtletasResultadosModel */

            $sql = 'SELECT * FROM (SELECT sp_atletas_resultados_save_record(' .
                $record->get_atletas_resultados_id() . '::INTEGER,' .
                '\'' . $record->get_atletas_codigo() . '\'::CHARACTER VARYING,' .
                $record->get_competencias_pruebas_id() . '::INTEGER,' .
                ($record->get_postas_id() == NULL ? 'null' : $record->get_postas_id()) . '::INTEGER,' .
                '\'' . $record->get_atletas_resultados_resultado() . '\'::CHARACTER VARYING,' .
                ($record->get_atletas_resultados_puntos() == NULL ? '0' : $record->get_atletas_resultados_puntos()) . '::INTEGER,' .
                ($record->get_atletas_resultados_puesto() == NULL ? 'null' : $record->get_atletas_resultados_puesto()) . '::INTEGER,' .
                ($record->get_atletas_resultados_viento() == NULL ? 'null' : $record->get_atletas_resultados_viento()) . '::NUMERIC,' .
                'FALSE::BOOLEAN,' .
                '\'' . $record->getActivo() . '\'::BOOLEAN,' .
                '\'' . $record->get_Usuario_mod() . '\'::CHARACTER VARYING,' .
                $record->getVersionId() . '::INTEGER,1::BIT)  AS insupd) AS ans WHERE insupd IS NOT NULL;';

            return $sql;
        }

        protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL) {
            // Por la estructura del sp , aqui si durante un update la ultima operacion
            // es el insert , en caso se modificara cuidad aqui ya qeu habria que cambiar el metodo.
            return 'SELECT currval(pg_get_serial_sequence(\'tb_atletas_resultados\', \'atletas_resultados_id\'));';
        }

    }

?>