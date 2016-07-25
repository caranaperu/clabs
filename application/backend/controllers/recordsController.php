<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para registrar los records de diverso tipo sean nacionales , mundiales,etc
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class recordsController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'records', "validationId" => 'records_validation', "validationGroupId" => 'v_records', "validationRulesId" => 'getRecords'],
                "add" => ["langId" => 'records', "validationId" => 'records_validation', "validationGroupId" => 'v_records', "validationRulesId" => 'addRecords'],
                "del" => ["langId" => 'records', "validationId" => 'records_validation', "validationGroupId" => 'v_records', "validationRulesId" => 'delRecords'],
                "upd" => ["langId" => 'records', "validationId" => 'records_validation', "validationGroupId" => 'v_records', "validationRulesId" => 'updRecords']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['records_id', 'verifyExist'],
                "add" => ['records_tipo_codigo', 'atletas_resultados_id','categorias_codigo', 'records_id_origen','records_protected','activo'],
                "del" => ['records_id', 'versionId'],
                "upd" => ['records_id','records_tipo_codigo', 'atletas_resultados_id','categorias_codigo', 'records_id_origen','records_protected','versionId', 'activo'],
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
        return new RecordsBussinessService();
    }
}
