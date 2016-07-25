<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de los insumos
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package CLABS
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class insumoController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'insumo', "validationId" => 'insumo_validation', "validationGroupId" => 'v_insumo', "validationRulesId" => 'getInsumo'],
                "add" => ["langId" => 'insumo', "validationId" => 'insumo_validation', "validationGroupId" => 'v_insumo', "validationRulesId" => 'addInsumo'],
                "del" => ["langId" => 'insumo', "validationId" => 'insumo_validation', "validationGroupId" => 'v_insumo', "validationRulesId" => 'delInsumo'],
                "upd" => ["langId" => 'insumo', "validationId" => 'insumo_validation', "validationGroupId" => 'v_insumo', "validationRulesId" => 'updInsumo']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['insumo_codigo', 'verifyExist'],
                "add" => ['insumo_codigo', 'insumo_descripcion','tinsumo_codigo','tcostos_codigo','unidad_medida_codigo','insumo_merma','activo'],
                "del" => ['insumo_codigo', 'versionId'],
                "upd" => ['insumo_codigo', 'insumo_descripcion','tinsumo_codigo','tcostos_codigo','unidad_medida_codigo','insumo_merma', 'versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['insumo_','tinsumo_','unidad_medida_','tcostos_'],
            "paramsFixableToValue" => ["insumo_codigo" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
           "paramToMapId" => 'insumo_codigo'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() {
        return new InsumoBussinessService();
    }
}
