<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de los tipos de records , digase
 * Panamericano, Sudamericano (Regional) , etc.
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class recordsTipoController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'recordstipo', "validationId" => 'recordstipo_validation', "validationGroupId" => 'v_records_tipo', "validationRulesId" => 'getRecordsTipo'],
                "add" => ["langId" => 'recordstipo', "validationId" => 'recordstipo_validation', "validationGroupId" => 'v_records_tipo', "validationRulesId" => 'addRecordsTipo'],
                "del" => ["langId" => 'recordstipo', "validationId" => 'recordstipo_validation', "validationGroupId" => 'v_records_tipo', "validationRulesId" => 'delRecordsTipo'],
                "upd" => ["langId" => 'recordstipo', "validationId" => 'recordstipo_validation', "validationGroupId" => 'v_records_tipo', "validationRulesId" => 'updRecordsTipo']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['records_tipo_codigo', 'verifyExist'],
                "add" => ['records_tipo_codigo', 'records_tipo_descripcion', 'records_tipo_abreviatura', 'records_tipo_tipo', 'records_tipo_clasificacion', 'records_tipo_peso', 'records_tipo_protected', 'activo'],
                "del" => ['records_tipo_codigo', 'versionId'],
                "upd" => ['records_tipo_codigo', 'records_tipo_descripcion', 'records_tipo_abreviatura', 'records_tipo_tipo', 'records_tipo_clasificacion', 'records_tipo_peso', 'records_tipo_protected', 'versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['records_tipo_'],
            "paramsFixableToValue" => ["records_tipo_codigo" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'records_tipo_codigo'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() {
        return new RecordsTipoBussinessService();
    }

}
