<?php

    if (!defined('BASEPATH'))
        exit('No direct script access allowed');

    /**
     * Controlador para los resultados de los atletas inputados en forma directa o por consolidacion de resultados de una
     * competencia.
     *
     * @author    Carlos Arana Reategui <aranape@gmail.com>
     * @version   0.1
     * @package   SoftAthletics
     * @copyright 2015-2016 Carlos Arana Reategui.
     * @license   GPL
     *
     */
    class atletasResultadosController extends app\common\controller\TSLAppDefaultCRUDController {

        public function __construct() {
            parent::__construct();
        }

        /**
         * {@inheritDoc}
         */
        protected function setupData() {

            $this->setupOpts = [
                "validateOptions"      => [
                    "fetch" => [],
                    "read"  => ["langId" => 'atletasresultados', "validationId" => 'atletasresultados_validation', "validationGroupId" => 'v_atletasresultados', "validationRulesId" => 'getAtletasResultados'],
                    "add"   => ["langId" => 'atletasresultados', "validationId" => 'atletasresultados_validation', "validationGroupId" => 'v_atletasresultados', "validationRulesId" => 'addAtletasResultados'],
                    "del"   => ["langId" => 'atletasresultados', "validationId" => 'atletasresultados_validation', "validationGroupId" => 'v_atletasresultados', "validationRulesId" => 'delAtletasResultados'],
                    "upd"   => ["langId" => 'atletasresultados', "validationId" => 'atletasresultados_validation', "validationGroupId" => 'v_atletasresultados', "validationRulesId" => 'updAtletasResultados']
                ],
                "paramsList"           => [
                    "fetch" => [],
                    "read"  => ['atletas_resultados_id', 'verifyExist'],
                    "add"   => ['competencias_pruebas_id', 'postas_id', 'atletas_codigo', 'atletas_resultados_resultado', 'atletas_resultados_puesto',
                        'atletas_resultados_puntos', 'atletas_resultados_viento', 'activo'],
                    "del"   => ['atletas_resultados_id', 'versionId'],
                    "upd"   => ['atletas_resultados_id', 'competencias_pruebas_id', 'postas_id', 'atletas_codigo', 'atletas_resultados_resultado',
                        'atletas_resultados_puesto', 'atletas_resultados_puntos', 'atletas_resultados_viento', 'versionId', 'activo']],
                "paramsFixableToNull"  => ['atletas_resultados_', 'competencias_', 'atletas_', 'pruebas_'.'postas_'],
                "paramsFixableToValue" => ["atletas_resultados_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => TRUE]],
                "paramToMapId"         => 'atletas_resultados_id'
            ];
        }

        /**
         * {@inheritDoc}
         */
        protected function getBussinessService() {
            return new AtletasResultadosBussinessService();
        }

    }
