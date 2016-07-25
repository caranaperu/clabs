<?php

    if (!defined('BASEPATH'))
        exit('No direct script access allowed');

    /**
     * Controlador para las operaciones CRUD de los paises de competicion.
     *
     *
     * @author    Carlos Arana Reategui <aranape@gmail.com>
     * @version   0.1
     * @package   SoftAthletics
     * @copyright 2015-2016 Carlos Arana Reategui.
     * @license   GPL
     *
     */
    class paisesController extends app\common\controller\TSLAppDefaultCRUDController {

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
                    "read"  => ["langId" => 'paises', "validationId" => 'paises_validation', "validationGroupId" => 'v_paises', "validationRulesId" => 'getPaises'],
                    "add"   => ["langId" => 'paises', "validationId" => 'paises_validation', "validationGroupId" => 'v_paises', "validationRulesId" => 'addPaises'],
                    "del"   => ["langId" => 'paises', "validationId" => 'paises_validation', "validationGroupId" => 'v_paises', "validationRulesId" => 'delPaises'],
                    "upd"   => ["langId" => 'paises', "validationId" => 'paises_validation', "validationGroupId" => 'v_paises', "validationRulesId" => 'updPaises']
                ],
                "paramsList"           => [
                    "fetch" => [],
                    "read"  => ['paises_codigo', 'verifyExist'],
                    "add"   => ['paises_codigo', 'paises_descripcion', 'paises_entidad', 'regiones_codigo', 'paises_use_apm', 'paises_use_docid', 'activo'],
                    "del"   => ['paises_codigo', 'versionId'],
                    "upd"   => ['paises_codigo', 'paises_descripcion', 'paises_entidad', 'regiones_codigo', 'paises_use_apm', 'paises_use_docid', 'versionId', 'activo'],
                ],
                "paramsFixableToNull"  => ['paises_', 'regiones_'],
                "paramsFixableToValue" => ["paises_codigo" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => TRUE]],
                "paramToMapId"         => 'paises_codigo'
            ];
        }

        /**
         * {@inheritDoc}
         */
        protected function getBussinessService() {
            return new PaisesBussinessService();
        }
    }
