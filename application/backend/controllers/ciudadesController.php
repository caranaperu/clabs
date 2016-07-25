<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de las ciudades donde se realizan las competencias.
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class ciudadesController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'ciudades', "validationId" => 'ciudades_validation', "validationGroupId" => 'v_ciudades', "validationRulesId" => 'getCiudades'],
                "add" => ["langId" => 'ciudades', "validationId" => 'ciudades_validation', "validationGroupId" => 'v_ciudades', "validationRulesId" => 'addCiudades'],
                "del" => ["langId" => 'ciudades', "validationId" => 'ciudades_validation', "validationGroupId" => 'v_ciudades', "validationRulesId" => 'delCiudades'],
                "upd" => ["langId" => 'ciudades', "validationId" => 'ciudades_validation', "validationGroupId" => 'v_ciudades', "validationRulesId" => 'updCiudades']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['ciudades_codigo', 'verifyExist'],
                "add" => ['ciudades_codigo', 'ciudades_descripcion', 'paises_codigo', 'ciudades_altura', 'activo'],
                "del" => ['ciudades_codigo', 'versionId'],
                "upd" => ['ciudades_codigo', 'ciudades_descripcion', 'paises_codigo', 'ciudades_altura', 'versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['ciudades_', 'paises_'],
            "paramsFixableToValue" => ["ciudades_codigo" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'ciudades_codigo'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() {
        return new CiudadesBussinessService();
    }

}
