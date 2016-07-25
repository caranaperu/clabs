<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para los resultados de los atletas inputados en forma directa , es por eso que los registros del modelo
 * son una combinacion de la prueba de una competencia y el resultado , ya que en realidad el backend realiza operaciones
 * sobre ambas tablas , la de pruebas por competencia y la de resultados de un atleta.
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class atletasPruebasResultadosController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'atletaspruebas_resultados', "validationId" => 'atletaspruebas_resultados_validation', "validationGroupId" => 'v_atletaspruebas_resultados', "validationRulesId" => 'getAtletasPruebasResultados'],
                "add" => ["langId" => 'atletaspruebas_resultados', "validationId" => 'atletaspruebas_resultados_validation', "validationGroupId" => 'v_atletaspruebas_resultados', "validationRulesId" => 'addAtletasPruebasResultados'],
                "del" => ["langId" => 'atletaspruebas_resultados', "validationId" => 'atletaspruebas_resultados_validation', "validationGroupId" => 'v_atletaspruebas_resultados', "validationRulesId" => 'delAtletasPruebasResultados'],
                "upd" => ["langId" => 'atletaspruebas_resultados', "validationId" => 'atletaspruebas_resultados_validation', "validationGroupId" => 'v_atletaspruebas_resultados', "validationRulesId" => 'updAtletasPruebasResultados']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['atletas_resultados_id', 'verifyExist'],
                "add" => ['atletas_codigo', 'competencias_codigo', 'pruebas_codigo', 'competencias_pruebas_origen_combinada', 'competencias_pruebas_fecha',
                    'competencias_pruebas_viento', 'competencias_pruebas_tipo_serie', 'competencias_pruebas_nro_serie', 'competencias_pruebas_anemometro',
                    'competencias_pruebas_material_reglamentario', 'competencias_pruebas_anemometro', 'competencias_pruebas_manual', 'competencias_pruebas_observaciones',
                    'atletas_resultados_resultado', 'atletas_resultados_puntos', 'atletas_resultados_puesto', 'activo'],
                "del" => ['atletas_resultados_id', 'versionId'],
                "upd" => ['atletas_resultados_id', 'atletas_codigo', 'competencias_codigo', 'pruebas_codigo', 'competencias_pruebas_origen_combinada', 'competencias_pruebas_fecha',
                    'competencias_pruebas_viento', 'competencias_pruebas_tipo_serie', 'competencias_pruebas_nro_serie', 'competencias_pruebas_anemometro',
                    'competencias_pruebas_material_reglamentario', 'competencias_pruebas_anemometro', 'competencias_pruebas_manual', 'competencias_pruebas_observaciones',
                    'atletas_resultados_resultado', 'atletas_resultados_puntos', 'atletas_resultados_puesto', 'versionId', 'activo']],
            "paramsFixableToNull" => ['competencias_pruebas_', 'atletas_resultados_', 'atletas_', 'competencias_', 'pruebas_'],
            "paramsFixableToValue" => ["atletas_resultados_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'atletas_resultados_id'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() {
        return new AtletasPruebasResultadosBussinessService();
    }

}
