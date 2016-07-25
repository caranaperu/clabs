<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de las clubes .
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class clubesController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'clubes', "validationId" => 'clubes_validation', "validationGroupId" => 'v_clubes', "validationRulesId" => 'getClubes'],
                "add" => ["langId" => 'clubes', "validationId" => 'clubes_validation', "validationGroupId" => 'v_clubes', "validationRulesId" => 'addClubes'],
                "del" => ["langId" => 'clubes', "validationId" => 'clubes_validation', "validationGroupId" => 'v_clubes', "validationRulesId" => 'delClubes'],
                "upd" => ["langId" => 'clubes', "validationId" => 'clubes_validation', "validationGroupId" => 'v_clubes', "validationRulesId" => 'updClubes']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['clubes_codigo', 'verifyExist'],
                "add" => ['clubes_codigo', 'clubes_descripcion', 'clubes_persona_contacto', 'clubes_direccion', 'clubes_email',
                    'clubes_telefono_oficina', 'clubes_telefono_celular', 'clubes_web_url', 'activo'],
                "del" => ['clubes_codigo', 'versionId'],
                "upd" => ['clubes_codigo', 'clubes_descripcion', 'clubes_persona_contacto', 'clubes_direccion', 'clubes_email',
                    'clubes_telefono_oficina', 'clubes_telefono_celular', 'clubes_web_url', 'versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['clubes_'],
            "paramsFixableToValue" => ["clubes_codigo" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'clubes_codigo'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() {
        return new ClubesBussinessService();
    }

}
