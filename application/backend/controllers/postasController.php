<?php

    if (!defined('BASEPATH'))
        exit('No direct script access allowed');

    /**
     * Controlador para las operaciones CRUD para definir las postas para cada
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
    class postasController extends app\common\controller\TSLAppDefaultCRUDController {

        public function __construct() {
            parent::__construct();
        }

        /**
         * {@inheritDoc}
         */
        protected function setupData() {

            $this->setupOpts = [
                "validateOptions"      => [
                    "fetch" => [],
                    "read"  => ["langId" => 'postas', "validationId" => 'postas_validation', "validationGroupId" => 'v_postas', "validationRulesId" => 'getPostas'],
                    "add"   => ["langId" => 'postas', "validationId" => 'postas_validation', "validationGroupId" => 'v_postas', "validationRulesId" => 'addPostas'],
                    "del"   => ["langId" => 'postas', "validationId" => 'postas_validation', "validationGroupId" => 'v_postas', "validationRulesId" => 'delPostas'],
                    "upd"   => ["langId" => 'postas', "validationId" => 'postas_validation', "validationGroupId" => 'v_postas', "validationRulesId" => 'updPostas']
                ],
                "paramsList"           => [
                    "fetch" => [],
                    "read"  => ['postas_id', 'verifyExist'],
                    "add"   => ['competencias_pruebas_id', 'postas_descripcion', 'activo'],
                    "del"   => ['postas_id', 'versionId'],
                    "upd"   => ['postas_id', 'competencias_pruebas_id', 'postas_descripcion', 'versionId', 'activo']],
                "paramsFixableToNull"  => ['postas_', 'competencias_pruebas_'],
                "paramsFixableToValue" => ["postas_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => TRUE]],
                "paramToMapId"         => 'postas_id'
            ];
        }

        /**
         * {@inheritDoc}
         */
        protected function getBussinessService() {
            return new PostasBussinessService();
        }
    }
