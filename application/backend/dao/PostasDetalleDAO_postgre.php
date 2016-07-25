<?php

    if (!defined('BASEPATH'))
        exit('No direct script access allowed');

    /**
     * Este DAO es especifico el mantenimiento de la definicion de los integrantes
     * de una posta.
     *
     * @author    Carlos Arana Reategui <aranape@gmail.com>
     * @version   0.1
     * @package   SoftAthletics
     * @copyright 2015-2016 Carlos Arana Reategui.
     * @license   GPL
     *
     */
    class PostasDetalleDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

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
            return 'DELETE FROM tb_postas_detalle WHERE postas_detalle_id = ' . $id . '  AND xmin =' . $versionId;
        }

        /**
         * @{inheritdoc}
         * @see \TSLBasicRecordDAO::getAddRecordQuery()
         */
        protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
            /* @var $record  PostasDetalleModel */


            $sql = 'select sp_postasdetalle_save_record(' .
                'NULL::INTEGER,' .
                $record->get_postas_id() . '::INTEGER,' .
                '\'' . $record->get_atletas_codigo() . '\'::character varying,' .
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

            if ($subOperation == 'fetchJoined') {
                $sql = 'SELECT postas_detalle_id,postas_id,pd.atletas_codigo,atletas_nombre_completo,pd.activo,pd.xmin AS "versionId" ' .
                    'FROM  tb_postas_detalle pd ' .
                    'inner join tb_atletas atl on atl.atletas_codigo = pd.atletas_codigo';
            } else {
                $sql = 'SELECT postas_detalle_id,postas_id,atletas_codigo,activo,xmin AS "versionId" FROM  tb_postas_detalle pd';
            }


            if ($this->activeSearchOnly == TRUE) {
                // Solo activos
                $sql .= ' where pd.activo=TRUE ';
            }

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

            $sql = str_replace('like', 'ilike', $sql);

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
            return 'SELECT postas_detalle_id,postas_id,atletas_codigo,xmin AS "versionId" FROM tb_postas_detalle WHERE postas_detalle_id = ' . $code;
        }

        /**
         *
         * @{inheritdoc}
         * @see \TSLBasicRecordDAO::getUpdateRecordQuery()
         */
        protected function getUpdateRecordQuery(\TSLDataModel &$record) {

            /* @var $record  PostasDetalleModel */
            $sql = 'SELECT * FROM (SELECT  sp_postasdetalle_save_record(' .
                $record->get_postas_detalle_id(). '::INTEGER,' .
                $record->get_postas_id() . '::INTEGER,' .
                '\'' . $record->get_atletas_codigo() . '\'::CHARACTER VARYING,' .
                '\'' . $record->getActivo() . '\'::BOOLEAN,' .
                '\'' . $record->get_Usuario_mod() . '\'::CHARACTER VARYING,' .
                $record->getVersionId() . '::INTEGER, 1::BIT) AS insupd) AS ans WHERE insupd IS NOT NULL;';

            return $sql;
        }

        protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL) {
            return 'SELECT currval(\'tb_postas_detalle_postas_detalle_id_seq\')';
        }

    }