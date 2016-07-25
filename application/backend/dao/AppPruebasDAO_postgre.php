<?php

    if (!defined('BASEPATH'))
        exit('No direct script access allowed');

    /**
     * Este DAO es especifico para el manejo de los datos genericos de pruebas.
     *
     * @author  $Author: aranape $
     * @since   06-FEB-2013
     * @version $Id: AppPruebasDAO_postgre.php 319 2014-07-30 04:43:48Z aranape $
     * @history ''
     *
     * $Date: 2014-07-29 23:43:48 -0500 (mar, 29 jul 2014) $
     * $Rev: 319 $
     */
    class AppPruebasDAO_postgre extends \app\common\dao\TSLAppBasicRecordDAO_postgre {

        /**
         * Constructor se puede indicar si las busquedas solo seran en registros activos.
         *
         * @param boolean $activeSearchOnly
         */
        public function __construct($activeSearchOnly = TRUE) {
            parent::__construct($activeSearchOnly);
        }

        /**
         * {@inheritdoc}
         * @see TSLBasicRecordDAO::getDeleteRecordQuery()
         */
        protected function getDeleteRecordQuery($id, $versionId) {
            return 'DELETE FROM tb_app_pruebas_values WHERE apppruebas_codigo = \'' . $id . '\'  AND xmin =' . $versionId;
        }

        /**
         * @see TSLBasicRecordDAO::getAddRecordQuery()
         */
        protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL) {
            /* @var $record  AppPruebasModel */

            $sql = 'select sp_apppruebas_save_record(' .
                '\'' . $record->get_apppruebas_codigo() . '\'::character varying,' .
                '\'' . $record->get_apppruebas_descripcion() . '\'::character varying,' .
                '\'' . $record->get_pruebas_clasificacion_codigo() . '\'::character varying,' .
                '\'' . $record->get_apppruebas_marca_menor() . '\'::character varying,' .
                '\'' . $record->get_apppruebas_marca_mayor() . '\'::character varying,' .
                '\'' . $record->get_apppruebas_multiple() . '\'::boolean,' .
                '\'' . $record->get_apppruebas_verifica_viento() . '\'::boolean,' .
                '\'' . $record->get_apppruebas_viento_individual() . '\'::boolean,' .
                ($record->get_apppruebas_verifica_viento() !== 'false' ? (!$record->get_apppruebas_viento_limite_normal() ? 'null' : $record->get_apppruebas_viento_limite_normal()) : 'null') . '::numeric,' .
                ($record->get_apppruebas_verifica_viento() !== 'false' ? (!$record->get_apppruebas_viento_limite_multiple() ? 'null' : $record->get_apppruebas_viento_limite_multiple()) : 'null') . '::numeric,' .
                $record->get_apppruebas_nro_atletas() . '::integer,' .
                $record->get_apppruebas_factor_manual() . '::numeric,' .
                '\'' . $record->getActivo() . '\'::boolean,' .
                '\'' . $record->getUsuario() . '\'::character varying,' .
                'null::integer, 0::BIT)';

            return $sql;
        }

        /**
         * @see TSLBasicRecordDAO::getFetchQuery()
         */
        protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {
            // Si la busqueda permite buscar solo activos e inactivos
            if ($subOperation == 'fetchJoined') {
                $sql = 'select apppruebas_codigo,apppruebas_descripcion,pv.pruebas_clasificacion_codigo,pruebas_clasificacion_descripcion,apppruebas_marca_menor,apppruebas_marca_mayor,apppruebas_multiple,'
                    . 'apppruebas_verifica_viento,apppruebas_viento_individual,apppruebas_viento_limite_normal,apppruebas_viento_limite_multiple,'
                    . 'apppruebas_nro_atletas,apppruebas_factor_manual,apppruebas_protected,pv.activo,pv.xmin as "versionId" from  tb_app_pruebas_values pv '
                    . 'inner join tb_pruebas_clasificacion pc on pc.pruebas_clasificacion_codigo=pv.pruebas_clasificacion_codigo';
            } else if ($subOperation == 'fetchDescriptions') {
                $sql = 'SELECT apppruebas_codigo,apppruebas_descripcion FROM  tb_app_pruebas_values pv ';

            } else {
                $sql = 'select apppruebas_codigo,apppruebas_descripcion,pruebas_clasificacion_codigo,apppruebas_marca_menor,apppruebas_marca_mayor,apppruebas_multiple,apppruebas_viento_individual,'
                    . 'apppruebas_verifica_viento,apppruebas_viento_limite_normal,apppruebas_viento_limite_multiple,apppruebas_nro_atletas,apppruebas_factor_manual,apppruebas_protected,activo,xmin as "versionId" from  tb_app_pruebas_values pv ';
            }

            if ($this->activeSearchOnly == TRUE) {
                // Solo activos
                $sql .= ' where pv.activo=TRUE ';
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

            // No es necesario paginacion aqui

            $sql = str_replace('like', 'ilike', $sql);

            return $sql;
        }

        /**
         * @see TSLBasicRecordDAO::getRecordQuery()
         */
        protected function getRecordQuery($id) {
            // en este caso el codigo es la llave primaria
            return $this->getRecordQueryByCode($id);
        }

        /**
         * @see TSLBasicRecordDAO::getRecordQueryByCode()
         */
        protected function getRecordQueryByCode($code) {
            return 'select apppruebas_codigo,apppruebas_descripcion,pruebas_clasificacion_codigo,apppruebas_marca_menor,apppruebas_marca_mayor,'
            . 'apppruebas_multiple,apppruebas_verifica_viento,apppruebas_viento_individual,apppruebas_viento_limite_normal,apppruebas_viento_limite_multiple,'
            . 'apppruebas_nro_atletas,apppruebas_factor_manual,activo,' .
            'xmin as "versionId" from tb_app_pruebas_values where apppruebas_codigo =  \'' . $code . '\'';
        }

        /**
         * Aqui el id es el codigo
         * @see TSLBasicRecordDAO::getUpdateRecordQuery()
         */
        protected function getUpdateRecordQuery(\TSLDataModel &$record) {
            /* @var $record  AppPruebasModel */

            $sql = 'SELECT * FROM (SELECT sp_apppruebas_save_record(' .
                '\'' . $record->get_apppruebas_codigo() . '\'::CHARACTER VARYING,' .
                '\'' . $record->get_apppruebas_descripcion() . '\'::CHARACTER VARYING,' .
                '\'' . $record->get_pruebas_clasificacion_codigo() . '\'::CHARACTER VARYING,' .
                '\'' . $record->get_apppruebas_marca_menor() . '\'::CHARACTER VARYING,' .
                '\'' . $record->get_apppruebas_marca_mayor() . '\'::CHARACTER VARYING,' .
                '\'' . $record->get_apppruebas_multiple() . '\'::BOOLEAN,' .
                '\'' . $record->get_apppruebas_verifica_viento() . '\'::BOOLEAN,' .
                '\'' . $record->get_apppruebas_viento_individual() . '\'::BOOLEAN,' .
                ($record->get_apppruebas_verifica_viento() !== 'false' ? (!$record->get_apppruebas_viento_limite_normal() ? 'null' : $record->get_apppruebas_viento_limite_normal()) : 'null') . '::NUMERIC,' .
                ($record->get_apppruebas_verifica_viento() !== 'false' ? (!$record->get_apppruebas_viento_limite_multiple() ? 'null' : $record->get_apppruebas_viento_limite_multiple()) : 'null') . '::NUMERIC,' .
                $record->get_apppruebas_nro_atletas() . '::INTEGER,' .
                $record->get_apppruebas_factor_manual() . '::NUMERIC,' .
                '\'' . $record->getActivo() . '\'::BOOLEAN,' .
                '\'' . $record->get_Usuario_mod() . '\'::CHARACTER VARYING,' .
                $record->getVersionId() . '::INTEGER, 1::BIT) AS insupd) AS ans WHERE insupd IS NOT NULL;';

            return $sql;
        }

    }

?>