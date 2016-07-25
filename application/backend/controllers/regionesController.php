<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de las regiones atleticas.
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class regionesController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'regiones', "validationId" => 'regiones_validation', "validationGroupId" => 'v_regiones', "validationRulesId" => 'getRegiones'],
                "add" => ["langId" => 'regiones', "validationId" => 'regiones_validation', "validationGroupId" => 'v_regiones', "validationRulesId" => 'addRegiones'],
                "del" => ["langId" => 'regiones', "validationId" => 'regiones_validation', "validationGroupId" => 'v_regiones', "validationRulesId" => 'delRegiones'],
                "upd" => ["langId" => 'regiones', "validationId" => 'regiones_validation', "validationGroupId" => 'v_regiones', "validationRulesId" => 'updRegiones']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['regiones_codigo', 'verifyExist'],
                "add" => ['regiones_codigo', 'regiones_descripcion','activo'],
                "del" => ['regiones_codigo', 'versionId'],
                "upd" => ['regiones_codigo', 'regiones_descripcion', 'versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['regiones_'],
            "paramsFixableToValue" => ["regiones_codigo" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
           "paramToMapId" => 'regiones_codigo'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() {
        return new RegionesBussinessService();
    }
}
