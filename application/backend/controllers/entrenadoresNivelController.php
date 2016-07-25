<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD para definir los niveles de entrenador
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class entrenadoresNivelController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'entrenadores_nivel', "validationId" => 'entrenadores_nivel_validation', "validationGroupId" => 'v_entrenadores_nivel', "validationRulesId" => 'getEntrenadoresNivel'],
                "add" => ["langId" => 'entrenadores_nivel', "validationId" => 'entrenadores_nivel_validation', "validationGroupId" => 'v_entrenadores_nivel', "validationRulesId" => 'addEntrenadoresNivel'],
                "del" => ["langId" => 'entrenadores_nivel', "validationId" => 'entrenadores_nivel_validation', "validationGroupId" => 'v_entrenadores_nivel', "validationRulesId" => 'delEntrenadoresNivel'],
                "upd" => ["langId" => 'entrenadores_nivel', "validationId" => 'entrenadores_nivel_validation', "validationGroupId" => 'v_entrenadores_nivel', "validationRulesId" => 'updEntrenadoresNivel']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['entrenadores_nivel_codigo', 'verifyExist'],
                "add" => ['entrenadores_nivel_codigo', 'entrenadores_nivel_descripcion', 'activo'],
                "del" => ['entrenadores_nivel_codigo', 'versionId'],
                "upd" => ['entrenadores_nivel_codigo', 'entrenadores_nivel_descripcion', 'versionId', 'activo']],
            "paramsFixableToNull" => ['entrenadores_nivel_'],
            "paramsFixableToValue" => ["entrenadores_nivel_codigo" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'entrenadores_nivel_codigo'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() {
        return new EntrenadoresNivelBussinessService();
    }

}
