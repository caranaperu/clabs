<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de las entrenadores.
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class entrenadoresController extends app\common\controller\TSLAppDefaultCRUDController {

    public function __construct() {
        parent::__construct();
    }

    /**
     * {@inheritDoc}
     */
    protected function setupData() {

        $this->setupOpts = [
            "validateOptions" => [
                "fetch" => [],
                "read" => ["langId" => 'entrenadores', "validationId" => 'entrenadores_validation', "validationGroupId" => 'v_entrenadores', "validationRulesId" => 'getEntrenadores'],
                "add" => ["langId" => 'entrenadores', "validationId" => 'entrenadores_validation', "validationGroupId" => 'v_entrenadores', "validationRulesId" => 'addEntrenadores'],
                "del" => ["langId" => 'entrenadores', "validationId" => 'entrenadores_validation', "validationGroupId" => 'v_entrenadores', "validationRulesId" => 'delEntrenadores'],
                "upd" => ["langId" => 'entrenadores', "validationId" => 'entrenadores_validation', "validationGroupId" => 'v_entrenadores', "validationRulesId" => 'updEntrenadores']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['entrenadores_codigo', 'verifyExist'],
                "add" => ['entrenadores_codigo', 'entrenadores_ap_paterno', 'entrenadores_ap_materno', 'entrenadores_nombres', 'entrenadores_nivel_codigo', 'activo'],
                "del" => ['entrenadores_codigo', 'versionId'],
                "upd" => ['entrenadores_codigo', 'entrenadores_ap_paterno', 'entrenadores_ap_materno', 'entrenadores_nombres', 'entrenadores_nivel_codigo', 'versionId', 'activo']],
            "paramsFixableToNull" => ['entrenadores_', 'entrenadores_nivel_'],
            "paramsFixableToValue" => ["entrenadores_codigo" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'entrenadores_codigo'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() {
        return new EntrenadoresBussinessService();
    }

}
