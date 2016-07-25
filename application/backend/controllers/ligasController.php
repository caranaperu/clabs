<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD para definir las ligas.
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class ligasController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'ligas', "validationId" => 'ligas_validation', "validationGroupId" => 'v_ligas', "validationRulesId" => 'getLigas'],
                "add" => ["langId" => 'ligas', "validationId" => 'ligas_validation', "validationGroupId" => 'v_ligas', "validationRulesId" => 'addLigas'],
                "del" => ["langId" => 'ligas', "validationId" => 'ligas_validation', "validationGroupId" => 'v_ligas', "validationRulesId" => 'delLigas'],
                "upd" => ["langId" => 'ligas', "validationId" => 'ligas_validation', "validationGroupId" => 'v_ligas', "validationRulesId" => 'updLigas']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['ligas_codigo', 'verifyExist'],
                "add" => ['ligas_codigo', 'ligas_descripcion', 'ligas_persona_contacto', 'ligas_direccion', 'ligas_email',
                    'ligas_telefono_oficina', 'ligas_web_url', 'activo'],
                "del" => ['ligas_codigo', 'versionId'],
                "upd" => ['ligas_codigo', 'ligas_descripcion', 'ligas_persona_contacto', 'ligas_direccion', 'ligas_email',
                    'ligas_telefono_oficina', 'ligas_web_url', 'versionId', 'activo']],
            "paramsFixableToNull" => ['ligas_'],
            "paramsFixableToValue" => ["ligas_codigo" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'ligas_codigo'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() {
        return new LigasBussinessService();
    }

}
