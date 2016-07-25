<?php

    if (!defined('BASEPATH'))
        exit('No direct script access allowed');

    /**
     * Controlador para las operaciones CRUD para definir los items o detalle postas para cada
     * competencia-prueba-posta.
     *
     *
     * @author    Carlos Arana Reategui <aranape@gmail.com>
     * @version   0.1
     * @package   SoftAthletics
     * @copyright 2015-2016 Carlos Arana Reategui.
     * @license   GPL
     *
     */
    class postasDetalleController extends app\common\controller\TSLAppDefaultCRUDController {

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
                    "read"  => ["langId" => 'postas_detalle', "validationId" => 'postas_detalle_validation', "validationGroupId" => 'v_postas_detalle', "validationRulesId" => 'getPostasDetalle'],
                    "add"   => ["langId" => 'postas_detalle', "validationId" => 'postas_detalle_validation', "validationGroupId" => 'v_postas_detalle', "validationRulesId" => 'addPostasDetalle'],
                    "del"   => ["langId" => 'postas_detalle', "validationId" => 'postas_detalle_validation', "validationGroupId" => 'v_postas_detalle', "validationRulesId" => 'delPostasDetalle'],
                    "upd"   => ["langId" => 'postas_detalle', "validationId" => 'postas_detalle_validation', "validationGroupId" => 'v_postas_detalle', "validationRulesId" => 'updPostasDetalle']
                ],
                "paramsList"           => [
                    "fetch" => [],
                    "read"  => ['postas_detalle_id', 'verifyExist'],
                    "add"   => ['postas_id', 'atletas_codigo', 'activo'],
                    "del"   => ['postas_detalle_id', 'versionId'],
                    "upd"   => ['postas_detalle_id', 'postas_id', 'atletas_codigo', 'versionId', 'activo']],
                "paramsFixableToNull"  => ['postas_', 'postas_detalle_', 'atletas_'],
                "paramsFixableToValue" => ["postas_detalle_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => TRUE]],
                "paramToMapId"         => 'postas_detalle_id'
            ];
        }

        /**
         * {@inheritDoc}
         */
        protected function getBussinessService() {
            return new PostasDetalleBussinessService();
        }
    }
