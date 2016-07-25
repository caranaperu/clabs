<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de la relacion club-atleta.
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class clubesAtletasController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'clubesatletas', "validationId" => 'clubesatletas_validation', "validationGroupId" => 'v_clubesatletas', "validationRulesId" => 'getClubesAtletas'],
                "add" => ["langId" => 'clubesatletas', "validationId" => 'clubesatletas_validation', "validationGroupId" => 'v_clubesatletas', "validationRulesId" => 'addClubesAtletas'],
                "del" => ["langId" => 'clubesatletas', "validationId" => 'clubesatletas_validation', "validationGroupId" => 'v_clubesatletas', "validationRulesId" => 'delClubesAtletas'],
                "upd" => ["langId" => 'clubesatletas', "validationId" => 'clubesatletas_validation', "validationGroupId" => 'v_clubesatletas', "validationRulesId" => 'updClubesAtletas']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['clubesatletas_id', 'verifyExist'],
                "add" => ['clubes_codigo', 'atletas_codigo', 'clubesatletas_desde', 'clubesatletas_hasta', 'activo'],
                "del" => ['clubesatletas_id', 'versionId'],
                "upd" => ['clubesatletas_id', 'clubes_codigo', 'atletas_codigo', 'clubesatletas_desde', 'clubesatletas_hasta', 'versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['clubesatletas_', 'clubes_', 'atletas_'],
            "paramsFixableToValue" => ["clubesatletas_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'clubesatletas_id'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() {
        return new ClubesAtletasBussinessService();
    }

}
