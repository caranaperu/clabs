<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para la relacion entrenador-atleta.
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class entrenadoresAtletasController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'entrenadoresatletas', "validationId" => 'entrenadoresatletas_validation', "validationGroupId" => 'v_entrenadoresatletas', "validationRulesId" => 'getEntrenadoresAtletas'],
                "add" => ["langId" => 'entrenadoresatletas', "validationId" => 'entrenadoresatletas_validation', "validationGroupId" => 'v_entrenadoresatletas', "validationRulesId" => 'addEntrenadoresAtletas'],
                "del" => ["langId" => 'entrenadoresatletas', "validationId" => 'entrenadoresatletas_validation', "validationGroupId" => 'v_entrenadoresatletas', "validationRulesId" => 'delEntrenadoresAtletas'],
                "upd" => ["langId" => 'entrenadoresatletas', "validationId" => 'entrenadoresatletas_validation', "validationGroupId" => 'v_entrenadoresatletas', "validationRulesId" => 'updEntrenadoresAtletas']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['entrenadoresatletas_id', 'verifyExist'],
                "add" => ['entrenadores_codigo', 'atletas_codigo', 'entrenadoresatletas_desde', 'entrenadoresatletas_hasta',  'activo'],
                "del" => ['entrenadoresatletas_id', 'versionId'],
                "upd" => ['entrenadoresatletas_id','entrenadores_codigo', 'atletas_codigo', 'entrenadoresatletas_desde', 'entrenadoresatletas_hasta',  'versionId', 'activo']],
            "paramsFixableToNull" => ['entrenadoresatletas_', 'entrenadores_', 'atletas_'],
            "paramsFixableToValue" => ["entrenadoresatletas_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'entrenadoresatletas_id'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() {
        return new EntrenadoresAtletasBussinessService();
    }
}
