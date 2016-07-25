<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para los resultados de los atletas inputados en forma directa , es por eso que los registros del modelo
 * so una combinacion de la prueba de una competencia y el resultado , ya que en realidad el backend realiza operaciones
 * sobre ambas tablas , la de pruebas por competencia y la de resultados de un atleta.
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class competenciasPruebasController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'competencias_pruebas', "validationId" => 'competencias_pruebas_validation', "validationGroupId" => 'v_competencias_pruebas', "validationRulesId" => 'getompetenciasPruebas'],
                "add" => ["langId" => 'competencias_pruebas', "validationId" => 'competencias_pruebas_validation', "validationGroupId" => 'v_competencias_pruebas', "validationRulesId" => 'addCompetenciasPruebas'],
                "del" => ["langId" => 'competencias_pruebas', "validationId" => 'competencias_pruebas_validation', "validationGroupId" => 'v_competencias_pruebas', "validationRulesId" => 'delCompetenciasPruebas'],
                "upd" => ["langId" => 'competencias_pruebas', "validationId" => 'competencias_pruebas_validation', "validationGroupId" => 'v_competencias_pruebas', "validationRulesId" => 'updCompetenciasPruebas']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['competencias_pruebas_id', 'verifyExist'],
                "add" => ['competencias_codigo', 'pruebas_codigo', 'competencias_pruebas_origen_combinada', 'competencias_pruebas_fecha', 'competencias_pruebas_viento',
                    'competencias_pruebas_tipo_serie', 'competencias_pruebas_nro_serie', 'competencias_pruebas_anemometro',
                    'competencias_pruebas_material_reglamentario','competencias_pruebas_manual', 'competencias_pruebas_observaciones',
                    'competencias_pruebas_origen_id','activo'],
                "del" => ['competencias_pruebas_id', 'versionId'],
                "upd" => ['competencias_pruebas_id','competencias_codigo', 'pruebas_codigo', 'competencias_pruebas_origen_combinada', 'competencias_pruebas_fecha',
                    'competencias_pruebas_viento','competencias_pruebas_tipo_serie', 'competencias_pruebas_nro_serie', 'competencias_pruebas_anemometro',
                    'competencias_pruebas_material_reglamentario','competencias_pruebas_manual', 'competencias_pruebas_observaciones',
                    'competencias_pruebas_origen_id','versionId', 'activo']],
            "paramsFixableToNull" => ['competencias_pruebas_', 'competencias_', 'pruebas_'],
            "paramsFixableToValue" => ["competencias_pruebas_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'competencias_pruebas_id'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() {
        return new CompetenciasPruebasBussinessService();
    }

}
