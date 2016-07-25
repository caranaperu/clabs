<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de las competencias atleticas.
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class competenciasController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'competencias', "validationId" => 'competencias_validation', "validationGroupId" => 'v_competencias', "validationRulesId" => 'getCompetencias'],
                "add" => ["langId" => 'competencias', "validationId" => 'competencias_validation', "validationGroupId" => 'v_competencias', "validationRulesId" => 'addCompetencias'],
                "del" => ["langId" => 'competencias', "validationId" => 'competencias_validation', "validationGroupId" => 'v_competencias', "validationRulesId" => 'delCompetencias'],
                "upd" => ["langId" => 'competencias', "validationId" => 'competencias_validation', "validationGroupId" => 'v_competencias', "validationRulesId" => 'updCompetencias']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['competencias_codigo', 'verifyExist'],
                "add" => ['competencias_codigo', 'competencias_descripcion', 'competencia_tipo_codigo', 'paises_codigo', 'ciudades_codigo',
                    'categorias_codigo', 'competencias_fecha_inicio', 'competencias_fecha_final', 'competencias_es_oficial',
                    'competencias_clasificacion','activo'],
                "del" => ['competencias_codigo', 'versionId'],
                "upd" => ['competencias_codigo', 'competencias_descripcion', 'competencia_tipo_codigo', 'paises_codigo', 'ciudades_codigo',
                    'categorias_codigo', 'competencias_fecha_inicio', 'competencias_fecha_final', 'competencias_es_oficial',
                    'competencias_clasificacion', 'versionId', 'activo']],
            "paramsFixableToNull" => ['competencias_', 'paises_', 'ciudades_', 'competencia_tipo_', 'categorias_'],
            "paramsFixableToValue" => ["competencias_codigo" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'competencias_codigo'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() {
        return new CompetenciasBussinessService();
    }
}
