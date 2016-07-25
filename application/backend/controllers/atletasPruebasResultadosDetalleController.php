<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para los resultados de los atletas inputados en forma directa o por consolidacion de resultados de una
 * competencia, pero solo para las pruebas que corresponde al detalle de pruebas combinadas , no para las pruebas
 * normales.
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class atletasPruebasResultadosDetalleController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'atletaspruebas_resultados_detalle', "validationId" => 'atletaspruebas_resultados_detalle_validation', "validationGroupId" => 'v_atletaspruebas_resultados_detalle', "validationRulesId" => 'getAtletasPruebasResultadosDetalle'],
                "add" => ["langId" => 'atletaspruebas_resultados_detalle', "validationId" => 'atletaspruebas_resultados_detalle_validation', "validationGroupId" => 'v_atletaspruebas_resultados_detalle', "validationRulesId" => 'addAtletasPruebasResultadosDetalle'],
                "del" => ["langId" => 'atletaspruebas_resultados_detalle', "validationId" => 'atletaspruebas_resultados_detalle_validation', "validationGroupId" => 'v_atletaspruebas_resultados_detalle', "validationRulesId" => 'delAtletasPruebasResultadosDetalle'],
                "upd" => ["langId" => 'atletaspruebas_resultados_detalle', "validationId" => 'atletaspruebas_resultados_detalle_validation', "validationGroupId" => 'v_atletaspruebas_resultados_detalle', "validationRulesId" => 'updAtletasPruebasResultadosDetalle']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['atletas_resultados_id', 'verifyExist'],
                "add" => ['competencias_pruebas_id', 'atletas_codigo', 'competencias_codigo', 'pruebas_codigo', 'competencias_pruebas_origen_combinada',
                    'competencias_pruebas_fecha', 'competencias_pruebas_viento', 'competencias_pruebas_tipo_serie', 'competencias_pruebas_nro_serie',
                    'competencias_pruebas_anemometro', 'competencias_pruebas_material_reglamentario', 'competencias_pruebas_anemometro', 'competencias_pruebas_manual',
                    'competencias_pruebas_observaciones', 'atletas_resultados_resultado', 'atletas_resultados_puntos', 'atletas_resultados_puesto', 'activo'],
                "del" => ['atletas_resultados_id', 'versionId'],
                "upd" => ['atletas_resultados_id', 'competencias_pruebas_id', 'atletas_codigo', 'competencias_codigo', 'pruebas_codigo', 'competencias_pruebas_origen_combinada',
                    'competencias_pruebas_fecha', 'competencias_pruebas_viento', 'competencias_pruebas_tipo_serie', 'competencias_pruebas_nro_serie',
                    'competencias_pruebas_anemometro', 'competencias_pruebas_material_reglamentario', 'competencias_pruebas_anemometro', 'competencias_pruebas_manual',
                    'competencias_pruebas_observaciones', 'atletas_resultados_resultado', 'atletas_resultados_puntos', 'atletas_resultados_puesto', 'versionId', 'activo']],
            "paramsFixableToNull" => ['atletas_resultados_', 'competencias_', 'atletas_', 'pruebas_'],
            "paramsFixableToValue" => ["atletas_resultados_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true],
                "competencias_pruebas_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => false]],
            "paramToMapId" => 'atletas_resultados_id'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() {
        return new AtletasPruebasResultadosDetalleBussinessService();
    }

}
