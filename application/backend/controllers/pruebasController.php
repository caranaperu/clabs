<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de las pruebas atleticas , digase 100 metros con vallas,
 * impulsion de bala , etc
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class pruebasController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'pruebas', "validationId" => 'pruebas_validation', "validationGroupId" => 'v_pruebas', "validationRulesId" => 'getPruebas'],
                "add" => ["langId" => 'pruebas', "validationId" => 'pruebas_validation', "validationGroupId" => 'v_pruebas', "validationRulesId" => 'addPruebas'],
                "del" => ["langId" => 'pruebas', "validationId" => 'pruebas_validation', "validationGroupId" => 'v_pruebas', "validationRulesId" => 'delPruebas'],
                "upd" => ["langId" => 'pruebas', "validationId" => 'pruebas_validation', "validationGroupId" => 'v_pruebas', "validationRulesId" => 'updPruebas']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['pruebas_codigo', 'verifyExist'],
                "add" => ['pruebas_codigo', 'pruebas_descripcion', 'pruebas_generica_codigo', 'pruebas_clasificacion_codigo',
                    'categorias_codigo', 'pruebas_sexo', 'pruebas_record_hasta', 'pruebas_anotaciones', 'pruebas_multiple', 'activo'],
                "del" => ['pruebas_codigo', 'versionId'],
                "upd" => ['pruebas_codigo', 'pruebas_descripcion', 'pruebas_generica_codigo', 'pruebas_clasificacion_codigo',
                    'categorias_codigo', 'pruebas_sexo', 'pruebas_record_hasta', 'pruebas_anotaciones', 'pruebas_multiple', 'versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['pruebas_', 'pruebas_clasificacion_', 'categorias_'],
            "paramsFixableToValue" => ["pruebas_codigo" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'pruebas_codigo'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() {
        return new PruebasBussinessService();
    }

}
