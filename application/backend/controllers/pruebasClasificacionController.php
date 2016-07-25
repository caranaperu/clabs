<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de la clasficacion de pruebas , digase
 * FONDO, VELOCIDAD, COMBINADA, etc
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class pruebasClasificacionController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'pruebasclasificacion', "validationId" => 'pruebasclasificacion_validation', "validationGroupId" => 'v_pruebasclasificacion', "validationRulesId" => 'getPruebasClasificacion'],
                "add" => ["langId" => 'pruebasclasificacion', "validationId" => 'pruebasclasificacion_validation', "validationGroupId" => 'v_pruebasclasificacion', "validationRulesId" => 'addPruebasClasificacion'],
                "del" => ["langId" => 'pruebasclasificacion', "validationId" => 'pruebasclasificacion_validation', "validationGroupId" => 'v_pruebasclasificacion', "validationRulesId" => 'delPruebasClasificacion'],
                "upd" => ["langId" => 'pruebasclasificacion', "validationId" => 'pruebasclasificacion_validation', "validationGroupId" => 'v_pruebasclasificacion', "validationRulesId" => 'updPruebasClasificacion']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['pruebas_clasificacion_codigo', 'verifyExist'],
                "add" => ['pruebas_clasificacion_codigo', 'pruebas_clasificacion_descripcion', 'pruebas_tipo_codigo', 'unidad_medida_codigo', 'activo'],
                "del" => ['pruebas_clasificacion_codigo', 'versionId'],
                "upd" => ['pruebas_clasificacion_codigo', 'pruebas_clasificacion_descripcion', 'pruebas_tipo_codigo', 'unidad_medida_codigo', 'versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['pruebas_clasificacion_', 'pruebas_tipo_', 'unidad_medida_'],
            "paramsFixableToValue" => ["pruebas_clasificacion_codigo" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'pruebas_clasificacion_codigo'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() {
        return new PruebasClasificacionBussinessService();
    }

}
