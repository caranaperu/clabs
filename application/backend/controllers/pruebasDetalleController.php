<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de los detalles de una prueba , sirve para
 * especificar que pruebas componen una prueba combinada.
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class pruebasDetalleController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'pruebasdetalle', "validationId" => 'pruebasdetalle_validation', "validationGroupId" => 'v_pruebasdetalle', "validationRulesId" => 'getPruebasDetalle'],
                "add" => ["langId" => 'pruebasdetalle', "validationId" => 'pruebasdetalle_validation', "validationGroupId" => 'v_pruebasdetalle', "validationRulesId" => 'addPruebasDetalle'],
                "del" => ["langId" => 'pruebasdetalle', "validationId" => 'pruebasdetalle_validation', "validationGroupId" => 'v_pruebasdetalle', "validationRulesId" => 'delPruebasDetalle'],
                "upd" => ["langId" => 'pruebasdetalle', "validationId" => 'pruebasdetalle_validation', "validationGroupId" => 'v_pruebasdetalle', "validationRulesId" => 'updPruebasDetalle']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['pruebasdetalle_id', 'verifyExist'],
                "add" => ['pruebas_codigo', 'pruebas_detalle_prueba_codigo', 'pruebas_detalle_orden', 'activo'],
                "del" => ['pruebas_detalle_id', 'versionId'],
                "upd" => ['pruebas_detalle_id', 'pruebas_codigo', 'pruebas_detalle_prueba_codigo', 'pruebas_detalle_orden', 'versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['pruebas_detalle_', 'pruebas_'],
            "paramsFixableToValue" => ["pruebas_detalle_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'pruebas_detalle_id'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() {
        return new PruebasDetalleBussinessService();
    }

}
