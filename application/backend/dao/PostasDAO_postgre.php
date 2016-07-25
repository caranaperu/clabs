<?php

    if (!defined('BASEPATH'))
        exit('No direct script access allowed');

    /**
     * Este DAO es especifico el mantenimiento de la definicion de postas para cada
     * competencia-prueba.
     *
     *
     * @author    Carlos Arana Reategui <aranape@gmail.com>
     * @version   0.1
     * @package   SoftAthletics
     * @copyright 2015-2016 Carlos Arana Reategui.
     * @license   GPL
     *
     */
    class PostasDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

        /**
         * Constructor se puede indicar si las busquedas solo seran en registros activos.
         *
         * @param boolean $activeSearchOnly
         */
        public function __construct($activeSearchOnly = TRUE) {
            parent::__construct($activeSearchOnly);
        }

        /**
         * @{inheritdoc}
         * @see \TSLBasicRecordDAO::getDeleteRecordQuery()
         */
        protected function getDeleteRecordQuery($id, $versionId) {
            return 'SELECT * FROM ( SELECT sp_postas_delete_record(' . $id . ',NULL,' . $versionId . ')  AS updins) AS ans WHERE updins IS NOT NULL';
        }

        /**
         * @{inheritdoc}
         * @see \TSLBasicRecordDAO::getAddRecordQuery()
         */
        protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
            /* @var $record  PostasModel */

            $sql = 'select sp_postas_save_record(' .
                'null::INTEGER,' .
                '\'' . $record->get_postas_descripcion() . '\'::character varying,' .
                $record->get_competencias_pruebas_id() . '::integer,' .
                '\'' . $record->getActivo() . '\'::boolean,' .
                '\'' . $record->getUsuario() . '\'::character varying,' .
                'null::integer, 0::BIT)';

            return $sql;
        }

        /**
         * @{inheritdoc}
         * @see \TSLBasicRecordDAO::getFetchQuery()
         */
        protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {


            if ($subOperation === 'fetchJoinedWithNames') {
                $postas_id = $constraints->getFilterField('postas_id');
                if ($postas_id) {
                    $sql = 'SELECT * FROM (
                       SELECT po.postas_id,postas_descripcion,array_to_string(ARRAY(SELECT unnest(array_agg(atl.atletas_ap_paterno))
                                 ORDER BY 1),\',\') AS postas_atletas
                       FROM tb_postas po
                       LEFT JOIN tb_postas_detalle pd ON pd.postas_id = po.postas_id
                       LEFT JOIN tb_atletas atl ON atl.atletas_codigo = pd.atletas_codigo
                       WHERE po.postas_id=' . $postas_id .
                        ' GROUP BY po.postas_id
                       ORDER BY  postas_descripcion
                   ) res';
                    $constraints->removeFilterField('postas_id');
                } else {
                    $sql = 'SELECT * FROM (
                       SELECT po.postas_id,postas_descripcion,array_to_string(ARRAY(SELECT unnest(array_agg(atl.atletas_ap_paterno))
                                 ORDER BY 1),\',\') AS postas_atletas
                       FROM tb_postas po
                       LEFT JOIN tb_postas_detalle pd ON pd.postas_id = po.postas_id
                       LEFT JOIN tb_atletas atl ON atl.atletas_codigo = pd.atletas_codigo
                       WHERE po.competencias_pruebas_id=' . $constraints->getFilterField('competencias_pruebas_id') .
                        ' GROUP BY po.postas_id
                       ORDER BY  postas_descripcion
                   ) res';
                    $constraints->removeFilterField('competencias_pruebas_id');
                }

            } else {
                $sql = 'SELECT postas_id,postas_descripcion,competencias_pruebas_id,activo,xmin AS "versionId" FROM  tb_postas ';
            }

            if ($this->activeSearchOnly == TRUE && $subOperation != 'fetchJoinedWithNames') {
                // Solo activos
                $sql .= ' where activo=TRUE ';
            }

            $where = $constraints->getFilterFieldsAsString();

            if (strlen($where) > 0) {
                if ($this->activeSearchOnly == TRUE && $subOperation != 'fetchJoinedWithNames') {
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
            //echo $sql;

            return $sql;
        }

        /**
         * @{inheritdoc}
         * @see \TSLBasicRecordDAO::getRecordQuery()
         */
        protected function getRecordQuery($id) {
            // en este caso el codigo es la llave primaria
            return $this->getRecordQueryByCode($id);
        }

        /**
         * @{inheritdoc}
         * @see \TSLBasicRecordDAO::getRecordQueryByCode()
         */
        protected function getRecordQueryByCode($code) {
            return 'select postas_id,postas_descripcion,competencias_pruebas_id,' .
            'xmin as "versionId" from tb_postas where postas_id = ' . $code;
        }

        /**
         *
         * @{inheritdoc}
         * @see \TSLBasicRecordDAO::getUpdateRecordQuery()
         */
        protected function getUpdateRecordQuery(\TSLDataModel &$record) {
            /* @var $record  PostasModel */
            $sql = 'SELECT * FROM (SELECT  sp_postas_save_record(' .
                $record->get_postas_id() . '::INTEGER,' .
                '\'' . $record->get_postas_descripcion() . '\'::CHARACTER VARYING,' .
                $record->get_competencias_pruebas_id() . '::INTEGER,' .
                '\'' . $record->getActivo() . '\'::BOOLEAN,' .
                '\'' . $record->get_Usuario_mod() . '\'::CHARACTER VARYING,' .
                $record->getVersionId() . '::INTEGER, 1::BIT) AS insupd) AS ans WHERE insupd IS NOT NULL;';

            return $sql;
        }

        protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL) {
            return 'SELECT currval(\'tb_postas_postas_id_seq\')';
        }
    }