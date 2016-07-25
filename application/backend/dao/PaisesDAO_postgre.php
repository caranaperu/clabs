<?php

    if (!defined('BASEPATH'))
        exit('No direct script access allowed');

    /**
     * Este DAO es especifico el mantenimiento de los paises al sistema.
     *
     * @author  $Author: aranape $
     * @since   06-FEB-2013
     * @version $Id: PaisesDAO_postgre.php 279 2014-06-30 02:14:51Z aranape $
     * @history ''
     *
     * $Date: 2014-06-29 21:14:51 -0500 (dom, 29 jun 2014) $
     * $Rev: 279 $
     */
    class PaisesDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

        /**
         * Constructor se puede indicar si las busquedas solo seran en registros activos.
         *
         * @param boolean $activeSearchOnly
         */
        public function __construct($activeSearchOnly = TRUE) {
            parent::__construct($activeSearchOnly);
        }

        /**
         * @see \TSLBasicRecordDAO::getDeleteRecordQuery()
         */
        protected function getDeleteRecordQuery($id, $versionId) {
            return 'DELETE FROM tb_paises WHERE paises_codigo = \'' . $id . '\'  AND xmin =' . $versionId;
        }

        /**
         * @see \TSLBasicRecordDAO::getAddRecordQuery()
         */
        protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
            /* @var $record  PaisesModel */
            $sql = 'select sp_paises_save_record(' .
                '\'' . $record->get_paises_codigo() . '\'::character varying,' .
                '\'' . $record->get_paises_descripcion() . '\'::character varying,' .
                '\'' . $record->get_paises_entidad() . '\'::boolean,' .
                '\'' . $record->get_regiones_codigo() . '\'::character varying,' .
                '\'' . $record->get_paises_use_apm() . '\'::boolean,' .
                '\'' . $record->get_paises_use_docid() . '\'::boolean,' .
                '\'' . $record->getActivo() . '\'::boolean,' .
                '\'' . $record->getUsuario() . '\'::character varying,' .
                'null::integer, 0::BIT);';
echo $sql;
            return $sql;
        }

        /**
         * @see \TSLBasicRecordDAO::getFetchQuery()
         */
        protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {
            // Si la busqueda permite buscar solo activos e inactivos
            $sql = 'SELECT paises_codigo,paises_descripcion,paises_entidad,paises_use_apm,paises_use_docid,regiones_codigo,activo,xmin AS "versionId" FROM  tb_paises ';

            if ($this->activeSearchOnly == TRUE) {
                // Solo activos
                $sql .= ' where "activo"=TRUE ';
            }

            $where = $constraints->getFilterFieldsAsString();
            if (strlen($where) > 0) {
                $sql .= ' and ' . $where;
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
            return 'select paises_codigo,paises_descripcion,paises_entidad,paises_use_apm,paises_use_docid,regiones_codigo,activo,' .
            'xmin as "versionId" from tb_paises where "paises_codigo" =  \'' . $code . '\'';
        }

        /**
         * Aqui el id es el codigo
         * @see \TSLBasicRecordDAO::getUpdateRecordQuery()
         */
        protected function getUpdateRecordQuery(\TSLDataModel &$record) {
            /* @var $record  PaisesModel */
            $sql = 'SELECT * FROM (SELECT sp_paises_save_record(' .
                '\'' . $record->get_paises_codigo() . '\'::CHARACTER VARYING,' .
                '\'' . $record->get_paises_descripcion() . '\'::CHARACTER VARYING,' .
                '\'' . $record->get_paises_entidad() . '\'::BOOLEAN,' .
                '\'' . $record->get_regiones_codigo() . '\'::CHARACTER VARYING,' .
                '\'' . $record->get_paises_use_apm() . '\'::BOOLEAN,' .
                '\'' . $record->get_paises_use_docid() . '\'::BOOLEAN,' .
                '\'' . $record->getActivo() . '\'::BOOLEAN,' .
                '\'' . $record->get_Usuario_mod() . '\'::CHARACTER VARYING,' .
                $record->getVersionId() . '::INTEGER, 1::BIT)  AS insupd) AS ans WHERE insupd IS NOT NULL;';

            return $sql;
        }

    }

?>