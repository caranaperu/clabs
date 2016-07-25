<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD para definir las genericas de las pruebas
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class appPruebasController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'apppruebas', "validationId" => 'apppruebas_validation', "validationGroupId" => 'v_apppruebas', "validationRulesId" => 'getAppPruebas'],
                "add" => ["langId" => 'apppruebas', "validationId" => 'apppruebas_validation', "validationGroupId" => 'v_apppruebas', "validationRulesId" => 'addAppPruebas'],
                "del" => ["langId" => 'apppruebas', "validationId" => 'apppruebas_validation', "validationGroupId" => 'v_apppruebas', "validationRulesId" => 'delAppPruebas'],
                "upd" => ["langId" => 'apppruebas', "validationId" => 'apppruebas_validation', "validationGroupId" => 'v_apppruebas', "validationRulesId" => 'updAppPruebas']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['apppruebas_codigo', 'verifyExist'],
                "add" => ['apppruebas_codigo', 'apppruebas_descripcion', 'pruebas_clasificacion_codigo', 'apppruebas_marca_menor', 'apppruebas_marca_mayor',
                    'apppruebas_multiple', 'apppruebas_verifica_viento', 'apppruebas_viento_individual', 'apppruebas_viento_limite_normal',
                    'apppruebas_viento_limite_multiple', 'apppruebas_nro_atletas', 'apppruebas_factor_manual', 'activo'],
                "del" => ['apppruebas_codigo', 'versionId'],
                "upd" => ['apppruebas_codigo', 'apppruebas_descripcion', 'pruebas_clasificacion_codigo', 'apppruebas_marca_menor', 'apppruebas_marca_mayor',
                    'apppruebas_multiple', 'apppruebas_verifica_viento', 'apppruebas_viento_individual', 'apppruebas_viento_limite_normal',
                    'apppruebas_viento_limite_multiple', 'apppruebas_nro_atletas', 'apppruebas_factor_manual', 'versionId', 'activo']],
            "paramsFixableToNull" => ['apppruebas_', 'pruebas_clasificacion_'],
            "paramsFixableToValue" => ["apppruebas_codigo" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'apppruebas_codigo'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() {
        return new AppPruebasBussinessService();
    }

}
