<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador que soporta la obtencion de datos para los resultados a poner
 * en diversos graficos del sistema.
 * Solo efectua fetch como unica operacion.
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class atletasResultadosGraphDataController extends app\common\controller\TSLAppDefaultCRUDController {

    public function __construct() {
        parent::__construct();
    }

    /**
     * {@inheritDoc}
     */
    protected function setupData() {

        $this->setupOpts = [
            "validateOptions" => [
                "fetch" => []
            ],
            "paramsList" => [
                "fetch" => []
            ],
            "paramsFixableToNull" => [],
            "paramsFixableToValue" => [],
            "paramToMapId" => ''
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() {
        return new AtletasResultadosGraphDataBussinessService();
    }

    /**
     *
     * @return string con el nombre base que se usara como response
     * procesor de este controller,
     */
    protected function getUserResponseProcessor() {
        return 'ResponseProcessorAmcharts';
    }

    /**
     *
     * @return string con el nombre base que se usara como filter
     * procesor de este controller,
     */
    public function getFilterProcessor() {
        return 'ConstraintProcessorAmcharts';
        ;
    }

}
