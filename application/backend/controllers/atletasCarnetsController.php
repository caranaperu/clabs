<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador CRUD para el registro de carnets pagados para el registro
 * de los atletas.
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class atletasCarnetsController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'atletascarnets', "validationId" => 'atletascarnets_validation', "validationGroupId" => 'v_atletascarnets', "validationRulesId" => 'getAtletasCarnets'],
                "add" => ["langId" => 'atletascarnets', "validationId" => 'atletascarnets_validation', "validationGroupId" => 'v_atletascarnets', "validationRulesId" => 'addAtletasCarnets'],
                "del" => ["langId" => 'atletascarnets', "validationId" => 'atletascarnets_validation', "validationGroupId" => 'v_atletascarnets', "validationRulesId" => 'delAtletasCarnets'],
                "upd" => ["langId" => 'atletascarnets', "validationId" => 'atletascarnets_validation', "validationGroupId" => 'v_atletascarnets', "validationRulesId" => 'updAtletasCarnets']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['getAtletasCarnets', 'verifyExist'],
                "add" => ['atletas_carnets_numero', 'atletas_codigo', 'atletas_carnets_agno', 'atletas_carnets_fecha', 'activo'],
                "del" => ['atletas_carnets_id', 'versionId'],
                "upd" => ['atletas_carnets_id','atletas_carnets_numero', 'atletas_codigo', 'atletas_carnets_agno', 'atletas_carnets_fecha', 'versionId', 'activo']],
            "paramsFixableToNull" => ['atletas_carnets_', 'atletas_'],
            "paramsFixableToValue" => ["atletas_carnets_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'atletas_carnets_id'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() {
        return new AtletasCarnetsBussinessService();
    }

}
