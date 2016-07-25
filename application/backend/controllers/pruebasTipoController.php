<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de los tipos de pruebas atleticas.
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class pruebasTipoController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'pruebastipo', "validationId" => 'pruebastipo_validation', "validationGroupId" => 'v_pruebastipo', "validationRulesId" => 'getPruebasTipo'],
                "add" => ["langId" => 'pruebastipo', "validationId" => 'pruebastipo_validation', "validationGroupId" => 'v_pruebastipo', "validationRulesId" => 'addPruebasTipo'],
                "del" => ["langId" => 'pruebastipo', "validationId" => 'pruebastipo_validation', "validationGroupId" => 'v_pruebastipo', "validationRulesId" => 'delPruebasTipo'],
                "upd" => ["langId" => 'pruebastipo', "validationId" => 'pruebastipo_validation', "validationGroupId" => 'v_pruebastipo', "validationRulesId" => 'updPruebasTipo']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['pruebas_tipo_codigo', 'verifyExist'],
                "add" => ['pruebas_tipo_codigo', 'pruebas_tipo_descripcion', 'activo'],
                "del" => ['pruebas_tipo_codigo', 'versionId'],
                "upd" => ['pruebas_tipo_codigo', 'pruebas_tipo_descripcion', 'versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['pruebas_tipo_'],
            "paramsFixableToValue" => ["pruebas_tipo_codigo" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'pruebas_tipo_codigo'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() {
        return new PruebasTipoBussinessService();
    }

}
